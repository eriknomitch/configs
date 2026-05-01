#!/usr/bin/env bash
# Claude Code hook → alerter notification dispatcher
# Receives hook JSON on stdin, sends macOS desktop notifications.
# Interactions (action buttons, body click) focus Ghostty; timeouts stay silent.

show_help() {
  cat <<'EOF'
notify.sh — Claude Code hook → macOS notification dispatcher

Reads hook JSON from stdin and sends a native macOS notification via
alerter. Wired up in ~/.claude/settings.json under hooks.

EVENTS HANDLED
  Stop            Claude finished a turn (offers View Diff / Commit)
  StopFailure     Claude turn errored (offers Retry)
  TaskCompleted   Background task finished

INTERACTION
  Action button    Focuses Ghostty; some run side-effects (clipboard)
  Click body       Focuses Ghostty
  Dismiss/timeout  Silent — does not steal focus

USAGE
  -h, --help      Show this help
  (piped JSON)    Read hook payload from stdin

DEPENDENCIES
  alerter (Homebrew tap vjeantet/tap/alerter)
  jq

TEST
  echo '{"hook_event_name":"Stop","cwd":"'"$PWD"'"}' | ~/.claude/hooks/notify.sh
EOF
}

# Show help on explicit flag, or when run interactively (no piped stdin)
case "${1:-}" in
  -h|--help|help) show_help; exit 0 ;;
esac
if [[ -t 0 ]]; then
  show_help
  exit 0
fi

INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')
ALERTER=/opt/homebrew/bin/alerter
ICON="/Applications/Claude Code Menu.app/Contents/Resources/icon.icns"

# Extract project context for subtitle
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
PROJECT="${CWD##*/}"

# Run alerter, then handle the user's response
# Usage: notify <event> <cwd> [alerter flags...]
notify() {
  local event="$1" cwd="$2"
  shift 2

  RESULT=$("$ALERTER" "$@" 2>/dev/null)

  case "$RESULT" in
    @TIMEOUT|@CLOSED) return ;; # user ignored
  esac

  # Event-specific response handling
  case "$event" in
    Stop)
      case "$RESULT" in
        *"View Diff"*)
          if [[ -n "$cwd" && -d "$cwd/.git" ]]; then
            git -C "$cwd" --no-pager diff | pbcopy
            "$ALERTER" --title "Diff Copied" --message "git diff is in your clipboard" \
              --app-icon "$ICON" --group "claude-info" --timeout 5 >/dev/null 2>&1 &
          fi
          ;;
        *"Commit"*)
          printf %s "/commit" | pbcopy
          ;;
      esac
      ;;
  esac

  open -a Ghostty
}

case "$EVENT" in
  Stop)
    TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')
    SUMMARY=""
    if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]]; then
      SUMMARY=$(tail -50 "$TRANSCRIPT" \
        | jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' 2>/dev/null \
        | tail -1 \
        | head -c 200 \
        | iconv -c -f UTF-8 -t UTF-8 2>/dev/null)
    fi
    MSG="${SUMMARY:-Ready for your next prompt}"

    notify "$EVENT" "$CWD" \
      --title "Claude Finished" \
      --message "$MSG" \
      --subtitle "${PROJECT:+in $PROJECT}" \
      --close-label "Dismiss" \
      --actions 'View Diff,Commit' \
      --dropdown-label "Next" \
      --app-icon "$ICON" \
      --group "claude-stop" \
      --sound "default" \
      --timeout 15 &
    ;;

  StopFailure)
    ERROR_TYPE=$(echo "$INPUT" | jq -r '.error_type // "unknown error"' | head -c 200 | iconv -c -f UTF-8 -t UTF-8 2>/dev/null)
    notify "$EVENT" "$CWD" \
      --title "Claude Error" \
      --message "Turn failed: $ERROR_TYPE" \
      --subtitle "${PROJECT:+in $PROJECT}" \
      --close-label "Ignore" \
      --actions "Retry" \
      --app-icon "$ICON" \
      --group "claude-error" \
      --sound "default" \
      --timeout 30 &
    ;;

  TaskCompleted)
    TASK=$(echo "$INPUT" | jq -r '.task_name // .tool_input.name // "A background task"' | head -c 200 | iconv -c -f UTF-8 -t UTF-8 2>/dev/null)
    notify "$EVENT" "$CWD" \
      --title "Task Completed" \
      --message "${TASK} finished" \
      --subtitle "${PROJECT:+in $PROJECT}" \
      --close-label "Dismiss" \
      --app-icon "$ICON" \
      --group "claude-task" \
      --sound "default" \
      --timeout 15 &
    ;;
esac
