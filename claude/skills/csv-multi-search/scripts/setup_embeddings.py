#!/usr/bin/env python3
"""
Embed text from a DuckDB table into ChromaDB for semantic search.
Uses sentence-transformers for local embedding (no API keys needed).

Usage:
    python setup_embeddings.py \
        --db data.duckdb \
        --table data \
        --text-column message_text \
        --id-column id \
        --chroma-path ./chroma_store \
        --model all-MiniLM-L6-v2 \
        --batch-size 512
"""

import argparse
import sys
import time
import json
from pathlib import Path

try:
    import duckdb
except ImportError:
    print("ERROR: duckdb not installed. Run: pip install duckdb", file=sys.stderr)
    sys.exit(1)

try:
    from sentence_transformers import SentenceTransformer
except ImportError:
    print("ERROR: sentence-transformers not installed. Run: pip install sentence-transformers", file=sys.stderr)
    sys.exit(1)

try:
    import chromadb
except ImportError:
    print("ERROR: chromadb not installed. Run: pip install chromadb", file=sys.stderr)
    sys.exit(1)


def get_existing_ids(collection):
    """Get IDs already in the collection to support resume."""
    try:
        result = collection.get(include=[])
        return set(result["ids"])
    except Exception:
        return set()


def main():
    parser = argparse.ArgumentParser(description="Embed text into ChromaDB for semantic search")
    parser.add_argument("--db", required=True, help="Path to DuckDB database")
    parser.add_argument("--table", default="data", help="Table name")
    parser.add_argument("--text-column", required=True, help="Column containing text to embed")
    parser.add_argument("--id-column", required=True, help="Unique ID column")
    parser.add_argument("--metadata-columns", nargs="*", default=[], help="Extra columns to store as metadata for filtering")
    parser.add_argument("--chroma-path", required=True, help="Directory for ChromaDB persistent storage")
    parser.add_argument("--collection", default="documents", help="ChromaDB collection name")
    parser.add_argument("--model", default="all-MiniLM-L6-v2", help="Sentence-transformer model name")
    parser.add_argument("--batch-size", type=int, default=512, help="Embedding batch size")
    parser.add_argument("--sample", type=int, default=None, help="Only embed this many rows (random sample)")
    parser.add_argument("--max-text-length", type=int, default=1000, help="Truncate text to this many chars before embedding")
    args = parser.parse_args()

    # Connect to DuckDB
    print(f"Reading from DuckDB: {args.db}")
    con = duckdb.connect(args.db, read_only=True)

    # Build query
    columns = [args.id_column, args.text_column] + args.metadata_columns
    col_str = ", ".join(columns)
    query = f"SELECT {col_str} FROM {args.table}"
    if args.sample:
        query += f" USING SAMPLE {args.sample}"

    total_rows = con.execute(f"SELECT count(*) FROM ({query})").fetchone()[0]
    print(f"Rows to embed: {total_rows:,}")

    # Load model
    print(f"Loading embedding model: {args.model}")
    t0 = time.time()
    model = SentenceTransformer(args.model)
    print(f"Model loaded in {time.time() - t0:.1f}s")

    # Set up ChromaDB
    print(f"ChromaDB storage: {args.chroma_path}")
    client = chromadb.PersistentClient(path=args.chroma_path)
    collection = client.get_or_create_collection(
        name=args.collection,
        metadata={"hnsw:space": "cosine"}
    )

    # Check for existing embeddings (resume support)
    existing_ids = get_existing_ids(collection)
    if existing_ids:
        print(f"Found {len(existing_ids):,} already-embedded rows — will skip them")

    # Ensure output directory exists
    Path(args.chroma_path).mkdir(parents=True, exist_ok=True)

    # Save config for the search script
    config = {
        "db": str(Path(args.db).resolve()),
        "table": args.table,
        "text_column": args.text_column,
        "id_column": args.id_column,
        "metadata_columns": args.metadata_columns,
        "model": args.model,
        "collection": args.collection,
    }
    config_path = Path(args.chroma_path) / "search_config.json"
    config_path.parent.mkdir(parents=True, exist_ok=True)
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)

    # Process in batches
    print(f"\nEmbedding with batch_size={args.batch_size}...")
    offset = 0
    embedded_count = 0
    skipped_count = 0
    t_start = time.time()

    while offset < total_rows:
        batch_query = f"{query} LIMIT {args.batch_size} OFFSET {offset}"
        batch = con.execute(batch_query).fetchall()

        if not batch:
            break

        ids = []
        texts = []
        metadatas = []

        for row in batch:
            row_id = str(row[0])
            text = str(row[1]) if row[1] is not None else ""

            # Skip already-embedded
            if row_id in existing_ids:
                skipped_count += 1
                continue

            # Skip empty text
            if not text.strip():
                skipped_count += 1
                continue

            # Truncate long text
            if len(text) > args.max_text_length:
                text = text[:args.max_text_length]

            ids.append(row_id)
            texts.append(text)

            # Build metadata dict
            meta = {}
            for i, col in enumerate(args.metadata_columns):
                val = row[2 + i]
                if val is not None:
                    meta[col] = str(val)
            metadatas.append(meta)

        if texts:
            embeddings = model.encode(texts, show_progress_bar=False, batch_size=args.batch_size)
            collection.add(
                ids=ids,
                embeddings=embeddings.tolist(),
                documents=texts,
                metadatas=metadatas if any(m for m in metadatas) else None
            )
            embedded_count += len(texts)

        offset += args.batch_size

        # Progress
        elapsed = time.time() - t_start
        rate = embedded_count / elapsed if elapsed > 0 else 0
        pct = min(100, (offset / total_rows) * 100)
        remaining = (total_rows - offset) / rate if rate > 0 else 0
        print(f"  {pct:5.1f}% | {embedded_count:,} embedded | {skipped_count:,} skipped | {rate:.0f} rows/s | ~{remaining:.0f}s remaining", end="\r")

    elapsed = time.time() - t_start
    print(f"\n\nDone! Embedded {embedded_count:,} rows in {elapsed:.1f}s ({skipped_count:,} skipped)")
    print(f"ChromaDB collection '{args.collection}' now has {collection.count():,} documents")
    print(f"Config saved to: {config_path}")

    con.close()


if __name__ == "__main__":
    main()
