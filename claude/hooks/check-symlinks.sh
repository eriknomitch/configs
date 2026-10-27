#!/usr/bin/env bash
# Claude Code SessionStart hook: warn when a repo-managed ~/.claude path is
# no longer a symlink into ~/.configs.
#
# The paths come from the "_ensure_symbolic_link claude/..." lines in
# .bin/ensure-symbolic-links, so new links are checked without editing this
# file. Any path that is not a symlink is named in a systemMessage, which
# Claude Code shows to the user. Writes nothing when every path is a symlink,
# and always exits 0.

links_script="$HOME/.configs/.bin/ensure-symbolic-links"
[ -f "$links_script" ] || exit 0

tilde='~'
broken=()
while read -r _ _ destination; do
  destination="${destination/#$tilde/$HOME}"
  [ -L "$destination" ] || broken+=("${destination/#$HOME/$tilde}")
done < <(grep '^_ensure_symbolic_link claude/' "$links_script")

if [ ${#broken[@]} -gt 0 ]; then
  printf '{"systemMessage": "Not symlinked into ~/.configs: %s. Back up and remove, then run .bin/ensure-symbolic-links."}\n' "${broken[*]}"
fi

exit 0
