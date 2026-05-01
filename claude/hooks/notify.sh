#!/usr/bin/env bash
# Claude Code hook → alerter notification dispatcher
# Receives hook JSON on stdin, sends macOS desktop notifications.
# Clicking a notification focuses Ghostty. Action buttons trigger useful commands.

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
          echo "/commit" | pbcopy
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
        | head -c 200)
    fi
    MSG="${SUMMARY:-Ready for your next prompt}"

    notify "$EVENT" "$CWD" \
      --title "Claude Finished" \
      --message "$MSG" \
      --subtitle "${PROJECT:+in $PROJECT}" \
      --close-label "Dismiss" \
      --actions '"View Diff","Commit"' \
      --dropdown-label "Next" \
      --app-icon "$ICON" \
      --group "claude-stop" \
      --sound "default" \
      --timeout 15 &
    ;;

  StopFailure)
    ERROR_TYPE=$(echo "$INPUT" | jq -r '.error_type // "unknown error"' | head -c 200)
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

  Notification)
    notify "$EVENT" "$CWD" \
      --title "Claude is Waiting" \
      --message "Idle — waiting for your input" \
      --subtitle "${PROJECT:+in $PROJECT}" \
      --close-label "OK" \
      --app-icon "$ICON" \
      --group "claude-idle" \
      --sound "default" \
      --timeout 20 &
    ;;

  TaskCompleted)
    TASK=$(echo "$INPUT" | jq -r '.task_name // .tool_input.name // "A background task"' | head -c 200)
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
