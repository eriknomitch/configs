#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
input=$(cat)

# Extract message from JSON (e.g., "Claude needs permission to use Bash")
message=$(echo "$input" | jq -r '.message // empty' 2>/dev/null)
[[ -z "$message" ]] && message="Permission required"

"$SCRIPT_DIR/util/play-sound.sh" needs-permission
"$SCRIPT_DIR/util/notify.sh" -t "Permission" -m "$message"
