# AGENTS.md

This file provides guidance to Coding agents like Claude when working with code in this repository.

## Repository Overview

This is a dotfiles repository for an Arch Linux system running Hyprland (Wayland compositor). It contains configuration files for:

- **Hyprland** - Wayland compositor (`.config/hypr/`)
- **Kitty** - Terminal emulator (`.config/kitty/`)
- **Neovim** - Based on kickstart.nvim, single-file config (`.config/nvim/init.lua`)
- **Zsh** - Shell with vi mode enabled (`.zshrc`, `.config/zsh_aliases`)
- **Tmux** - Terminal multiplexer (`.config/tmux/`)
- **Waybar** - Status bar (`.config/waybar/`)
- **Rofi** - Application launcher (`.config/rofi/`)
- **Starship** - Shell prompt (`.config/starship.toml`)

## Key Dependencies

Required packages for full functionality:
- `fzf` - Fuzzy finder (required for shell)
- `eza` - Modern ls replacement (required for shell aliases)
- `starship` - Shell prompt
- `ttf-nerd-fonts-symbols` - Icons for waybar

## Hyprland Configuration Structure

The main config (`hyprland.conf`) sources additional files:
- `envs.conf` - Environment variables
- `monitors.conf` - Monitor configuration (user-specific, not in repo)
- `workspaces.conf` - Workspace rules (user-specific, not in repo)
- `extra.conf` - Additional customizations (user-specific, not in repo)

Key bindings use `SUPER` as the main modifier with vim-style navigation (h/j/k/l).

## Shell Aliases

Defined in `.config/zsh_aliases`. Notable conventions:
- `n` or `n <file>` - Opens neovim
- `pac*` prefix - Pacman operations (paci, pacs, pacu, pacr, etc.)
- `dock*` prefix - Docker operations
- `g*` prefix - Git operations (gs, ga, gp, gc, gd, etc.)
- `tmux*` prefix - Tmux session management
