---
name: csv-multi-search
description: >
  Search and explore tabular data files — CSV, TSV, Excel (.xlsx/.xls/.xlsm/.xlsb), ODS,
  JSON, JSONL/NDJSON, Parquet, Arrow IPC, Avro, and compressed variants (.csv.gz, .csv.zst).
  Default mode uses qsv — a fast Rust CLI that handles profiling, filtering, frequency analysis,
  and keyword search with zero setup. For conceptual or semantic search ("find messages about
  frustration" even when that word isn't used), offers an optional upgrade path using local
  embeddings (sentence-transformers + ChromaDB + DuckDB). Trigger on: "search my CSV",
  "search this spreadsheet", "explore this Excel file", "find rows where...", "what's in this
  Parquet file", "query my chat logs", "find messages about...", "filter this data",
  "what are people saying about...", or any reference to searching, filtering, analyzing, or
  exploring tabular data files. Also trigger when a user has a large data file and wants to ask
  questions about it, or asks how to make tabular data searchable.
---

# CSV Multi-Search

Search and explore tabular data files of any size. Uses qsv by default — no databases, no
Python deps, no setup time. Optionally upgrades to semantic vector search for conceptual queries.

## Supported formats

| Format | Extensions | How qsv handles it |
|---|---|---|
| CSV / TSV / SSV / TAB | `.csv`, `.tsv`, `.ssv`, `.tab` | Native — all commands work directly |
| Compressed CSV | `.csv.gz`, `.csv.zst`, `.csv.zlib` | Native (with polars feature) |
| Excel | `.xlsx`, `.xls`, `.xlsm`, `.xlsb` | `qsv excel` converts to CSV |
| OpenDocument Spreadsheet | `.ods` | `qsv excel` converts to CSV |
| JSON array | `.json` | `qsv json` converts to CSV |
| JSONL / NDJSON | `.jsonl`, `.ndjson` | `qsv jsonl` converts to CSV |
| Parquet | `.parquet` | `qsv sqlp` reads directly (polars feature) |
| Arrow IPC | `.arrow`, `.ipc` | `qsv sqlp` reads directly (polars feature) |

### Format detection and conversion

When the input file is not CSV/TSV, convert it to CSV first so all qsv commands work:

```bash
# Excel / ODS → CSV
qsv excel input.xlsx > data.csv
qsv excel input.xlsx --sheet "Sheet2" > data.csv   # specific sheet
qsv excel input.ods > data.csv

# JSON array → CSV
qsv json input.json > data.csv

# JSONL / NDJSON → CSV
qsv jsonl input.jsonl > data.csv

# Parquet → can query directly with sqlp, or convert
qsv sqlp "SELECT * FROM read_parquet('input.parquet')" --output data.csv

# Compressed CSV — most qsv commands handle .csv.gz natively, but you can also:
qsv input data.csv.gz > data.csv
```

For TSV files, most qsv commands auto-detect the delimiter. If not, pass `--delimiter '\t'`.

After conversion, proceed with the CSV as normal through the rest of this skill.

For DuckDB (semantic path), it reads many formats natively:
```sql
-- These all work in DuckDB without conversion
SELECT * FROM read_csv_auto('data.csv');
SELECT * FROM read_csv_auto('data.tsv');
SELECT * FROM read_parquet('data.parquet');
SELECT * FROM read_json_auto('data.json');
SELECT * FROM read_json_auto('data.jsonl', format='newline_delimited');
```

## Output location

All generated files go in a `.csv-search/<stem>/` directory next to the source file.

For a file at `/Users/me/Downloads/chat_messages.xlsx`:
```
/Users/me/Downloads/
├── chat_messages.xlsx
└── .csv-search/
    └── chat_messages/
        ├── data.csv           # Converted CSV (only if source was non-CSV)
        ├── data.duckdb        # DuckDB database (after semantic setup)
        ├── chroma_store/      # ChromaDB vectors (after semantic setup)
        └── config.json        # Saved column choices, model name, paths
```

The scripts default to this convention automatically. All paths can be overridden with flags.

## Tools

| Tool | Role | Install | When needed |
|---|---|---|---|
| **qsv** | Profiling, filtering, keyword search, stats, frequency, format conversion | `brew install qsv` or [binary release](https://github.com/dathere/qsv/releases) | Always (default) |
| **DuckDB** | SQL queries, full-text BM25 search | `pip install duckdb` | Only if user opts into semantic path |
| **sentence-transformers + ChromaDB** | Local embedding + vector search | `pip install sentence-transformers chromadb` | Only if user opts into semantic path |

## Scripts

| Script | Purpose |
|---|---|
| `setup_semantic.py` | One-command semantic upgrade: converts format if needed → installs deps → DuckDB + FTS → embeddings. |
| `search.py` | Query interface: semantic, keyword (BM25), or hybrid search. CLI + importable module. |
| `setup_duckdb.py` | Standalone DuckDB + FTS loader, for when the user only wants SQL without embeddings. |
| `setup_embeddings.py` | Standalone embedding script, for re-embedding or embedding a different sample size. |

## Default workflow: qsv search loop

When a user asks a question about a tabular data file, answer it using qsv commands. No setup
needed beyond having qsv installed. Work in a loop: run a qsv command, read the output, decide
if you have the answer or need another command.

### Step 0: Convert to CSV if needed (non-CSV formats only)

If the input file is not CSV/TSV, convert it first:

```bash
# Detect format
qsv sniff input_file --just-mime

# Convert (pick the right one based on extension)
qsv excel input.xlsx > data.csv
qsv json input.json > data.csv
qsv jsonl input.jsonl > data.csv
```

Then work with `data.csv` for all subsequent steps. Skip this for CSV/TSV files.

### Step 1: Profile the data (first time only)

On the first question about a new file, profile it to understand the shape:

```bash
# Build an index for fast subsequent operations
qsv index data.csv

# Row count (instant with index)
qsv count data.csv

# Column names
qsv headers data.csv

# Column types, cardinality, null counts
qsv stats data.csv --everything | qsv table

# Top values per column — reveals categoricals, common patterns
qsv frequency data.csv --limit 15 | qsv table

# A few sample rows to see real data
qsv sample 5 data.csv | qsv table
```

Cache this mentally — you'll reuse it for every subsequent question.

### Step 2: Answer questions with qsv commands

Map the user's question to the right qsv subcommand(s). Run them, read the output, and either
answer or refine with another command. Common patterns:

**Counting / aggregation:**
```bash
qsv count data.csv
qsv frequency data.csv --select channel --limit 50 | qsv table
qsv search -s status "closed" data.csv | qsv count
```

**Filtering rows:**
```bash
# Exact column match (regex)
qsv search -s channel "support" data.csv | qsv sample 10 | qsv table

# Case-insensitive text search
qsv search -i -s message_text "billing" data.csv | qsv table

# Multiple terms (regex OR)
qsv search -i -s message_text "refund|cancel|chargeback" data.csv | qsv table
```

**Sorting and top-N:**
```bash
qsv sort -s created_at -R data.csv | qsv slice --len 20 | qsv table
qsv frequency data.csv --select message_text --limit 20 | qsv table
```

**Selecting columns:**
```bash
qsv select id,channel,message_text data.csv | qsv search -s message_text "bug" | qsv table
```

**Sampling:**
```bash
qsv sample 100 data.csv -o sample.csv
qsv slice --len 10 data.csv | qsv table
```

**Dedup and validation:**
```bash
qsv dedup data.csv -o data_clean.csv
qsv validate data.csv
```

**Chaining for complex queries:**
```bash
qsv search -s channel "support" data.csv \
  | qsv search -i -s message_text "slow" \
  | qsv search -s created_at "^2024" \
  | qsv sample 10 \
  | qsv select id,created_at,message_text \
  | qsv table
```

### Step 3: Iterate

If the first command doesn't fully answer the question, refine. Narrow the filter, try a
different column, adjust the regex, or chain an additional command. Show the user what you ran
so they can iterate too.

### When qsv isn't enough

qsv handles structured queries and keyword matching well. But some questions need something
it can't do:

- **Conceptual / semantic search**: "find messages where people are frustrated" (they might say
  "this is so confusing" without the word "frustrated")
- **Complex SQL**: aggregations with GROUP BY, JOINs across files, window functions
- **Fuzzy / similarity matching**: "messages similar to this one"

When you recognize a question like this, suggest the semantic upgrade:

> "This kind of question works better with semantic search — it finds conceptually related
> results even when the exact words don't match. Want me to set that up? It requires installing
> a few Python packages (duckdb, sentence-transformers, chromadb) and will take a few minutes
> to embed your data."

Only proceed if the user says yes.

## Semantic upgrade path (opt-in only)

Only do this when the user explicitly agrees.

### One-command setup

```bash
python /path/to/skill/scripts/setup_semantic.py \
  --input data.xlsx \
  --text-column message_text \
  --id-column id
```

This single command:
1. Detects file format and converts to CSV if needed (Excel, JSON, JSONL, Parquet)
2. Checks and installs Python dependencies (duckdb, sentence-transformers, chromadb)
3. Loads the CSV into DuckDB with a BM25 full-text index
4. Embeds the text column into ChromaDB for semantic search
5. Saves a config.json so the search script auto-discovers everything

All outputs go to `.csv-search/<stem>/` next to the source file (override with `--output-dir`).

**Options:**
- `--model all-MiniLM-L6-v2` (default, fast, 80MB) or `--model all-mpnet-base-v2` (better quality, 420MB)
- `--sample 200000` — embed only a random sample first to test
- `--batch-size 512` — reduce to 128 or 64 if running out of memory
- `--metadata-columns channel,status` — extra columns to store alongside embeddings for filtering
- `--sheet "Sheet2"` — for Excel/ODS files, specify which sheet to use

### Query with semantic search

```bash
# Semantic search (auto-discovers .csv-search/ paths)
python /path/to/skill/scripts/search.py \
  --input data.xlsx \
  --query "frustrated with onboarding experience" \
  --top-k 20

# Hybrid (semantic + keyword + SQL filter)
python /path/to/skill/scripts/search.py \
  --input data.xlsx \
  --query "confused about pricing" \
  --mode hybrid \
  --where "channel = 'sales'" \
  --top-k 20
```

Or as an importable module:

```python
from search import HybridSearcher

searcher = HybridSearcher.from_input("data.xlsx")  # auto-discovers .csv-search/ paths
results = searcher.hybrid("confused about pricing", where="channel = 'sales'", top_k=20)
```

## Answering user questions — decision tree

1. **Structured / analytical** ("how many X?", "top 10 by Y", "rows matching Z")
   → qsv commands. Always the default.

2. **Keyword search** ("find messages mentioning refund")
   → `qsv search`. Default path.

3. **Conceptual / semantic** ("what are people frustrated about?", "show me onboarding confusion")
   → Ask user if they want semantic search. If yes, run `setup_semantic.py`. If no,
     approximate with `qsv search` using multiple keyword variants.

4. **Complex SQL** ("join these two files", "group by X and count where Y > 10")
   → DuckDB SQL (lighter than full semantic — just needs `pip install duckdb`).

5. **Broad exploration** ("what topics come up most?")
   → Start with `qsv frequency`. If that's not rich enough, suggest semantic + clustering.

## Troubleshooting

- **qsv not found**: `brew install qsv` on macOS, or download from [github.com/dathere/qsv/releases](https://github.com/dathere/qsv/releases). Alternatively `cargo install qsv --locked`.
- **Format not recognized**: use `qsv sniff file --just-mime` to detect the file type, then convert manually.
- **Excel sheet selection**: `qsv excel --sheet "SheetName" file.xlsx` or `--sheet 0` for first sheet (default).
- **DuckDB not found**: `pip install duckdb` or `brew install duckdb` (only needed for semantic path)
- **Out of memory during embedding**: reduce `--batch-size` to 128 or 64
- **ChromaDB import errors**: ensure `chromadb >= 0.4.0`
- **Slow embedding**: CPU-bound by default. `pip install sentence-transformers[gpu]` uses CUDA automatically.
- **CSV parsing errors**: try `qsv input data.csv -o data_fixed.csv` to normalize first. For DuckDB, pass `--delimiter '|'` to the setup script.
- **qsv search too slow on huge files**: run `qsv index data.csv` first.
- **Parquet files**: use `qsv sqlp` commands (requires polars feature in qsv build). Prebuilt binaries include it.
