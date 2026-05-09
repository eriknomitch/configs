#!/usr/bin/env bash
# Claude Code statusline wrapper.
#
# Reads the JSON payload Claude Code pipes in, extracts the auto-generated
# session title (the `ai-title` line that powers the /resume picker) from the
# session JSONL, and renders it on its own line above ccstatusline's output.
#
# Falls back gracefully when ccstatusline is missing so the failure mode is
# visible instead of a silently empty statusline.

INPUT="$(cat)"

TRANSCRIPT="$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty')"

TITLE=""
if [[ -n "$TRANSCRIPT" && -r "$TRANSCRIPT" ]]; then
  # The session may contain multiple `ai-title` lines as Claude Code refines
  # the title — take the most recent one.
  TITLE="$(grep '"type":"ai-title"' "$TRANSCRIPT" 2>/dev/null \
    | tail -n 1 \
    | jq -r '.aiTitle // empty' 2>/dev/null)"
fi

if command -v ccstatusline >/dev/null 2>&1; then
  STATUS="$(printf '%s' "$INPUT" | ccstatusline)"
  if [[ -n "$TITLE" ]]; then
    printf '%s\n%s\n' "$TITLE" "$STATUS"
  else
    printf '%s\n' "$STATUS"
  fi
else
  CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // .workspace.current_dir // "?"')"
  if [[ -n "$TITLE" ]]; then
    printf '%s\n%s | ccstatusline not installed (bun install -g ccstatusline)\n' \
      "$TITLE" "$CWD"
  else
    printf '%s | ccstatusline not installed (bun install -g ccstatusline)\n' "$CWD"
  fi
fi
