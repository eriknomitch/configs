# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal configuration repository containing dotfiles and configuration files for various tools and applications. The repository includes configuration for:

- **Shell environment**: zsh configuration with custom functions, aliases, and host-specific settings
- **Development tools**: Neovim (Lua-based), Hammerspoon, tmux, git, and other CLI tools
- **GUI applications**: Alacritty terminal, Karabiner Elements, various themes
- **Home automation**: Home Assistant configuration with custom components
- **System management**: Ansible playbooks, system scripts, and bootstrap utilities

## Commands

### Initial Setup
```bash
# Clone and bootstrap the configuration
git clone git@github.com:eriknomitch/configs.git ~/.configs
cd ~/.configs
./bootstrap-host
```

### Development Workflow
```bash
# The bootstrap script handles:
# - Creating symbolic links for dotfiles
# - Setting up repositories in ~/.repositories
# - Configuring SSH permissions
# - Installing additional repositories (g, prwd)
```

## Architecture

### Configuration Structure
- **Main dotfiles**: Located in repository root (zshrc, gitconfig, tmux.conf, etc.)
- **Host-specific configs**: `zshrc-specific-to-host/` directory contains per-machine customizations
- **OS-specific configs**: `zshrc-specific-to-os/` directory contains platform-specific settings
- **Application configs**: Organized in subdirectories by application name

### Key Components

#### Shell Environment (zsh)
- **Main config**: `zshrc` sources shared configuration and host-specific files
- **Shared utilities**: `/etc/zsh/shared.zsh` contains common functions
- **Host customization**: Machine-specific configurations in `zshrc-specific-to-host/`
- **OS customization**: Platform-specific settings in `zshrc-specific-to-os/`

#### Neovim Configuration
- **Modern Lua setup**: `vim/init.lua` is the main entry point
- **Modular structure**: Configuration split into `lua/core/`, `lua/plugins/` modules
- **Plugin management**: Uses lazy.nvim for plugin management
- **Leader key**: Set to backslash (`\`)

#### Hammerspoon (macOS automation)
- **Main config**: `hammerspoon/init.lua` with modular requires
- **Spoons**: Custom and third-party Spoons in `hammerspoon/Spoons/`
- **Window management**: Configurable window resize keybindings
- **External display handling**: Automatic configuration for external monitors

#### Home Assistant
- **Full configuration**: Complete Home Assistant setup in `homeassistant/`
- **Custom components**: HACS, browser_mod, UI Lovelace Minimalist
- **Themes**: Multiple UI themes in `homeassistant/themes/`
- **Automation**: Blueprints and custom automations

### Configuration Patterns
- **Symbolic linking**: The bootstrap script creates symlinks from home directory to repository files
- **Modular organization**: Large configurations are split into logical modules
- **Environment-specific**: Host and OS-specific configurations are isolated
- **Version controlled**: All configurations are tracked in git for easy synchronization

## Development Notes

### File Modifications
When modifying configurations:
- Test changes on a single host before committing
- Use host-specific files for machine-dependent settings
- Maintain backwards compatibility when possible

### Adding New Configurations
- Place new dotfiles in repository root
- Add symbolic link creation to bootstrap script if needed
- Consider if host-specific variants are needed

### Neovim Plugin Development
- Add new plugins to appropriate module in `lua/plugins/`
- Follow existing patterns for plugin configuration
- Test with `:Lazy` command for plugin management