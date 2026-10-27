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
  StopFailure     Claude turn errored
  Notification    Claude is waiting on you (plays sounds/permission.mp3 for
                  permission prompts, sounds/input.mp3 otherwise)

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

# Skip when invoked from an internal headless child (e.g. the report-judge
# `claude -p` call), so background classification never pops a notification.
[[ -n "${CLAUDE_HEADLESS_CHILD:-}" ]] && exit 0

INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')
ALERTER=/opt/homebrew/bin/alerter
ICON="/Applications/Claude.app/Contents/Resources/electron.icns"
SOUNDS="$HOME/.claude/hooks/sounds"
SOUND_VOLUME=0.5
# macOS system alert sound, played via afplay because alerter has no volume flag
ALERT_SOUND=$(defaults read -g com.apple.sound.beep.sound 2>/dev/null)

# Play a sound in the background without waiting for alerter
# Usage: play_sound <file>
play_sound() {
  [[ -f "$1" ]] && afplay -v "$SOUND_VOLUME" "$1" >/dev/null 2>&1 &
}

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

    play_sound "$ALERT_SOUND"
    notify "$EVENT" "$CWD" \
      --title "Claude Finished" \
      --message "$MSG" \
      --subtitle "${PROJECT:+in $PROJECT}" \
      --close-label "Dismiss" \
      --actions 'View Diff,Commit' \
      --dropdown-label "Next" \
      --app-icon "$ICON" \
      --group "claude-stop" \
      --timeout 15 &
    ;;

  StopFailure)
    ERROR_TYPE=$(echo "$INPUT" | jq -r '.error_type // "unknown error"' | head -c 200 | iconv -c -f UTF-8 -t UTF-8 2>/dev/null)
    play_sound "$ALERT_SOUND"
    notify "$EVENT" "$CWD" \
      --title "Claude Error" \
      --message "Turn failed: $ERROR_TYPE" \
      --subtitle "${PROJECT:+in $PROJECT}" \
      --close-label "Ignore" \
      --app-icon "$ICON" \
      --group "claude-error" \
      --timeout 30 &
    ;;

  Notification)
    case "$(echo "$INPUT" | jq -r '.notification_type // empty')" in
      permission_prompt) play_sound "$SOUNDS/permission.mp3" ;;
      *)                 play_sound "$SOUNDS/input.mp3" ;;
    esac

    TITLE=$(echo "$INPUT" | jq -r '.title // "Claude needs input"' | head -c 100 | iconv -c -f UTF-8 -t UTF-8 2>/dev/null)
    MSG=$(echo "$INPUT" | jq -r '.message // "Waiting for you"' | head -c 200 | iconv -c -f UTF-8 -t UTF-8 2>/dev/null)
    notify "$EVENT" "$CWD" \
      --title "$TITLE" \
      --message "$MSG" \
      --subtitle "${PROJECT:+in $PROJECT}" \
      --close-label "Dismiss" \
      --app-icon "$ICON" \
      --group "claude-input" \
      --timeout 30 &
    ;;
esac
