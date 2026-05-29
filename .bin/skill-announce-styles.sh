#!/usr/bin/env bash
#
# Demo: 5 visual styles for a "skill invoked" announcement.
# Run this in a real terminal (a TTY) to see the colors — they won't
# render if the output is piped or captured.
#
#   chmod +x skill-announce-styles.sh
#   ./skill-announce-styles.sh [skill-name] [args]
#
# Each style is a standalone function taking (name, args). Pick the one
# you like, copy its body into ~/.claude/hooks/announce-skill.sh, and
# read `name`/`args` from stdin via jq as in the real hook.

name="${1:-qumis-pr}"
args="${2:-production staging}"

# --- shared escape helpers -------------------------------------------------
ESC=$'\033'
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
DIM="${ESC}[2m"
ITAL="${ESC}[3m"

# --- style 1: minimal arrow (the original) ---------------------------------
style_minimal() {
  printf '%b▶ skill%b %b%s%b %b%s%b\n' \
    "${ESC}[1;36m" "$RESET" "${ESC}[1;32m" "$1" "$RESET" \
    "$DIM" "${2:+$2}" "$RESET"
}

# --- style 2: inverse badge ------------------------------------------------
# A filled " SKILL " chip on a magenta background, then the name.
style_badge() {
  printf '%b SKILL %b %b%s%b %b%s%b\n' \
    "${ESC}[1;45;97m" "$RESET" \
    "$BOLD" "$1" "$RESET" \
    "$DIM$ITAL" "${2:+— $2}" "$RESET"
}

# --- style 3: rounded box --------------------------------------------------
# Draws a little frame. Width adapts to the content length.
style_box() {
  local label="  ⚙  skill: $1${2:+ — $2}  "
  local w=${#label}
  local line
  line=$(printf '─%.0s' $(seq 1 "$w"))
  printf '%b╭%s╮%b\n'  "${ESC}[36m" "$line" "$RESET"
  printf '%b│%b%b%s%b%b│%b\n' \
    "${ESC}[36m" "$RESET" "${ESC}[1;36m" "$label" "$RESET" "${ESC}[36m" "$RESET"
  printf '%b╰%s╯%b\n'  "${ESC}[36m" "$line" "$RESET"
}

# --- style 4: chevron segments (no nerd-font needed) -----------------------
# Two colored blocks separated by a solid triangle, terminal-safe.
style_chevron() {
  printf '%b ▶ SKILL %b%b%b %b %s %b%b%b %b%s%b\n' \
    "${ESC}[30;46m"  "${ESC}[0m"   `# cyan block "SKILL"` \
    "${ESC}[36m" "▶${RESET}"       `# cyan triangle into...` \
    "${ESC}[1;37;44m" "$1"         `# ...blue block with name` \
    "${ESC}[0m" "${ESC}[34m▶${RESET}" "" \
    "$DIM" "${2:+$2}" "$RESET"      `# trailing dim args`
}

# --- style 5: status line with dim subtitle --------------------------------
# Bright marker + name, args shown muted, trailing "running…" hint.
style_status() {
  printf '%b✦%b %b%s%b  %b%s%b  %brunning…%b\n' \
    "${ESC}[1;33m" "$RESET" \
    "${ESC}[1;37m" "$1" "$RESET" \
    "$DIM" "${2:+($2)}" "$RESET" \
    "$DIM$ITAL" "$RESET"
}

# --- style 6: bracket tag --------------------------------------------------
# Terse, log-friendly: [skill] name · args. Reads well even without color.
style_bracket() {
  printf '%b[%bskill%b]%b %b%s%b %b%s%b\n' \
    "${ESC}[2;37m" "${ESC}[1;36m" "${ESC}[2;37m" "$RESET" \
    "${ESC}[1m" "$1" "$RESET" \
    "$DIM" "${2:+· $2}" "$RESET"
}

# --- style 7: double-line box ----------------------------------------------
# Heavier framed variant of the box, useful when you want it to really pop.
style_double_box() {
  local label="  ▸ $1${2:+ — $2}  "
  local w=${#label}
  local line
  line=$(printf '═%.0s' $(seq 1 "$w"))
  printf '%b╔%s╗%b\n'  "${ESC}[35m" "$line" "$RESET"
  printf '%b║%b%b%s%b%b║%b\n' \
    "${ESC}[35m" "$RESET" "${ESC}[1;35m" "$label" "$RESET" "${ESC}[35m" "$RESET"
  printf '%b╚%s╝%b\n'  "${ESC}[35m" "$line" "$RESET"
}

# --- style 8: traffic-light dots -------------------------------------------
# Three colored dots as a "now running" indicator, then the name.
style_dots() {
  printf '%b●%b%b●%b%b●%b %bskill%b %b%s%b %b%s%b\n' \
    "${ESC}[32m" "$RESET" "${ESC}[33m" "$RESET" "${ESC}[31m" "$RESET" \
    "$DIM" "$RESET" \
    "${ESC}[1;37m" "$1" "$RESET" \
    "$DIM$ITAL" "${2:+$2}" "$RESET"
}

# --- style 9: shell-prompt style -------------------------------------------
# Mimics a command being run: a green prompt glyph + name + arrow + args.
style_prompt() {
  printf '%b❯%b %bskill%b %b%s%b %b→%b %b%s%b\n' \
    "${ESC}[1;32m" "$RESET" \
    "$DIM" "$RESET" \
    "${ESC}[1;36m" "$1" "$RESET" \
    "${ESC}[2;37m" "$RESET" \
    "$ITAL" "${2:-—}" "$RESET"
}

# --- style 10: pill / lozenge ----------------------------------------------
# Rounded background "pill" using half-circle block ends; very chip-like.
style_pill() {
  printf '%b%b%b SKILL %b%b%b %b%s%b %b%s%b\n' \
    "${ESC}[38;5;42m" "" "${ESC}[30;48;5;42m" \
    "${ESC}[38;5;42m" "" "$RESET" \
    "${ESC}[1;37m" "$1" "$RESET" \
    "$DIM" "${2:+$2}" "$RESET"
}

# --- style 11: full-width banner -------------------------------------------
# A solid background bar spanning a fixed width, name left-aligned.
style_banner() {
  local text="  ⚙ SKILL · $1${2:+  ($2)}"
  local pad=$(( 48 - ${#text} ))
  (( pad < 1 )) && pad=1
  printf '%b%s%*s%b\n' \
    "${ESC}[1;30;44m" "$text" "$pad" "" "$RESET"
}

# --- style 12: tree branch -------------------------------------------------
# Looks like a node in a tree/log, good for nested/sequential output.
style_tree() {
  printf '%b└─%b %b●%b %bskill%b %b%s%b %b%s%b\n' \
    "${ESC}[2;37m" "$RESET" \
    "${ESC}[1;34m" "$RESET" \
    "${ESC}[2;37m" "$RESET" \
    "${ESC}[1;37m" "$1" "$RESET" \
    "$DIM$ITAL" "${2:+— $2}" "$RESET"
}

# --- style 13: log line with level -----------------------------------------
# Structured-log feel: a colored level tag then key=value-ish content.
style_log() {
  printf '%b SKILL %b %bname=%b%b%s%b %bargs=%b%b%s%b\n' \
    "${ESC}[30;42m" "$RESET" \
    "$DIM" "$RESET" "${ESC}[1;32m" "$1" "$RESET" \
    "$DIM" "$RESET" "$ITAL" "${2:-∅}" "$RESET"
}

# --- style 14: arrow trail -------------------------------------------------
# A sequence of fading arrows leading into the name; conveys "entering".
style_arrows() {
  printf '%b»%b%b»%b%b»%b %b%s%b %b%s%b\n' \
    "${ESC}[38;5;240m" "$RESET" \
    "${ESC}[38;5;245m" "$RESET" \
    "${ESC}[38;5;250m" "$RESET" \
    "${ESC}[1;36m" "$1" "$RESET" \
    "$DIM" "${2:+$2}" "$RESET"
}

# --- style 15: centered rules ----------------------------------------------
# Name flanked by horizontal rules, centered-divider look.
style_rules() {
  printf '%b───┤%b %b⚙ %s%b %b├───%b %b%s%b\n' \
    "${ESC}[36m" "$RESET" \
    "${ESC}[1;36m" "$1" "$RESET" \
    "${ESC}[36m" "$RESET" \
    "$DIM$ITAL" "${2:+$2}" "$RESET"
}

# --- render all styles -----------------------------------------------------
divider() { printf '%b%s%b\n' "$DIM" "  ── $1 ──────────────────────────────" "$RESET"; }

printf '\n'
divider "1. minimal";     style_minimal    "$name" "$args";     printf '\n'
divider "2. badge";       style_badge      "$name" "$args";     printf '\n'
divider "3. box";         style_box        "$name" "$args";     printf '\n'
divider "4. chevron";     style_chevron    "$name" "$args";     printf '\n'
divider "5. status";      style_status     "$name" "$args";     printf '\n'
divider "6. bracket";     style_bracket    "$name" "$args";     printf '\n'
divider "7. double-box";  style_double_box "$name" "$args";     printf '\n'
divider "8. dots";        style_dots       "$name" "$args";     printf '\n'
divider "9. prompt";      style_prompt     "$name" "$args";     printf '\n'
divider "10. pill";       style_pill       "$name" "$args";     printf '\n'
divider "11. banner";     style_banner     "$name" "$args";     printf '\n'
divider "12. tree";       style_tree       "$name" "$args";     printf '\n'
divider "13. log";        style_log        "$name" "$args";     printf '\n'
divider "14. arrows";     style_arrows     "$name" "$args";     printf '\n'
divider "15. rules";      style_rules      "$name" "$args";     printf '\n'
