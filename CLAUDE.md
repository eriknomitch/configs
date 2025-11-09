# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles and configuration repository for development tools, shell environment, window management, and home automation. Core philosophy: modular, environment-specific, symlink-based configuration management.

## Commands

### Bootstrap and Setup
```bash
# Initial setup (creates symlinks from ~/.configs to ~/)
./bootstrap-host

# Manually recreate symlinks if needed
.bin/ensure-symbolic-links

# Reload shell configuration
resource  # or: src
```

### Key Shell Functions
Available globally via `/etc/zsh/shared.zsh`:
- `resource` / `src` - Reload zsh configuration
- `command-exists <cmd>` - Check if command is available
- `source-if-exists <file>` - Safely source files
- `extend-path <dir>` - Add directory to PATH

### Neovim
```bash
# Plugin management (inside Neovim)
:Lazy          # Open plugin manager
:Lazy sync     # Update plugins
```

Leader key: `\` (backslash)

### Git Workflow
```bash
# Custom aliases (from gitconfig)
git log-tree              # Pretty graph log with dates
git changed-files <hash>  # List files changed in commit
git changes <hash>        # Show diff for specific commit
```

## Architecture

### Bootstrap System
The `bootstrap-host` script orchestrates initial setup:
1. Runs `.bin/ensure-symbolic-links` to create symlinks
2. Creates `~/.repositories` directory structure
3. Clones helper repositories (`g`, `prwd`)
4. Sets SSH permissions (700 for ~/.ssh, 600 for config)

**Critical:** The `_ensure_symbolic_link` function in `.bin/ensure-symbolic-links`:
- Links from `~/.configs/<file>` → `~/<file>` or system locations
- Handles both user and sudo links (e.g., `/etc/zsh/shared`)
- Creates symlinks for: zshrc, vimrc, gitconfig, tmux.conf, and application configs
- Neovim gets dual symlinks: `~/.vim` and `~/.config/nvim` both point to `vim/`

### Shell Environment (zsh)

**Loading hierarchy:**
1. `zshrc` (main entry point)
2. `/etc/zsh/shared.zsh` (cross-system utilities and aliases)
3. `zshrc-specific-to-os/Darwin.zsh` or `Linux.zsh` (platform-specific)
4. `zshrc-specific-to-host/<hostname>.zsh` (machine-specific)

**Key patterns:**
- Host-specific configs are optional; use for machine-dependent settings
- OS-specific configs handle platform differences (macOS vs Linux)
- The `INITIAL_CWD` environment variable forces initial working directory if set
- History is shared across sessions with deduplication

### Neovim Structure

**Architecture:**
- Entry: `vim/init.lua` (NOT init.vim - fully Lua-based)
- Configuration: `vim/lua/core/` (options, keymaps, autocommands)
- Plugins: `vim/lua/plugins/` organized by category:
  - `configs/` - General configuration plugins
  - `ui/` - Interface and appearance
  - `lsp/` - Language server protocol
  - `git/` - Git integration
  - `coding/` - Code editing enhancements
  - `completion/` - Autocompletion
- Plugin manager: lazy.nvim (`vim/lua/plugins/init.lua`)

**Key settings (from init.lua:1-50):**
- Leader: `\` (set before plugin loads)
- No swap/backup files, persistent undo enabled
- Line numbers disabled by default
- Smart search with case sensitivity

### Hammerspoon (macOS)

**Structure (from init.lua):**
- Entry: `hammerspoon/init.lua`
- Local modules: `utility.lua`, `external_display_handler.lua`
- Third-party: `hammerspoon/Spoons/` directory

**Configuration variables (customizable per-host):**
- `enableWindowResizeKeybindings` - Toggle window management hotkeys
- `appsToCenter` - Apps that auto-center on launch (Finder, Messages, etc.)
- `defaultBrowserName` - Primary browser (currently "Arc")
- `defaultTerminalName` - Primary terminal (currently "iTerm")
- `secondaryBrowserName` - Fallback browser

**External display handling:**
- Automatically triggered on display connection/disconnection
- Custom layout configurations per display

### Git Configuration

**Notable settings (gitconfig:1-60):**
- Default branch: `main`
- Auto-setup remote on first push
- Pager: Delta (dark theme) with navigation
- Merge: diff3 conflict style, rerere enabled
- Rebase: auto-stash and auto-squash enabled
- LFS filter configured

### tmux

**Key bindings:**
- Prefix: `Ctrl-n` (not the default Ctrl-b)
- `Prefix-r` - Reload configuration
- Mouse mode enabled
- Default shell: zsh via `reattach-to-user-namespace`

### SSH Configuration

Structure: `ssh/config` (single file, no includes)
**Important:** Bootstrap sets permissions automatically (700/600)

## Modification Patterns

### Adding a New Dotfile
1. Place file in repository root (e.g., `newconfig`)
2. Add symlink creation to `.bin/ensure-symbolic-links`:
   ```bash
   _ensure_symbolic_link newconfig ~/.newconfig
   ```
3. Run `./bootstrap-host` or `.bin/ensure-symbolic-links`

### Host-Specific Configuration
Create `zshrc-specific-to-host/<hostname>.zsh` with machine-specific settings. This file is automatically sourced if it exists.

### OS-Specific Configuration
Edit `zshrc-specific-to-os/Darwin.zsh` (macOS) or `Linux.zsh`. These are automatically sourced based on platform.

### Neovim Plugin Configuration
Add plugin specifications to appropriate module in `vim/lua/plugins/`:
- LSP configs → `lsp/`
- UI/themes → `ui/`
- Code editing → `coding/`

Follow lazy.nvim spec format. Changes are auto-detected on save.

### Hammerspoon Modifications
For per-host changes, modify the configuration variables at the top of `hammerspoon/init.lua` (lines 9-49). For cross-host changes, edit the main logic or create new module files and require them.
