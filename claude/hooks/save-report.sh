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
#   REPORT_MODE           basic | judge | off    (default: basic)
#   CLAUDE_REPORTS_DIR    output root            (default: ~/.claude/reports)
#   REPORT_MIN_CHARS      min length to qualify  (default: 800)
#   REPORT_MIN_HEADINGS   markdown headings req. (default: 2, basic mode)
#   CLAUDE_SKIP_REPORT_SAVE=1   disable entirely for a session (recursion guard)
#
# REPORT_MODE selects the decision strategy (unset -> basic):
#   * basic — qualify when the message is >= REPORT_MIN_CHARS AND structured
#     (>= REPORT_MIN_HEADINGS markdown headings, or >= 2 table rows). Zero cost,
#     zero latency, but dumb (misses heading-less prose reports).
#   * judge — after the cheap length pre-gate, ask a small model (Haiku) whether
#     the message is worth keeping. Smarter, catches prose. Costs one background
#     model call per candidate message.
#       REPORT_JUDGE_MODEL=haiku   model alias/id for the judge (default: haiku)
#       CLAUDE_JUDGE_BIN=<path>    claude binary (default: ~/.local/bin/claude)
#     The judge shells out to `claude -p` with CLAUDE_HEADLESS_CHILD=1 set, so
#     the child session's own hooks (notify.sh, this script) skip themselves —
#     no recursive saves, no spurious desktop notifications. Run this hook with
#     "async": true in settings.json so the judge call never blocks the turn.
#   * off — never save (equivalent to CLAUDE_SKIP_REPORT_SAVE=1).

# Skip if we ARE the headless judge child (guards recursion), or fully disabled.
[ -n "${CLAUDE_SKIP_REPORT_SAVE:-}${CLAUDE_HEADLESS_CHILD:-}" ] && exit 0

# Normalize the mode (case-insensitive). Anything unrecognized falls back to
# basic, so a typo fails safe to the zero-cost path rather than surprising you.
MODE=$(printf '%s' "${REPORT_MODE:-basic}" | tr '[:upper:]' '[:lower:]')
case "$MODE" in
  judge|basic) : ;;
  off)         exit 0 ;;
  *)           MODE=basic ;;
esac

OUT_ROOT="${CLAUDE_REPORTS_DIR:-$HOME/.claude/reports}"
MIN_CHARS="${REPORT_MIN_CHARS:-800}"
MIN_HEADINGS="${REPORT_MIN_HEADINGS:-2}"

# Need jq to read the payload; if it's missing, do nothing (never disturb).
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
MSG=$(printf '%s' "$INPUT" | jq -r '.last_assistant_message // empty' 2>/dev/null)
[ -z "$MSG" ] && exit 0

# --- decision: cheap length pre-gate, then structural OR semantic judge -------
LEN=${#MSG}
[ "$LEN" -lt "$MIN_CHARS" ] && exit 0

if [ "$MODE" = judge ]; then
  # Semantic judge via a small model. The whole hook runs async, so this call
  # (Claude startup + a Haiku turn) never blocks the user's turn.
  CLAUDE_BIN="${CLAUDE_JUDGE_BIN:-$HOME/.local/bin/claude}"
  [ -x "$CLAUDE_BIN" ] || CLAUDE_BIN="$(command -v claude 2>/dev/null)"
  [ -x "$CLAUDE_BIN" ] || exit 0   # no usable CLI -> do nothing (never disturb)

  JUDGE_PROMPT="You are a silent binary classifier. Decide whether the assistant message below is a substantive artifact the user would plausibly want to keep as a saved file — e.g. a report, research summary, comparison, analysis, plan, design doc, runbook, spec, or a meaningful written draft. It is NOT keepable if it is a short conversational reply, a status update, a confirmation, a clarifying question, a brief code-fix explanation, or routine back-and-forth. Respond with EXACTLY one word: YES or NO.

--- MESSAGE START ---
$MSG
--- MESSAGE END ---"

  VERDICT=$(printf '%s' "$JUDGE_PROMPT" \
    | CLAUDE_HEADLESS_CHILD=1 CLAUDE_SKIP_REPORT_SAVE=1 \
      "$CLAUDE_BIN" -p --model "${REPORT_JUDGE_MODEL:-haiku}" 2>/dev/null \
    | tr '[:upper:]' '[:lower:]')
  printf '%s' "$VERDICT" | grep -q 'yes' || exit 0
else
  # basic: structural heuristic — require markdown structure.
  HEADINGS=$(printf '%s\n' "$MSG" | grep -cE '^#{1,6} ' 2>/dev/null); HEADINGS=${HEADINGS:-0}
  TABLEROWS=$(printf '%s\n' "$MSG" | grep -cE '^[[:space:]]*\|.*\|[[:space:]]*$' 2>/dev/null); TABLEROWS=${TABLEROWS:-0}
  if [ "$HEADINGS" -lt "$MIN_HEADINGS" ] && [ "$TABLEROWS" -lt 2 ]; then
    exit 0
  fi
fi

# --- filename slug: first heading, else first text line -----------------------
TITLE=$(printf '%s\n' "$MSG" | grep -m1 -E '^#{1,6} ' 2>/dev/null | sed -E 's/^#+[[:space:]]+//')
[ -z "$TITLE" ] && TITLE=$(printf '%s\n' "$MSG" | grep -m1 -E '[[:alnum:]]' 2>/dev/null | sed -E 's/^[[:space:]#>*-]+//' | cut -c1-60)
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
