#!/usr/bin/env bash
#
# backfill-report-index.sh — one-time (re-runnable) backfill of the report index.
#
# Scans the report archive and appends a catalog record to INDEX.jsonl for every
# .md report not already indexed. Idempotent: reports already present (matched by
# relative path) are skipped, so it is safe to re-run.
#
# Metadata is MECHANICAL here (title = first heading/line, summary = first prose
# line, keywords = top frequent non-stopword terms). Reports saved going forward
# by the judge-mode hook get model-quality metadata instead. Records written here
# carry "mode":"backfill" so you can tell them apart.
#
#   CLAUDE_REPORTS_DIR   archive root (default: ~/.claude/reports)

set -u
ROOT="${CLAUDE_REPORTS_DIR:-$HOME/.claude/reports}"
INDEX="$ROOT/INDEX.jsonl"

command -v jq >/dev/null 2>&1 || { echo "backfill: jq is required" >&2; exit 1; }
[ -d "$ROOT" ] || { echo "backfill: no reports dir at $ROOT" >&2; exit 0; }
touch "$INDEX" 2>/dev/null || { echo "backfill: cannot write $INDEX" >&2; exit 1; }

STOP='the|and|for|that|this|with|from|have|will|your|you|are|was|were|our|its|into|than|then|them|they|their|there|here|what|when|which|while|would|could|should|about|been|before|being|between|both|but|can|did|does|down|each|more|most|other|some|such|only|own|same|over|once|very|just|not|now|off|use|used|using|via|per'

added=0; skipped=0
while IFS= read -r F; do
  rel="${F#"$ROOT"/}"
  if grep -qF "\"path\":\"$rel\"" "$INDEX" 2>/dev/null; then
    skipped=$((skipped + 1)); continue
  fi
  proj="$(basename "$(dirname "$F")")"
  base="$(basename "$F")"
  # Reconstruct an ISO-ish timestamp from the filename prefix YYYYMMDD-HHMMSS.
  if printf '%s' "$base" | grep -qE '^[0-9]{8}-[0-9]{6}-'; then
    ts="${base:0:4}-${base:4:2}-${base:6:2}T${base:9:2}:${base:11:2}:${base:13:2}"
  else
    ts=""
  fi

  title=$(grep -m1 -E '^#{1,6} ' "$F" | sed -E 's/^#+[[:space:]]+//')
  [ -z "$title" ] && title=$(grep -m1 -vE '^[[:space:]]*(<!--.*-->)?[[:space:]]*$' "$F" \
                             | sed -E 's/^[[:space:]#>*_-]+//' | cut -c1-70)
  title=$(printf '%s' "$title" | sed -E 's/[`*_]//g')
  [ -z "$title" ] && title="report"

  summary=$(grep -m1 -vE '^[[:space:]]*(#{1,6} |<!--|$)' "$F" \
            | sed -E 's/^[[:space:]>*_`-]+//; s/[`*_]//g' | cut -c1-160)

  keywords=$(tr '[:upper:]' '[:lower:]' < "$F" | tr -c 'a-z0-9' '\n' \
    | grep -E '^[a-z][a-z0-9]{3,}$' | grep -vwE "$STOP" \
    | sort | uniq -c | sort -rn | head -6 | awk '{print $2}' | jq -R . | jq -cs . 2>/dev/null)
  [ -z "$keywords" ] && keywords='[]'

  if jq -nc --arg ts "$ts" --arg project "$proj" --arg mode backfill \
       --arg title "$title" --arg summary "$summary" --argjson keywords "$keywords" \
       --arg path "$rel" \
       '{ts:$ts,project:$project,mode:$mode,title:$title,summary:$summary,keywords:$keywords,path:$path}' \
       >> "$INDEX"; then
    added=$((added + 1))
  fi
done < <(find "$ROOT" -type f -name '*.md' | sort)

echo "backfill: +$added indexed, $skipped already present -> $INDEX"
