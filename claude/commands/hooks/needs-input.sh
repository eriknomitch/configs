#!/bin/bash
input=$(cat)
type=$(echo "$input" | jq -r '.notification_type // empty')
[[ "$type" == "permission_prompt" ]] && exit 0
"$(dirname "$0")/util/play-sound.sh" needs-input
