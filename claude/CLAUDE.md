- Always respond in English.
- Use `git rm` / `git mv` for files tracked by git. Use plain `rm` / `mv` only for untracked files (build artifacts, scratch files, etc.).
- Before running language runtimes (node, python, ruby, etc.) or their package managers, ensure asdf is loaded if installed. Discovery (decoupled from install method):
  1. Confirm `command -v asdf` succeeds — the binary must be on PATH because shims internally call `asdf exec`. If it isn't, locate it (typical paths: `/opt/homebrew/bin/asdf`, `/usr/local/bin/asdf`, `~/.asdf/bin/asdf`) and prepend its directory to PATH.
  2. If `~/.asdf/shims` exists, prepend it to PATH: `export PATH="$HOME/.asdf/shims:$PATH"`.
  Both steps no-op safely if asdf isn't installed. This works across asdf versions (legacy shell-script and 0.16+ Go binary) and install methods (Homebrew, manual), so the project's `.tool-versions` is honored.

# Scheduling offers
- Do not proactively offer to /schedule remote agents, follow-up runs, or any work measured in days or weeks. I do not operate on long-horizon follow-up cycles, so these offers are always noise. Only discuss /schedule when I explicitly bring it up.
- This does NOT restrict short-horizon polling within a session: /loop, Monitor, run_in_background, or babysitting a PR/build/deploy on a minutes-scale interval are fine to use or offer when genuinely useful.
