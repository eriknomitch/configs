#!/bin/bash
# notify.sh - macOS desktop notification utility using terminal-notifier
# Usage: notify.sh [options] [message]
#   -t, --title      Notification title (default: "Claude Code")
#   -s, --subtitle   Notification subtitle
#   -m, --message    Notification message
#   -S, --sound      Sound name (e.g., "default", "Ping")
#   -g, --group      Group ID for notification management

title="Claude Code"
subtitle=""
message=""
sound=""
group=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--title)
            title="$2"
            shift 2
            ;;
        -s|--subtitle)
            subtitle="$2"
            shift 2
            ;;
        -m|--message)
            message="$2"
            shift 2
            ;;
        -S|--sound)
            sound="$2"
            shift 2
            ;;
        -g|--group)
            group="$2"
            shift 2
            ;;
        -*)
            shift
            ;;
        *)
            # Positional argument treated as message if not set
            [[ -z "$message" ]] && message="$1"
            shift
            ;;
    esac
done

# Exit if no message
[[ -z "$message" ]] && exit 0

# Build terminal-notifier command
cmd=(terminal-notifier -title "$title" -message "$message")

[[ -n "$subtitle" ]] && cmd+=(-subtitle "$subtitle")
[[ -n "$sound" ]] && cmd+=(-sound "$sound")
[[ -n "$group" ]] && cmd+=(-group "$group")

# Run in background for non-blocking behavior
"${cmd[@]}" &>/dev/null &

exit 0
