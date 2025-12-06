# Ghostty color functions
# Similar to iTerm2 tab colors, but uses OSC 11 (background color)
# Note: This changes the entire window background, not just the tab

# Set the window background color
ghostty-bg-color() {
    # Takes 1 hex string argument or 3 decimal RGB values
    local R G B
    case "$#" in
        3)
            R="$1"
            G="$2"
            B="$3"
            ;;
        1)
            local hex="$1"
            # Remove leading # if present
            if [[ "${hex:0:1}" == "#" ]]; then
                hex="${hex:1}"
            fi
            # Get hex values for each channel and convert to decimal
            R="$((16#${hex:0:2}))"
            G="$((16#${hex:2:2}))"
            B="$((16#${hex:4}))"
            ;;
        *)
            echo "Usage: ghostty-bg-color color_hex"
            echo "          color_hex: 6 digit hex value (e.g. 1B2B34)"
            echo "       ghostty-bg-color r_val g_val b_val"
            echo "          *_val: values for R, G, B from 0-255 (e.g. 27 43 52)"
            return
            ;;
    esac

    # Convert to 16-bit hex for OSC 11
    # OSC 11 expects format: rgb:RRRR/GGGG/BBBB
    local R16=$(printf "%04x" $((R * 257)))
    local G16=$(printf "%04x" $((G * 257)))
    local B16=$(printf "%04x" $((B * 257)))

    # Send OSC 11 to change background color
    echo -ne "\033]11;rgb:${R16}/${G16}/${B16}\007"

    # Export environment variable to maintain colors during session
    export GHOSTTY_SESSION_COLOR="$R $G $B"
}

# Reset background color to default
ghostty-bg-reset() {
    # Query the default background color from config or reset to terminal default
    # This might not restore the exact config color, but resets to terminal defaults
    echo -ne "\033]111\007"
    unset GHOSTTY_SESSION_COLOR
}

# Example: Color code SSH sessions
# Uncomment and customize as needed
# color-ssh() {
#     if [[ -n "$GHOSTTY_RESOURCES_DIR" ]] || command -v ghostty &> /dev/null; then
#         trap "ghostty-bg-reset" INT EXIT
#         if [[ "$*" =~ "production|prod" ]]; then
#             ghostty-bg-color 40 0 0  # Dark red for production
#         elif [[ "$*" =~ "staging|stg" ]]; then
#             ghostty-bg-color 40 30 0  # Dark orange for staging
#         else
#             ghostty-bg-color 0 30 0  # Dark green for dev
#         fi
#     fi
#     command ssh "$@"
# }
# alias ssh="color-ssh"

# Restore session background color if set
if [ -n "$GHOSTTY_SESSION_COLOR" ]; then
    ghostty-bg-color $GHOSTTY_SESSION_COLOR
fi
