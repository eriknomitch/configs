#!/usr/bin/env bash
#
# Announce an invoked skill in the "minimal" style:
#
#   ▶ skill /<name>  <args>
#
# Bold-white marker, green slash-prefixed name, dim args.
# Run in a real terminal (a TTY) to see the colors.
#
#   ./skill-announce.sh [skill-name] [args]

name="${1:-qumis-pr}"
args="${2:-}"

ESC=$'\033'
RESET="${ESC}[0m"
DIM="${ESC}[2m"

printf '%b▶ skill%b %b/%s%b %b%s%b\n' \
  "${ESC}[1;37m" "$RESET" \
  "${ESC}[1;32m" "$name" "$RESET" \
  "$DIM" "${args:+$args}" "$RESET"
