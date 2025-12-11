#!/bin/bash
# play-sound.sh - Non-blocking audio playback utility
# Usage: play-sound.sh [options] <sound>
#   sound: Path to audio file OR shortcut name (finished, input)
#   -v, --volume   Volume level 0-100 (default: 50)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIO_DIR="$SCRIPT_DIR/../audio"

volume=50
sound=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--volume)
            volume="$2"
            shift 2
            ;;
        -*)
            shift
            ;;
        *)
            [[ -z "$sound" ]] && sound="$1"
            shift
            ;;
    esac
done

[[ -z "$sound" ]] && exit 0

# Resolve shortcuts to full paths
case "$sound" in
    finished|input|needs-input|needs-permission)
        sound="$AUDIO_DIR/${sound}.mp3"
        ;;
esac

# Convert volume to afplay scale (0.0-1.0)
afplay_vol=$(awk "BEGIN {printf \"%.2f\", $volume / 100}")

# Play sound in background if file exists
[[ -f "$sound" ]] && afplay -v "$afplay_vol" "$sound" &>/dev/null &

exit 0
