# AGENTS.md

## Project overview

Deploy a DWM desktop environment on Linux Mint 22.3 (Ubuntu 24.04 LTS). The repo is a collection of shell install scripts, dotfiles, and admin tools — no build system, no tests, no CI.

## Entry points

- **`install.sh`** — main orchestrator. Runs all `bin/install-*.sh` in sequence, prompting retry/skip/exit on each failure.
- **`tools/config-manager.sh`** — interactive backup/restore for SSH, GPG, dconf, fcitx5 configs. Accepts `backup` or `restore` subcommand.
- **`sbin/*.sh`** — standalone admin scripts (zram, btrfs subvolumes). Run separately, not part of `install.sh`.

## Do NOT run as root

- `install.sh` refuses root and must run as a regular user with sudo.
- `tools/config-manager.sh` refuses root.
- `sbin/zram.sh` and `sbin/btrfs-select.sh` **require** root/sudo.

## Architecture

```
bin/        Install scripts, one per component. Source bin/utils.sh for logging + helpers.
dotfiles/   Config files organized as `dotfiles/<app>/<path-from-HOME>`. Deployed by `bin/deploy-dotfiles.sh`.
tools/      config-manager.sh (fzf-based backup/restore)
sbin/       System admin scripts (sudo required, run independently)
res/        Font archives (JetBrainsMono, UbuntuMono)
backups/    Output directory for config-manager.sh backups
```

## How dotfiles are deployed

`bin/deploy-dotfiles.sh` **copies** (not symlinks) files from `dotfiles/` into `$HOME`. It walks each subdirectory and uses `find` to replicate the internal path structure under `$HOME`. Existing files are backed up to `~/.config-backup-<timestamp>/`.

Key implication: **editing files in the repo does NOT affect the live system** — you must re-run `deploy-dotfiles.sh` or manually copy.

## DWM / slstatus / slock

These are compiled from personal forks under `github.com/syaofox/*`:
- `dwm` → `https://github.com/syaofox/dwm.git`
- `slstatus` → `https://github.com/syaofox/slstatus.git`
- `slock` → `https://github.com/syaofox/slock.git`

The `compile_and_install()` helper in `bin/utils.sh` clones into `/tmp/<name>`, runs `git pull` if the directory already exists, then `sudo make clean install`. These repos must be accessible.

## Theme system

Themes are Xresources files in `~/.Xresources.d/`. The active theme name is stored in `~/.config/theme`.

`dotfiles/scripts/.local/bin/switch-theme.sh` handles switching. It runs `generate-app-themes.py` (which must exist in `~/.local/bin/`) to generate configs for rofi, wezterm, dunst, and xsettingsd from the Xresources theme file.

## DWM session startup flow

1. `/usr/share/xsessions/dwm.desktop` (created by `bin/generate-dwm-desktop.sh`) → `Exec=dwm-start.sh`
2. `dwm-start.sh` in `~/.local/bin/`:
   - Sets XDG/IM env vars, loads Xresources, generates app themes (first run only)
   - Starts: xsettingsd, dunst, nm-applet, fcitx5, blueman-applet, pasystray, slstatus, xfce4-clipman, picom, xwallpaper
   - `exec dwm`

## Shell configuration

`bin/update-bashrc.sh` adds a snippet to `~/.bashrc` that sources `~/.bashrc.d/*.sh`. The bashrc.d fragments are in `dotfiles/bashrc/.bashrc.d/`.

## Commands to know

```bash
# Full install (as regular user)
./install.sh

# Single component (example)
bash bin/install-dwm.sh

# Redeploy dotfiles only
bash bin/deploy-dotfiles.sh

# Config backup/restore
bash tools/config-manager.sh backup
bash tools/config-manager.sh restore

# Switch theme
~/.local/bin/switch-theme.sh <theme-name>
```

## opencode config

Repo-local config at `dotfiles/opencode/.config/opencode/opencode.json` — MCP chrome-devtools enabled, paste summary and formatter disabled. No project-level `opencode.json` at repo root.
