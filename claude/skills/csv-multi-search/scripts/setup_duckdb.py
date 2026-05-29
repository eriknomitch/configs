#!/usr/bin/env python3
"""
Set up a DuckDB database from a CSV file with full-text search indexing.

Outputs go to .csv-search/<csv_stem>/ next to the CSV by default.

Usage:
    python setup_duckdb.py --csv data.csv --text-columns message_text --id-column id
    python setup_duckdb.py --csv data.csv --db /custom/path.duckdb --text-columns body --id-column id
"""

import argparse
import sys
import time
from pathlib import Path

try:
    import duckdb
except ImportError:
    print("ERROR: duckdb not installed. Run: pip install duckdb", file=sys.stderr)
    sys.exit(1)


def default_db_path(csv_path):
    """Compute default: .csv-search/<csv_stem>/data.duckdb next to the CSV."""
    csv_path = Path(csv_path).resolve()
    return csv_path.parent / ".csv-search" / csv_path.stem / "data.duckdb"


def main():
    parser = argparse.ArgumentParser(description="Load CSV into DuckDB with full-text search")
    parser.add_argument("--csv", required=True, help="Path to input CSV file")
    parser.add_argument("--db", default=None, help="Path for output DuckDB database (default: .csv-search/<stem>/data.duckdb)")
    parser.add_argument("--table", default="data", help="Table name (default: data)")
    parser.add_argument("--text-columns", required=True, nargs="+", help="Column(s) to index for full-text search")
    parser.add_argument("--id-column", required=True, help="Unique ID column for FTS index")
    parser.add_argument("--delimiter", default=None, help="CSV delimiter (auto-detected if not specified)")
    args = parser.parse_args()

    db_path = args.db or str(default_db_path(args.csv))

    # Ensure output directory exists
    Path(db_path).parent.mkdir(parents=True, exist_ok=True)

    print(f"CSV:    {args.csv}")
    print(f"DuckDB: {db_path}")
    print()

    con = duckdb.connect(db_path)

    # Load CSV
    print(f"Loading CSV...")
    t0 = time.time()

    read_opts = f"'{args.csv}'"
    if args.delimiter:
        read_opts = f"'{args.csv}', delim='{args.delimiter}'"

    con.execute(f"CREATE OR REPLACE TABLE {args.table} AS SELECT * FROM read_csv_auto({read_opts})")

    row_count = con.execute(f"SELECT count(*) FROM {args.table}").fetchone()[0]
    elapsed = time.time() - t0
    print(f"Loaded {row_count:,} rows in {elapsed:.1f}s")

    # Show schema
    print(f"\nTable schema ({args.table}):")
    schema = con.execute(f"DESCRIBE {args.table}").fetchall()
    for col_name, col_type, *_ in schema:
        marker = " ← FTS indexed" if col_name in args.text_columns else ""
        marker = " ← ID column" if col_name == args.id_column else marker
        print(f"  {col_name:30s} {col_type}{marker}")

    # Validate columns exist
    col_names = {row[0] for row in schema}
    for tc in args.text_columns:
        if tc not in col_names:
            print(f"\nERROR: text column '{tc}' not found. Available: {sorted(col_names)}", file=sys.stderr)
            sys.exit(1)
    if args.id_column not in col_names:
        print(f"\nERROR: id column '{args.id_column}' not found. Available: {sorted(col_names)}", file=sys.stderr)
        sys.exit(1)

    # Install and load FTS extension
    print("\nSetting up full-text search index...")
    t0 = time.time()
    con.execute("INSTALL fts")
    con.execute("LOAD fts")

    text_cols_str = ", ".join(f"'{c}'" for c in args.text_columns)
    con.execute(f"""
        PRAGMA create_fts_index(
            '{args.table}',
            '{args.id_column}',
            {text_cols_str},
            overwrite=1
        )
    """)
    elapsed = time.time() - t0
    print(f"FTS index created in {elapsed:.1f}s")

    # Sample
    print("\nSample data (first 3 rows):")
    sample = con.execute(f"SELECT * FROM {args.table} LIMIT 3").fetchdf()
    print(sample.to_string(index=False))

    print(f"\nDuckDB ready at: {db_path}")

    con.close()


if __name__ == "__main__":
    main()
