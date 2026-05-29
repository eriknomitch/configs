#!/usr/bin/env python3
"""
Hybrid search: combines DuckDB full-text search with ChromaDB semantic search.
Auto-discovers paths from .csv-search/<stem>/config.json when given --input.

CLI usage:
    # Auto-discover from input file path
    python search.py --input data.xlsx --query "frustrated with onboarding" --top-k 20
    python search.py --input data.csv --query "billing" --mode keyword --top-k 20
    python search.py --input data.parquet --query "pricing confusion" --mode hybrid --where "channel = 'sales'"

    # Or specify paths explicitly
    python search.py --chroma-path ./chroma_store --db data.duckdb --query "search terms"

Module usage:
    from search import HybridSearcher
    searcher = HybridSearcher.from_input("data.xlsx")
    results = searcher.hybrid("frustrated with setup", where="channel = 'support'", top_k=20)
"""

import argparse
import json
import sys
from pathlib import Path

try:
    import duckdb
except ImportError:
    duckdb = None

try:
    import chromadb
except ImportError:
    chromadb = None

try:
    from sentence_transformers import SentenceTransformer
except ImportError:
    SentenceTransformer = None


COMPRESSED_EXT = {".gz", ".zst", ".zlib"}
CSV_LIKE = {".csv", ".tsv", ".ssv", ".tab"}


def discover_config(input_path):
    """Find config.json in .csv-search/<stem>/ next to the input file."""
    input_path = Path(input_path).resolve()
    stem = input_path.stem
    # Handle double extensions like .csv.gz
    if input_path.suffix in COMPRESSED_EXT and Path(stem).suffix in CSV_LIKE:
        stem = Path(stem).stem
    config_path = input_path.parent / ".csv-search" / stem / "config.json"
    if config_path.exists():
        with open(config_path) as f:
            return json.load(f)
    return {}


class HybridSearcher:
    """Combines DuckDB FTS and ChromaDB semantic search."""

    def __init__(self, duckdb_path=None, chroma_path=None, table=None,
                 text_column=None, id_column=None, model_name=None, collection_name=None):
        self._con = None
        self._chroma_collection = None
        self._model = None

        self.duckdb_path = duckdb_path
        self.chroma_path = chroma_path
        self.table = table or "data"
        self.text_column = text_column or "message_text"
        self.id_column = id_column or "id"
        self.model_name = model_name or "all-MiniLM-L6-v2"
        self.collection_name = collection_name or "documents"

    @classmethod
    def from_input(cls, input_path):
        """Auto-discover search paths from .csv-search/ directory next to the input file."""
        config = discover_config(input_path)
        if not config:
            stem = Path(input_path).stem
            raise FileNotFoundError(
                f"No config found at .csv-search/{stem}/config.json. "
                f"Run setup_semantic.py first."
            )
        return cls(
            duckdb_path=config.get("db"),
            chroma_path=config.get("chroma_path"),
            table=config.get("table", "data"),
            text_column=config.get("text_column"),
            id_column=config.get("id_column"),
            model_name=config.get("model", "all-MiniLM-L6-v2"),
            collection_name=config.get("collection", "documents"),
        )

    # Keep backward compat
    from_csv = from_input

    @classmethod
    def from_config(cls, config_path):
        """Load from an explicit config.json path."""
        with open(config_path) as f:
            config = json.load(f)
        return cls(
            duckdb_path=config.get("db"),
            chroma_path=config.get("chroma_path"),
            table=config.get("table", "data"),
            text_column=config.get("text_column"),
            id_column=config.get("id_column"),
            model_name=config.get("model", "all-MiniLM-L6-v2"),
            collection_name=config.get("collection", "documents"),
        )

    @property
    def con(self):
        if self._con is None:
            if not duckdb:
                raise ImportError("duckdb not installed. Run: pip install duckdb")
            if not self.duckdb_path:
                raise ValueError("No DuckDB path configured")
            self._con = duckdb.connect(self.duckdb_path, read_only=True)
            self._con.execute("LOAD fts")
        return self._con

    @property
    def collection(self):
        if self._chroma_collection is None:
            if not chromadb:
                raise ImportError("chromadb not installed. Run: pip install chromadb")
            if not self.chroma_path:
                raise ValueError("No ChromaDB path configured")
            client = chromadb.PersistentClient(path=self.chroma_path)
            self._chroma_collection = client.get_collection(name=self.collection_name)
        return self._chroma_collection

    @property
    def model(self):
        if self._model is None:
            if not SentenceTransformer:
                raise ImportError("sentence-transformers not installed. Run: pip install sentence-transformers")
            self._model = SentenceTransformer(self.model_name)
        return self._model

    def keyword(self, query, top_k=20, where=None):
        """BM25 full-text search via DuckDB."""
        fts_table = f"fts_main_{self.table}"
        sql = f"""
            SELECT *, {fts_table}.match_bm25(rowid, ?) AS bm25_score
            FROM {self.table}
            WHERE bm25_score IS NOT NULL
        """
        if where:
            sql += f" AND ({where})"
        sql += f" ORDER BY bm25_score DESC LIMIT {top_k}"

        return self.con.execute(sql, [query]).fetchdf()

    def semantic(self, query, top_k=20, chroma_where=None):
        """Semantic similarity search via ChromaDB."""
        embedding = self.model.encode([query]).tolist()

        search_kwargs = {
            "query_embeddings": embedding,
            "n_results": top_k,
            "include": ["documents", "metadatas", "distances"]
        }
        if chroma_where:
            search_kwargs["where"] = chroma_where

        results = self.collection.query(**search_kwargs)

        rows = []
        for i in range(len(results["ids"][0])):
            row = {
                self.id_column: results["ids"][0][i],
                self.text_column: results["documents"][0][i] if results["documents"] else None,
                "similarity_score": 1 - results["distances"][0][i],
            }
            if results["metadatas"] and results["metadatas"][0][i]:
                row.update(results["metadatas"][0][i])
            rows.append(row)

        return rows

    def hybrid(self, query, top_k=20, where=None, chroma_where=None,
               semantic_weight=0.6, keyword_weight=0.4):
        """
        Combined search: candidates from both semantic and keyword, merged by weighted score.
        """
        sem_results = self.semantic(query, top_k=top_k * 2, chroma_where=chroma_where)
        kw_results = self.keyword(query, top_k=top_k * 2, where=where)

        # Normalize scores to 0-1
        sem_scores = {}
        for r in sem_results:
            sem_scores[str(r[self.id_column])] = r["similarity_score"]

        kw_scores = {}
        if len(kw_results) > 0:
            max_bm25 = kw_results["bm25_score"].max()
            if max_bm25 > 0:
                for _, row in kw_results.iterrows():
                    kw_scores[str(row[self.id_column])] = row["bm25_score"] / max_bm25

        # Merge
        all_ids = set(sem_scores.keys()) | set(kw_scores.keys())
        scored = []
        for rid in all_ids:
            s_sem = sem_scores.get(rid, 0)
            s_kw = kw_scores.get(rid, 0)
            combined = (semantic_weight * s_sem) + (keyword_weight * s_kw)
            scored.append((rid, combined, s_sem, s_kw))

        scored.sort(key=lambda x: x[1], reverse=True)
        scored = scored[:top_k]

        if not scored:
            return []

        ids_str = ", ".join(f"'{s[0]}'" for s in scored)
        score_map = {s[0]: s for s in scored}

        rows = self.con.execute(f"""
            SELECT * FROM {self.table}
            WHERE CAST({self.id_column} AS VARCHAR) IN ({ids_str})
        """).fetchdf()

        rows["hybrid_score"] = rows[self.id_column].astype(str).map(
            lambda x: score_map.get(x, (x, 0, 0, 0))[1]
        )
        rows["semantic_score"] = rows[self.id_column].astype(str).map(
            lambda x: score_map.get(x, (x, 0, 0, 0))[2]
        )
        rows["keyword_score"] = rows[self.id_column].astype(str).map(
            lambda x: score_map.get(x, (x, 0, 0, 0))[3]
        )

        return rows.sort_values("hybrid_score", ascending=False)

    def sql(self, query):
        """Run raw SQL against DuckDB."""
        return self.con.execute(query).fetchdf()

    def close(self):
        if self._con:
            self._con.close()


def format_results(results, max_text_width=80):
    """Pretty-print results for CLI output."""
    if hasattr(results, 'iterrows'):
        if len(results) == 0:
            print("No results found.")
            return
        for i, (_, row) in enumerate(results.iterrows()):
            print(f"\n--- Result {i+1} ---")
            for col in results.columns:
                val = str(row[col])
                if len(val) > max_text_width:
                    val = val[:max_text_width] + "..."
                print(f"  {col}: {val}")
    elif isinstance(results, list):
        if not results:
            print("No results found.")
            return
        for i, row in enumerate(results):
            print(f"\n--- Result {i+1} ---")
            for k, v in row.items():
                val = str(v)
                if len(val) > max_text_width:
                    val = val[:max_text_width] + "..."
                print(f"  {k}: {val}")


def main():
    parser = argparse.ArgumentParser(description="Hybrid search over tabular data")
    parser.add_argument("--query", required=True, help="Search query")
    parser.add_argument("--mode", choices=["semantic", "keyword", "hybrid"], default="hybrid",
                        help="Search mode (default: hybrid)")
    parser.add_argument("--input", default=None,
                        help="Path to original data file — auto-discovers .csv-search/ paths")
    # Keep --csv as hidden alias for backward compat
    parser.add_argument("--csv", default=None, help=argparse.SUPPRESS)
    parser.add_argument("--db", default=None, help="DuckDB database path (explicit override)")
    parser.add_argument("--chroma-path", default=None, help="ChromaDB storage path (explicit override)")
    parser.add_argument("--table", default=None, help="Table name")
    parser.add_argument("--text-column", default=None, help="Text column name")
    parser.add_argument("--id-column", default=None, help="ID column name")
    parser.add_argument("--where", default=None, help="SQL WHERE clause for filtering")
    parser.add_argument("--top-k", type=int, default=20, help="Number of results")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    args = parser.parse_args()

    input_file = args.input or args.csv

    # Build searcher: prefer --input auto-discovery, fall back to explicit paths
    if input_file:
        config = discover_config(input_file)
        searcher = HybridSearcher(
            duckdb_path=args.db or config.get("db"),
            chroma_path=args.chroma_path or config.get("chroma_path"),
            table=args.table or config.get("table"),
            text_column=args.text_column or config.get("text_column"),
            id_column=args.id_column or config.get("id_column"),
            model_name=config.get("model"),
            collection_name=config.get("collection"),
        )
    else:
        searcher = HybridSearcher(
            duckdb_path=args.db,
            chroma_path=args.chroma_path,
            table=args.table,
            text_column=args.text_column,
            id_column=args.id_column,
        )

    try:
        if args.mode == "semantic":
            results = searcher.semantic(args.query, top_k=args.top_k)
        elif args.mode == "keyword":
            results = searcher.keyword(args.query, top_k=args.top_k, where=args.where)
        else:  # hybrid
            has_db = searcher.duckdb_path and Path(searcher.duckdb_path).exists()
            has_chroma = searcher.chroma_path and Path(searcher.chroma_path).exists()

            if has_db and has_chroma:
                results = searcher.hybrid(args.query, top_k=args.top_k, where=args.where)
            elif has_chroma:
                results = searcher.semantic(args.query, top_k=args.top_k)
            elif has_db:
                results = searcher.keyword(args.query, top_k=args.top_k, where=args.where)
            else:
                print("ERROR: No DuckDB or ChromaDB found. Run setup_semantic.py first.", file=sys.stderr)
                sys.exit(1)

        if args.json:
            if hasattr(results, 'to_json'):
                print(results.to_json(orient="records", indent=2))
            else:
                print(json.dumps(results, indent=2, default=str))
        else:
            print(f"Search mode: {args.mode}")
            print(f"Query: {args.query}")
            if args.where:
                print(f"Filter: {args.where}")
            format_results(results)

    finally:
        searcher.close()


if __name__ == "__main__":
    main()
