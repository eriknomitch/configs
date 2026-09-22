#!/usr/bin/env bash
# Claude Code SessionStart hook: put asdf on PATH for the session.
#
# Shims call "asdf exec", so the asdf binary's own directory must be on PATH
# in addition to the shims directory. A hook cannot mutate the parent
# process's environment, so the resulting PATH is written as an export line
# to the file named by $CLAUDE_ENV_FILE, which Claude Code sources after the
# hook exits.
#
# Writes nothing to stdout (SessionStart stdout is injected as session
# context) and always exits 0, including when asdf is not installed.

for dir in /opt/homebrew/bin /usr/local/bin "$HOME/.asdf/bin"; do
  if [ -x "$dir/asdf" ]; then
    PATH="$dir:$PATH"
    break
  fi
done

if [ -d "$HOME/.asdf/shims" ]; then
  PATH="$HOME/.asdf/shims:$PATH"
fi

if [ -n "$CLAUDE_ENV_FILE" ]; then
  printf 'export PATH="%s"\n' "$PATH" >> "$CLAUDE_ENV_FILE"
fi

exit 0
