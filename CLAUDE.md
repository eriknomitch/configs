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

### Key Shell Functions
From `/etc/zsh/shared.zsh`:
- `resource` / `src` - Reload zsh configuration
- `command-exists <cmd>` - Check if command is available
- `source-if-exists <file>` - Safely source files
- `extend-path <dir>` - Add directory to PATH

From `zshrc`:
- `secrets <subcommand>` - Manage environment secrets (load, list, add, edit, check)
- `a [args]` - Aider wrapper (use `a h` for help, `a u` to upgrade, `a c` to commit)
- `aider-commit` / `ac` - Commit with aider then push
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
