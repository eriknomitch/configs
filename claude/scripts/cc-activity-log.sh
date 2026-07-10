#!/usr/bin/env bash
# Silent per-session activity log for Claude Code.
#
# Wired to PostToolUse / UserPromptSubmit / Stop hooks. Appends a readable line
# per event to ~/.claude/activity/<session_id>.log so you have a durable,
# greppable record of what Claude did — open it on demand instead of scrolling
# the terminal. Also maintains current.log -> the most-recently-active session
# for easy `tail -f`.
#
# Best-effort: never blocks Claude and always exits 0, even if jq/parse fails.

INPUT="$(cat)"

DIR="$HOME/.claude/activity"
mkdir -p "$DIR" 2>/dev/null

SID="$(printf '%s' "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)"
EVENT="$(printf '%s' "$INPUT" | jq -r '.hook_event_name // "?"' 2>/dev/null)"
LOG="$DIR/${SID:-unknown}.log"
TS="$(date '+%H:%M:%S')"

case "$EVENT" in
  UserPromptSubmit)
    PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null | head -n1 | cut -c1-100)"
    printf '\n### %s  %s\n' "$(date '+%Y-%m-%d %H:%M')" "$PROMPT" >> "$LOG"
    ;;
  PostToolUse)
    TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // "?"' 2>/dev/null)"
    # Pick the most descriptive arg available for the tool, whatever it is.
    TARGET="$(printf '%s' "$INPUT" \
      | jq -r '.tool_input.file_path // .tool_input.command // .tool_input.pattern // .tool_input.description // .tool_input.url // empty' 2>/dev/null \
      | head -n1 | cut -c1-120)"
    printf -- '- %s  %-10s %s\n' "$TS" "$TOOL" "$TARGET" >> "$LOG"
    ;;
  Stop)
    printf -- '- %s  — turn complete —\n' "$TS" >> "$LOG"
    ;;
esac

# Convenience: always point current.log at the active session's log.
ln -sfn "$LOG" "$DIR/current.log" 2>/dev/null

exit 0
