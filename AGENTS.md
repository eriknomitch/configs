# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles and configuration repository for development tools, shell environment, window management, and home automation. Core philosophy: modular, environment-specific, symlink-based configuration management.

## Commands

### Bootstrap and Setup
```bash
./bootstrap-host              # Initial setup (creates symlinks from ~/.configs to ~/)
.bin/ensure-symbolic-links    # Manually recreate symlinks
resource                      # Reload shell configuration (or: src)
```

Other `.bin/` utilities:
- `.bin/install-asdf-systems` — Install asdf plugin/version stack
- `.bin/generate-grconfig` — Regenerate `grconfig.json`
- `.bin/mac-perf-check` — macOS performance / health diagnostic

### Key Shell Functions
From `/etc/zsh/shared.zsh`:
- `resource` / `src` - Reload zsh configuration
- `command-exists <cmd>` - Check if command is available
- `source-if-exists <file>` - Safely source files
- `extend-path <dir>` - Add directory to PATH

From `zshrc`:
- `secrets <subcommand>` - Manage environment secrets (load, list, add, edit, check)
- `a [args]` - Aider wrapper (use `a h` for help, `a u` to upgrade, `a c` to commit)
- `aider-commit` - Commit with aider then push (LLM-generated message)
- `git-ac` - Interactive staged-commit helper (sourced from `zsh/git-ac.zsh`); skips large files, falls back to non-interactive shells
- `codebase-analysis` - Analyze codebase structure (tree, scc, git stats)
- `br <brew-cmd>` - Homebrew wrapper that auto-updates Brewfile on install/upgrade
- `cld` - Claude Code wrapper
- `ya` - Yazi file manager with directory change on exit

### Navigation
- `cd` is aliased to `z` (zoxide) when available
- `to <bookmark>` / `jump <bookmark>` - Jump to bookmark

### Neovim
```vim
:Lazy          " Open plugin manager
:Lazy sync     " Update plugins
```
Leader key: `\` (backslash)

### Git
```bash
git log-tree              # Pretty graph log with dates
git changed-files <hash>  # List files changed in commit
git changes <hash>        # Show diff for specific commit
```

## Architecture

### Bootstrap System
The `bootstrap-host` script:
1. Runs `.bin/ensure-symbolic-links` to create symlinks
2. Creates `~/.repositories` directory structure
3. Clones helper repositories (`g`, `prwd`)
4. Sets SSH permissions (700 for ~/.ssh, 600 for config)

**Symlink function** (`_ensure_symbolic_link` in `.bin/ensure-symbolic-links`):
- Links from `~/.configs/<file>` → `~/<file>` or system locations
- Handles both user and sudo links (e.g., `/etc/zsh/shared`)
- Neovim gets dual symlinks: `~/.vim` and `~/.config/nvim` both point to `vim/`

### Shell Environment (zsh)

**Loading hierarchy:**
1. `zshrc` (main entry point)
2. `/etc/zsh/shared.zsh` (cross-system utilities)
3. `zshrc-specific-to-os/Darwin.zsh` or `Linux.zsh` (platform-specific)
4. `zshrc-specific-to-host/<hostname>.zsh` (machine-specific, optional)

**Key patterns:**
- `INITIAL_CWD` environment variable forces initial working directory if set
- Secrets loaded from `~/.env` and `~/.secrets` on shell startup

### Neovim Structure

- Entry: `vim/init.lua` (fully Lua-based)
- Plugins: `vim/lua/plugins/` organized by category:
  - `configs/` - Plugin configurations (treesitter, lspconfig, telescope, etc.)
  - `ui/` - Interface and appearance
  - `lsp/` - Language server protocol
  - `git/` - Git integration
  - `coding/` - Code editing enhancements
  - `completion/` - Autocompletion
- Plugin manager: lazy.nvim

**Settings:** Leader `\`, no swap/backup files, persistent undo, line numbers disabled, smart case search

### Hammerspoon (macOS)

- Entry: `hammerspoon/init.lua`
- Local modules: `utility.lua`, `external_display_handler.lua`
- Spoons: `hammerspoon/Spoons/`

**Configuration variables** (top of init.lua):
- `defaultBrowserName` - Primary browser (Arc)
- `defaultTerminalName` - Primary terminal (Ghostty)
- `appsToCenter` - Apps that auto-center on launch
- `enableWindowResizeKeybindings` - Toggle window management hotkeys

**Hotkey prefixes:** `cmd+ctrl` for movement, `cmd+ctrl+shift` for secondary, `cmd+ctrl+alt` for window adjustment

### Git Configuration

- Default branch: `main`
- Auto-setup remote on first push
- Pager: Delta (dark theme) with navigation
- Merge: diff3 conflict style, rerere enabled
- Rebase: auto-stash and auto-squash enabled

### tmux

- Prefix: `Ctrl-n` (not default Ctrl-b)
- `Prefix-r` - Reload configuration
- Default shell: zsh via `reattach-to-user-namespace`

### Claude Code Configuration (`claude/`)

This repo also publishes the user's global Claude Code config to `~/.claude/` via symlinks created by `.bin/ensure-symbolic-links`:

- `claude/CLAUDE.md` → `~/.claude/CLAUDE.md` — global rules loaded for every project
- `claude/settings.json` → `~/.claude/settings.json` — hooks, permissions, status line config
- `claude/hooks/notify.sh` → `~/.claude/hooks/notify.sh` — alerter-based macOS notifications
- `claude/scripts/statusline.sh` → `~/.claude/scripts/statusline.sh` — terminal status line wrapper

Editing files in `claude/` updates the live config (no copy step). `claude/settings.json.backup` is a manual snapshot, not symlinked.

## Modification Patterns

### Adding a New Dotfile
1. Place file in repository root
2. Add to `.bin/ensure-symbolic-links`:
   ```bash
   _ensure_symbolic_link newconfig ~/.newconfig
   ```
3. Run `./bootstrap-host` or `.bin/ensure-symbolic-links`

### Host/OS-Specific Configuration
- Host-specific: Create `zshrc-specific-to-host/<hostname>.zsh`
- OS-specific: Edit `zshrc-specific-to-os/Darwin.zsh` or `Linux.zsh`

### Neovim Plugins
Add to `vim/lua/plugins/<category>/init.lua` using lazy.nvim spec format.

### Hammerspoon
Per-host: Modify config variables at top of `hammerspoon/init.lua`. Cross-host: Edit main logic or create new module files.

# CLAUDE.md — 12-rule template

These rules apply to every task in this project unless explicitly overridden.
Bias: caution over speed on non-trivial work. Use judgment on trivial tasks.

## Rule 1 — Think Before Coding
State assumptions explicitly. If uncertain, ask rather than guess.
Present multiple interpretations when ambiguity exists.
Push back when a simpler approach exists.
Stop when confused. Name what's unclear.

## Rule 2 — Simplicity First
Minimum code that solves the problem. Nothing speculative.
No features beyond what was asked. No abstractions for single-use code.
Test: would a senior engineer say this is overcomplicated? If yes, simplify.

## Rule 3 — Surgical Changes
Touch only what you must. Clean up only your own mess.
Don't "improve" adjacent code, comments, or formatting.
Don't refactor what isn't broken. Match existing style.

## Rule 4 — Goal-Driven Execution
Define success criteria. Loop until verified.
Don't follow steps. Define success and iterate.
Strong success criteria let you loop independently.

## Rule 5 — Use the model only for judgment calls
Use me for: classification, drafting, summarization, extraction.
Do NOT use me for: routing, retries, deterministic transforms.
If code can answer, code answers.

## Rule 6 — Token budgets are not advisory
Per-task: 4,000 tokens. Per-session: 30,000 tokens.
If approaching budget, summarize and start fresh.
Surface the breach. Do not silently overrun.

## Rule 7 — Surface conflicts, don't average them
If two patterns contradict, pick one (more recent / more tested).
Explain why. Flag the other for cleanup.
Don't blend conflicting patterns.

## Rule 8 — Read before you write
Before adding code, read exports, immediate callers, shared utilities.
"Looks orthogonal" is dangerous. If unsure why code is structured a way, ask.

## Rule 9 — Tests verify intent, not just behavior
Tests must encode WHY behavior matters, not just WHAT it does.
A test that can't fail when business logic changes is wrong.

## Rule 10 — Checkpoint after every significant step
Summarize what was done, what's verified, what's left.
Don't continue from a state you can't describe back.
If you lose track, stop and restate.

## Rule 11 — Match the codebase's conventions, even if you disagree
Conformance > taste inside the codebase.
If you genuinely think a convention is harmful, surface it. Don't fork silently.

## Rule 12 — Fail loud
"Completed" is wrong if anything was skipped silently.
"Tests pass" is wrong if any were skipped.
Default to surfacing uncertainty, not hiding it.
