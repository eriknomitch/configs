#!/usr/bin/env python3
"""
One-command semantic search setup for tabular data files.

Supports: CSV, TSV, Excel (.xlsx/.xls/.xlsm/.xlsb/.ods), JSON, JSONL, Parquet.
Automatically converts non-CSV formats to CSV before loading.

Orchestrates the full pipeline:
  1. Detect format and convert to CSV if needed
  2. Check/install Python dependencies (duckdb, sentence-transformers, chromadb)
  3. Load CSV into DuckDB with BM25 full-text index
  4. Embed text column into ChromaDB for semantic search
  5. Save config.json for the search script to auto-discover

All outputs go to .csv-search/<stem>/ next to the source file by default.

Usage:
    python setup_semantic.py --input chat_messages.csv --text-column message_text --id-column id
    python setup_semantic.py --input data.xlsx --text-column body --id-column id --sheet "Sheet2"
    python setup_semantic.py --input export.jsonl --text-column text --id-column id --sample 200000
"""

import argparse
import importlib
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path


# Extensions that are already CSV-like (qsv reads natively)
CSV_LIKE = {".csv", ".tsv", ".ssv", ".tab"}

# Extensions that need conversion
EXCEL_LIKE = {".xlsx", ".xls", ".xlsm", ".xlsb", ".ods"}
JSON_EXT = {".json"}
JSONL_EXT = {".jsonl", ".ndjson"}
PARQUET_EXT = {".parquet"}
ARROW_EXT = {".arrow", ".ipc"}
COMPRESSED_CSV = {".gz", ".zst", ".zlib"}


def get_output_dir(input_path, override=None):
    """Compute default output directory: .csv-search/<stem>/ next to the input file."""
    if override:
        return Path(override)
    input_path = Path(input_path).resolve()
    stem = input_path.stem
    # Handle double extensions like .csv.gz
    if input_path.suffix in COMPRESSED_CSV and Path(stem).suffix in CSV_LIKE:
        stem = Path(stem).stem
    return input_path.parent / ".csv-search" / stem


def detect_format(input_path):
    """Detect file format from extension."""
    p = Path(input_path)
    ext = p.suffix.lower()

    # Compressed CSV: .csv.gz, .tsv.zst, etc.
    if ext in COMPRESSED_CSV:
        inner_ext = Path(p.stem).suffix.lower()
        if inner_ext in CSV_LIKE:
            return "compressed_csv"

    if ext in CSV_LIKE:
        return "csv"
    if ext in EXCEL_LIKE:
        return "excel"
    if ext in JSON_EXT:
        return "json"
    if ext in JSONL_EXT:
        return "jsonl"
    if ext in PARQUET_EXT:
        return "parquet"
    if ext in ARROW_EXT:
        return "arrow"

    # Default to CSV and hope for the best
    return "csv"


def convert_to_csv(input_path, output_dir, fmt, sheet=None):
    """Convert non-CSV formats to CSV. Returns path to the CSV file."""
    csv_path = output_dir / "data.csv"
    output_dir.mkdir(parents=True, exist_ok=True)

    if fmt == "csv":
        return str(input_path)  # No conversion needed

    if fmt == "compressed_csv":
        # qsv input handles decompression
        print(f"Decompressing {input_path}...")
        if not shutil.which("qsv"):
            # Fall back to DuckDB
            print("  (qsv not found, will load compressed file directly via DuckDB)")
            return str(input_path)
        result = subprocess.run(
            f'qsv input "{input_path}" -o "{csv_path}"',
            shell=True, capture_output=True, text=True
        )
        if result.returncode == 0:
            print(f"  Decompressed to: {csv_path}")
            return str(csv_path)
        print(f"  Warning: qsv decompression failed, will try DuckDB directly")
        return str(input_path)

    if not shutil.which("qsv"):
        print(f"ERROR: qsv is required to convert {fmt} files. Install: brew install qsv", file=sys.stderr)
        sys.exit(1)

    if fmt == "excel":
        cmd = f'qsv excel "{input_path}"'
        if sheet is not None:
            cmd = f'qsv excel --sheet "{sheet}" "{input_path}"'
        print(f"Converting Excel/ODS to CSV...")
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"ERROR: qsv excel failed:\n{result.stderr}", file=sys.stderr)
            sys.exit(1)
        with open(csv_path, "w") as f:
            f.write(result.stdout)
        print(f"  Converted to: {csv_path}")
        return str(csv_path)

    if fmt == "json":
        print(f"Converting JSON array to CSV...")
        result = subprocess.run(
            f'qsv json "{input_path}"', shell=True, capture_output=True, text=True
        )
        if result.returncode != 0:
            print(f"ERROR: qsv json failed:\n{result.stderr}", file=sys.stderr)
            sys.exit(1)
        with open(csv_path, "w") as f:
            f.write(result.stdout)
        print(f"  Converted to: {csv_path}")
        return str(csv_path)

    if fmt == "jsonl":
        print(f"Converting JSONL/NDJSON to CSV...")
        result = subprocess.run(
            f'qsv jsonl "{input_path}"', shell=True, capture_output=True, text=True
        )
        if result.returncode != 0:
            print(f"ERROR: qsv jsonl failed:\n{result.stderr}", file=sys.stderr)
            sys.exit(1)
        with open(csv_path, "w") as f:
            f.write(result.stdout)
        print(f"  Converted to: {csv_path}")
        return str(csv_path)

    if fmt in ("parquet", "arrow"):
        # Use DuckDB for parquet/arrow since it handles them natively
        print(f"Converting {fmt} to CSV via DuckDB...")
        try:
            import duckdb
            read_fn = "read_parquet" if fmt == "parquet" else "read_ipc"
            con = duckdb.connect()
            con.execute(f"COPY (SELECT * FROM {read_fn}('{input_path}')) TO '{csv_path}' (HEADER, DELIMITER ',')")
            con.close()
            print(f"  Converted to: {csv_path}")
            return str(csv_path)
        except ImportError:
            print(f"ERROR: DuckDB required for {fmt} conversion. Run: pip install duckdb", file=sys.stderr)
            sys.exit(1)

    # Unknown format — just try it as CSV
    print(f"Warning: Unknown format '{fmt}', attempting to use as-is")
    return str(input_path)


def check_and_install_deps():
    """Check for required packages, install any that are missing."""
    required = {
        "duckdb": "duckdb",
        "sentence_transformers": "sentence-transformers",
        "chromadb": "chromadb",
    }

    missing = []
    for import_name, pip_name in required.items():
        try:
            importlib.import_module(import_name)
        except ImportError:
            missing.append(pip_name)

    if not missing:
        print("All Python dependencies already installed.")
        return True

    print(f"Installing missing packages: {', '.join(missing)}")
    cmd = [sys.executable, "-m", "pip", "install", "--break-system-packages"] + missing
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        cmd = [sys.executable, "-m", "pip", "install"] + missing
        result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"ERROR: Failed to install dependencies:\n{result.stderr}", file=sys.stderr)
        return False

    print("Dependencies installed successfully.")
    return True


def run_script(script_name, args_list):
    """Run a sibling script with arguments."""
    script_dir = Path(__file__).parent
    script_path = script_dir / script_name
    cmd = [sys.executable, str(script_path)] + args_list
    result = subprocess.run(cmd)
    return result.returncode == 0


def main():
    parser = argparse.ArgumentParser(
        description="One-command semantic search setup for tabular data files"
    )
    parser.add_argument("--input", required=True,
                        help="Path to source file (CSV, TSV, Excel, JSON, JSONL, Parquet, etc.)")
    parser.add_argument("--text-column", required=True, help="Column containing searchable text")
    parser.add_argument("--id-column", required=True, help="Unique ID column")
    parser.add_argument("--metadata-columns", nargs="*", default=[],
                        help="Extra columns to store as filterable metadata in ChromaDB")
    parser.add_argument("--output-dir", default=None,
                        help="Override output directory (default: .csv-search/<stem>/ next to input)")
    parser.add_argument("--sheet", default=None,
                        help="For Excel/ODS files: sheet name or zero-based index (default: first sheet)")
    parser.add_argument("--table", default="data", help="DuckDB table name (default: data)")
    parser.add_argument("--model", default="all-MiniLM-L6-v2",
                        help="Sentence-transformer model (default: all-MiniLM-L6-v2)")
    parser.add_argument("--batch-size", type=int, default=512, help="Embedding batch size")
    parser.add_argument("--sample", type=int, default=None,
                        help="Only embed this many rows (random sample)")
    parser.add_argument("--delimiter", default=None, help="CSV delimiter if not comma")
    parser.add_argument("--skip-embeddings", action="store_true",
                        help="Only set up DuckDB + FTS, skip the embedding step")
    args = parser.parse_args()

    input_path = Path(args.input).resolve()
    if not input_path.exists():
        print(f"ERROR: File not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    output_dir = get_output_dir(input_path, args.output_dir)
    db_path = output_dir / "data.duckdb"
    chroma_path = output_dir / "chroma_store"

    print(f"Input:      {input_path}")
    print(f"Output dir: {output_dir}")
    print()

    # Step 0: Format detection and conversion
    fmt = detect_format(input_path)
    print("=" * 60)
    print(f"STEP 0: Format detection ({fmt})")
    print("=" * 60)

    if fmt != "csv":
        csv_path = convert_to_csv(input_path, output_dir, fmt, sheet=args.sheet)
    else:
        csv_path = str(input_path)
    print()

    # Step 1: Dependencies
    print("=" * 60)
    print("STEP 1/3: Checking dependencies")
    print("=" * 60)
    if not check_and_install_deps():
        sys.exit(1)
    print()

    # Step 2: DuckDB + FTS
    print("=" * 60)
    print("STEP 2/3: Loading into DuckDB with full-text search")
    print("=" * 60)
    duckdb_args = [
        "--csv", csv_path,
        "--db", str(db_path),
        "--table", args.table,
        "--text-columns", args.text_column,
        "--id-column", args.id_column,
    ]
    if args.delimiter:
        duckdb_args += ["--delimiter", args.delimiter]

    if not run_script("setup_duckdb.py", duckdb_args):
        print("ERROR: DuckDB setup failed.", file=sys.stderr)
        sys.exit(1)
    print()

    # Step 3: Embeddings
    if args.skip_embeddings:
        print("Skipping embeddings (--skip-embeddings). DuckDB + FTS is ready.")
    else:
        print("=" * 60)
        print("STEP 3/3: Embedding text for semantic search")
        print("=" * 60)
        embed_args = [
            "--db", str(db_path),
            "--table", args.table,
            "--text-column", args.text_column,
            "--id-column", args.id_column,
            "--chroma-path", str(chroma_path),
            "--model", args.model,
            "--batch-size", str(args.batch_size),
        ]
        if args.sample:
            embed_args += ["--sample", str(args.sample)]
        if args.metadata_columns:
            embed_args += ["--metadata-columns"] + args.metadata_columns

        if not run_script("setup_embeddings.py", embed_args):
            print("ERROR: Embedding setup failed.", file=sys.stderr)
            sys.exit(1)
    print()

    # Save config
    config = {
        "input": str(input_path),
        "input_format": fmt,
        "csv": csv_path,
        "output_dir": str(output_dir),
        "db": str(db_path),
        "chroma_path": str(chroma_path),
        "table": args.table,
        "text_column": args.text_column,
        "id_column": args.id_column,
        "metadata_columns": args.metadata_columns,
        "model": args.model,
        "has_embeddings": not args.skip_embeddings,
    }
    config_path = output_dir / "config.json"
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)

    print("=" * 60)
    print("SETUP COMPLETE")
    print("=" * 60)
    print(f"Config:     {config_path}")
    print(f"DuckDB:     {db_path}")
    if not args.skip_embeddings:
        print(f"ChromaDB:   {chroma_path}")
    print()
    print("Search with:")
    print(f'  python /path/to/skill/scripts/search.py --input "{input_path}" --query "your question"')


if __name__ == "__main__":
    main()
