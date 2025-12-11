#!/bin/bash
SCRIPT_DIR="$(dirname "$0")"
input=$(cat)

# Try to extract message from Notification hook or question from AskUserQuestion
message=$(echo "$input" | jq -r '.message // empty' 2>/dev/null)
if [[ -z "$message" ]]; then
    # Try AskUserQuestion format - get first question
    message=$(echo "$input" | jq -r '.tool_input.questions[0].question // empty' 2>/dev/null)
fi
[[ -z "$message" ]] && message="Input needed"

"$SCRIPT_DIR/util/play-sound.sh" needs-input
"$SCRIPT_DIR/util/notify.sh" -t "Input Needed" -m "$message"
