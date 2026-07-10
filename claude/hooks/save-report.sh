#!/usr/bin/env bash
#
# save-report.sh — Claude Code Stop hook
#
# Silently archives "report-like" final responses as timestamped .md files so
# you can keep them for later. Never blocks or interrupts the session: it always
# exits 0, and Stop-hook stdout never reaches the UI or the model's context.
#
# It reads `last_assistant_message` straight from the hook stdin payload — the
# supported interface. (Do NOT parse the transcript JSONL: per the Claude Code
# hooks docs it is written asynchronously and can lag the current turn.)
#
# Tunables (environment overrides):
#   CLAUDE_REPORTS_DIR    output root            (default: ~/.claude/reports)
#   REPORT_MIN_CHARS      min length to qualify  (default: 800)
#   REPORT_MIN_HEADINGS   markdown headings req. (default: 2)
#   CLAUDE_SKIP_REPORT_SAVE=1   disable entirely for a session
#
# Heuristic: a message qualifies as a "report" when it is at least
# REPORT_MIN_CHARS long AND is structured — either >= REPORT_MIN_HEADINGS
# markdown headings, or >= 2 table rows. Tune the env vars to taste.

[ -n "${CLAUDE_SKIP_REPORT_SAVE:-}" ] && exit 0

OUT_ROOT="${CLAUDE_REPORTS_DIR:-$HOME/.claude/reports}"
MIN_CHARS="${REPORT_MIN_CHARS:-800}"
MIN_HEADINGS="${REPORT_MIN_HEADINGS:-2}"

# Need jq to read the payload; if it's missing, do nothing (never disturb).
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
MSG=$(printf '%s' "$INPUT" | jq -r '.last_assistant_message // empty' 2>/dev/null)
[ -z "$MSG" ] && exit 0

# --- report heuristic ---------------------------------------------------------
LEN=${#MSG}
[ "$LEN" -lt "$MIN_CHARS" ] && exit 0

HEADINGS=$(printf '%s\n' "$MSG" | grep -cE '^#{1,6} ' 2>/dev/null); HEADINGS=${HEADINGS:-0}
TABLEROWS=$(printf '%s\n' "$MSG" | grep -cE '^[[:space:]]*\|.*\|[[:space:]]*$' 2>/dev/null); TABLEROWS=${TABLEROWS:-0}

if [ "$HEADINGS" -lt "$MIN_HEADINGS" ] && [ "$TABLEROWS" -lt 2 ]; then
  exit 0
fi

# --- filename slug from the first heading -------------------------------------
TITLE=$(printf '%s\n' "$MSG" | grep -m1 -E '^#{1,6} ' 2>/dev/null | sed -E 's/^#+[[:space:]]+//')
[ -z "$TITLE" ] && TITLE="report"
SLUG=$(printf '%s' "$TITLE" | tr '[:upper:]' '[:lower:]' \
       | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' | cut -c1-60)
[ -z "$SLUG" ] && SLUG="report"

# --- per-project destination --------------------------------------------------
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
PROJECT=$(basename "${CWD:-$PWD}")
DEST="$OUT_ROOT/$PROJECT"
mkdir -p "$DEST" 2>/dev/null || exit 0

STAMP=$(date +%Y%m%d-%H%M%S)
FILE="$DEST/${STAMP}-${SLUG}.md"

{
  printf -- '<!-- auto-saved by save-report Stop hook | %s -->\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')"
  printf -- '<!-- project: %s | cwd: %s -->\n\n' "$PROJECT" "${CWD:-$PWD}"
  printf -- '%s\n' "$MSG"
} > "$FILE" 2>/dev/null

exit 0
