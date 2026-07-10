---
name: reports
description: >
  Interpret a natural-language request about the auto-saved report archive (the
  .md files the save-report Stop hook writes under ~/.claude/reports/<project>/)
  and do the right thing: list the most recent reports, list or filter by project
  or date, or search by topic and surface the matching report. Use when the user
  types /reports, asks to "show/list my reports", "recent reports", "what reports
  do I have", "find/pull up my report about X", or otherwise references the saved
  reports archive. Read-only: it finds, lists, and displays reports — it never
  edits or deletes them.
argument-hint: "[what you want — e.g. 'last 5', 'list from this project', or a topic to search]"
---

# Reports

Interpret the request (the text after `/reports`) and serve it from the local
report archive. You do the interpreting — there is no fixed command grammar.
Map the request to one of the intents below, run the matching recipe, and format
the result. If the request is ambiguous, make the most reasonable call and say
which interpretation you used in one line.

## What you're operating on

- **Archive root:** `${CLAUDE_REPORTS_DIR:-$HOME/.claude/reports}` (call it `$ROOT`).
- **Layout:** `$ROOT/<project>/<YYYYMMDD-HHMMSS>-<slug>.md`. The `<project>` dir is
  the basename of the repo/cwd the report was saved from. The filename starts with
  a sortable timestamp, so **sorting filenames lexically = chronological order**.
- **Current project:** `$(basename "$PWD")`. "this project" / "here" means that dir.
- **File shape:** two HTML-comment provenance lines, a blank line, then the report
  body:
  ```
  <!-- auto-saved by save-report Stop hook | 2026-07-10T04:42:47-0500 -->
  <!-- project: qumis-platform | cwd: /path/to/repo -->

  # Actual report content...
  ```
- **Optional index — `$ROOT/INDEX.jsonl`.** If present, it is one JSON record per
  report and is the fast path for topical search. Schema:
  ```json
  {"ts":"2026-07-10T04:42:47-0500","project":"qumis-platform","mode":"judge",
   "title":"Cache Strategy Recommendation","summary":"one-line gist",
   "keywords":["redis","elasticache","ttl"],"path":"qumis-platform/2026...-slug.md"}
  ```
  **If `INDEX.jsonl` does not exist yet, ignore it and use the filesystem +
  body-grep recipes below** — everything still works, topical search is just
  broader (matches full text instead of curated keywords).

## Intents and recipes

Set up once:
```bash
ROOT="${CLAUDE_REPORTS_DIR:-$HOME/.claude/reports}"
PROJECT="$(basename "$PWD")"
```

### 1. Recency — "last N", "recent", "latest", "what did I save today"
Across all projects (true chronological via the filename timestamp):
```bash
find "$ROOT" -type f -name '*.md' | awk -F/ '{print $NF"\t"$0}' | sort -r | head -N | cut -f2-
```
Scoped to the current project:
```bash
ls "$ROOT/$PROJECT"/*.md 2>/dev/null | sort -r | head -N
```

### 2. List / scope — "list reports from this project", "all reports", "reports from <project>"
```bash
ls "$ROOT"                              # what projects have reports
ls "$ROOT/$PROJECT"/*.md 2>/dev/null | sort -r   # this project, newest first
find "$ROOT" -type f -name '*.md' | sort            # everything
```
Default sort is **newest first** unless the user asks otherwise.

### 3. Topical search — "comparison of onboarding tools", "find my report about X"
Pull the salient terms out of the request yourself (e.g. "onboarding", "tools"),
then:
```bash
# Preferred: query the index if it exists
[ -f "$ROOT/INDEX.jsonl" ] && jq -c --arg q 'TERM' '
  select(([.title,.summary,(.keywords//[]|join(" "))]|join(" ")|ascii_downcase)
         | test($q; "i"))' "$ROOT/INDEX.jsonl"

# Fallback: grep report bodies
grep -ril --include='*.md' 'TERM' "$ROOT"
```
For a multi-word topic, grep/filter for each salient term, gather candidates,
**read the top few files**, judge which actually matches the request, and surface
the best one. If several are close, list them ranked and ask which (or show the
top one and note the alternatives). If nothing matches, say so plainly and show
the nearest few by topic rather than inventing a match.

### Helper — extract a human title from a file (filesystem mode)
```bash
# first markdown heading; else first real content line (skip provenance comments)
T=$(grep -m1 -E '^#{1,6} ' "$F" | sed -E 's/^#+[[:space:]]+//')
[ -z "$T" ] && T=$(grep -m1 -vE '^[[:space:]]*(<!--.*-->)?[[:space:]]*$' "$F" \
                   | sed -E 's/^[[:space:]#>*_-]+//' | cut -c1-80)
printf '%s\n' "$T"
```
Do **not** collapse this into `grep … | sed … || fallback` — the pipe makes the
exit code `sed`'s (always 0), so the fallback never runs. Use the explicit
empty-check above. When displaying, strip stray markdown emphasis (`*`, `` ` ``).
Prefer the `title` from `INDEX.jsonl` when it exists.

### Helper — show a report's content without the provenance header
```bash
sed -E '/^<!--.*-->$/d' "$F"   # drop the two comment lines; body remains
```

## Output formatting

- **Lists / recency →** a compact Markdown table, newest first:
  `| Date | Project | Title | File |`. Derive Date from the filename timestamp
  (`YYYYMMDD-HHMMSS`). Keep titles short; link the path as inline code.
- **A single found report →** if it's short, print the body (header stripped). If
  it's long, give a tight summary + the key points, then the file path so the user
  can open the full thing. Don't dump a huge file verbatim without saying so.
- **Nothing found →** one honest line ("No report matches 'X'."), then the closest
  few candidates if any, so the user can redirect.
- Always end a list with the archive path used, so the user knows where to look.

## Scope notes

- Read-only. Never edit, move, or delete report files or the index — if the user
  wants pruning, say that's out of scope for this skill.
- If `$ROOT` doesn't exist or is empty, say the archive is empty (the save-report
  hook may not have fired yet) rather than erroring.
- "last 5" with no project mentioned → all projects. "from this project" / "here"
  → current project only. When unsure of scope, default to the current project and
  say so.
