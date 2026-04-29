# AGENTS.md

## Overview
Dotfiles repository for a dwm-based Linux desktop setup. No build, test, or lint toolchain.

## Key Structure
- `dotfiles/`: Tool configs mapped to `$HOME` (e.g., `dotfiles/yazi/.config/yazi/` → `~/.config/yazi/`)
- `bin/`: Install scripts for tools, dotfile deploy logic, utilities
- Root `install.sh`: Orchestrates full system setup (requires non-root user with sudo)

## Critical Commands
- Deploy dotfiles: `./bin/deploy-dotfiles.sh` (backs up existing configs to `~/.config-backup-<timestamp>`)
- Full install: `./install.sh` (do not run as root)
- Single tool install: `./bin/install-<tool>.sh` (e.g., `./bin/install-dwm.sh` clones dwm from `https://github.com/syaofox/dwm.git`, runs `sudo make clean install`)

## OpenCode Config
- Repo-local config: `dotfiles/opencode/.config/opencode/opencode.json` (enables Chrome DevTools MCP, disables formatter/paste summary)
- Custom commands: `dotfiles/opencode/.config/opencode/commands/`
