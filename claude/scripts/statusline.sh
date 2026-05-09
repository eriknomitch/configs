#!/usr/bin/env bash
# Claude Code statusline wrapper.
#
# Reads the JSON payload Claude Code pipes in, extracts the auto-generated
# session title (the `ai-title` line that powers the /resume picker) and the
# session cwd, and renders them on their own lines above ccstatusline's
# output.
#
# Falls back gracefully when ccstatusline is missing so the failure mode is
# visible instead of a silently empty statusline.

INPUT="$(cat)"

TRANSCRIPT="$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty')"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // .workspace.current_dir // empty')"

# Tilde-shorten so $HOME doesn't dominate the line on long paths.
CWD_DISPLAY="$CWD"
if [[ -n "$CWD" && -n "$HOME" ]]; then
  CWD_DISPLAY="${CWD/#$HOME/\~}"
fi

TITLE=""
if [[ -n "$TRANSCRIPT" && -r "$TRANSCRIPT" ]]; then
  # The session may contain multiple `ai-title` lines as Claude Code refines
  # the title — take the most recent one.
  TITLE="$(grep '"type":"ai-title"' "$TRANSCRIPT" 2>/dev/null \
    | tail -n 1 \
    | jq -r '.aiTitle // empty' 2>/dev/null)"
fi

# Build the prelude (title + cwd) shown above ccstatusline. Each piece prints
# on its own line if present; both missing → no prelude at all.
PRELUDE=""
[[ -n "$TITLE" ]] && PRELUDE+="$TITLE"$'\n'
[[ -n "$CWD_DISPLAY" ]] && PRELUDE+=$'\033[38;5;39m'"$CWD_DISPLAY"$'\033[0m\n'

if command -v ccstatusline >/dev/null 2>&1; then
  STATUS="$(printf '%s' "$INPUT" | ccstatusline)"
  printf '%s%s\n' "$PRELUDE" "$STATUS"
else
  printf '%sccstatusline not installed (bun install -g ccstatusline)\n' "$PRELUDE"
fi
