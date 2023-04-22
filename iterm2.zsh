# https://gist.github.com/wadey/1140259

# Usage:
# source iterm2.zsh

# iTerm2 window/tab color commands
#   Requires iTerm2 >= Build 1.0.0.20110804
#   http://code.google.com/p/iterm2/wiki/ProprietaryEscapeCodes
tab-color() {
    echo -ne "\033]6;1;bg;red;brightness;$1\a"
    echo -ne "\033]6;1;bg;green;brightness;$2\a"
    echo -ne "\033]6;1;bg;blue;brightness;$3\a"
}
tab-reset() {
    echo -ne "\033]6;1;bg;*;default\a"
    trap - INT EXIT
}

# # Change the color of the tab when using SSH
# # reset the color after the connection closes
# color-ssh() {
#     if [[ -n "$ITERM_SESSION_ID" ]]; then
#         trap "tab-reset" INT EXIT
#         if [[ "$*" =~ "production|ec2-.*compute-1" ]]; then
#             tab-color 255 0 0
#         else
#             tab-color 0 255 0
#         fi
#     fi
#     ssh $*
# }
# compdef _ssh color-ssh=ssh

# alias ssh="color-ssh"

# # Default tab color
tab-color 255 255 255
tab-color 0 0 0


# ================================================================
# iTerm2 tab color functions
#
# Author: Connor de la Cruz (connor.c.delacruz@gmail.com)
# Repo: https://github.com/connordelacruz/iterm2-tab-color
# ================================================================

# Set the tab color
it2-tab-color() {
    # takes 1 hex string argument or 3 hex values for RGB
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
            echo "Usage: it2-tab-color color_hex"
            echo "          color_hex: 6 digit hex value (e.g. 1B2B34)"
            echo "       it2-tab-color r_val g_val b_val"
            echo "          *_val: values for R, G, B from 0-255 (e.g. 27 43 52)"
            return
            ;;
    esac
    echo -ne "\033]6;1;bg;red;brightness;$R\a"
    echo -ne "\033]6;1;bg;green;brightness;$G\a"
    echo -ne "\033]6;1;bg;blue;brightness;$B\a"
    # Export environment variable to maintain colors during session
    export IT2_SESSION_COLOR="$R $G $B"
}

# Reset tab color to default
it2-tab-reset() {
    echo -ne "\033]6;1;bg;*;default\a"
    # Unset environment variable
    unset IT2_SESSION_COLOR
}

# Check for ~/.base16_theme and set the tab color based on that
it2-b16-theme() {
    if [ -f "$HOME/.base16_theme" ]; then
        local colornum color
        # If no argument was passed, default to color00
        if [ "$#" -lt 1 ]; then
            colornum="00"
        else
            colornum="$1"
        fi
        color="$(perl -nle "print \$& if m{color$colornum=\"\K.*(?=\")}" "$HOME/.base16_theme")"
        it2-tab-color ${color///}
    fi
}

# Restore session tab color
if [ -n "$IT2_SESSION_COLOR" ]; then
    it2-tab-color $IT2_SESSION_COLOR
fi


# ------------------------------------------------
