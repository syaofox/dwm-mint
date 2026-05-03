# AGENTS.md

## Project overview

Deploy a DWM desktop environment on Linux Mint 22.3 (Ubuntu 24.04 LTS). The repo is a collection of shell install scripts, dotfiles, and admin tools — no build system, no tests, no CI.

## Entry points

- **`install.sh`** — main orchestrator. Runs all `setup/install-*.sh` in sequence, prompting retry/skip/exit on each failure. Supports `-u`/`--upgrade` flag to force reinstallation/upgrade of already-installed components.
- **`tools/config-manager.sh`** — interactive backup/restore for SSH, GPG, dconf, fcitx5 configs. Accepts `backup` or `restore` subcommand.
- **`sbin/*.sh`** — standalone admin scripts (zram, btrfs subvolumes). Run separately, not part of `install.sh`.

## Do NOT run as root

- `install.sh` refuses root and must run as a regular user with sudo.
- `tools/config-manager.sh` refuses root.
- `sbin/zram.sh` and `sbin/btrfs-select.sh` **require** root/sudo.

## Architecture

```
setup/      Install scripts, one per component. Source setup/utils.sh for logging + helpers.
dotfiles/   Config files organized as a flat `$HOME` mirror tree. Deployed by `setup/deploy-dotfiles.sh`.
tools/      config-manager.sh (fzf-based backup/restore)
sbin/       System admin scripts (sudo required, run independently)
res/        Font archives (JetBrainsMono, UbuntuMono)
backups/    Output directory for config-manager.sh backups
```

## How dotfiles are deployed

`setup/deploy-dotfiles.sh` **copies** (not symlinks) files from `dotfiles/` into `$HOME`. The `dotfiles/` tree mirrors `$HOME` directly — each file's target path is its relative path under `dotfiles/`. Existing files are backed up to `~/.config-backup-<timestamp>/`.

Key implication: **editing files in the repo does NOT affect the live system** — you must re-run `deploy-dotfiles.sh` or manually copy.

## DWM / slstatus / slock

These are compiled from personal forks under `github.com/syaofox/*`:
- `dwm` → `https://github.com/syaofox/dwm.git`
- `slstatus` → `https://github.com/syaofox/slstatus.git`
- `slock` → `https://github.com/syaofox/slock.git`

The `compile_and_install()` helper in `setup/utils.sh` clones into `/tmp/<name>`, runs `git pull` if the directory already exists, then `sudo make clean install`. These repos must be accessible.

## Theme system

Themes are Xresources files in `~/.Xresources.d/`. Each file uses `#define` macros at the top to define a standard palette (~40 variables covering all colors). Below the macros are the `dwm.*`, `slstatus.*`, and `slock.*` entries that reference those macros — these are read directly by `xrdb`.

The active theme name is stored in `~/.config/theme`.

`dotfiles/.local/bin/switch-theme.sh` handles switching. It runs `generate-app-themes.py` (in `~/.local/bin/`) which:
1. Parses the `#define` macros from the Xresources theme file → palette dict
2. Renders Jinja2-style templates from `~/.local/bin/templates/*.j2` using a built-in template engine (no Jinja2 dependency)
3. Writes the rendered configs to the correct paths

### Templates (dotfiles/.local/bin/templates/)

| Template | Output |
|----------|--------|
| `dunstrc.j2` | `~/.config/dunst/dunstrc` |
| `rofi.rasi.j2` | `~/.config/rofi/theme.rasi` |
| `wezterm.lua.j2` | `~/.config/wezterm/theme.lua` |
| `yazi.toml.j2` | `~/.config/yazi/theme.toml` |
| `ps1.j2` | `~/.bashrc.d/ps1/current` |
| `gtk2.j2` | `~/.gtkrc-2.0` |
| `gtk3.ini.j2` | `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini` |
| `xsettingsd.conf.j2` | `~/.config/xsettingsd/xsettingsd.conf` |
| `xfce4-terminal.sh.j2` | `~/.cache/xfce4-terminal-theme.sh` (executed as shell script) |

**Adding a new app**: create a new `.j2` template and add a `(template_name, output_path)` entry in `TEMPLATE_OUTPUTS` inside `generate-app-themes.py` — no new Python function needed.

**Adding a new theme**: create an Xresources file in `dotfiles/.Xresources.d/` with the standard `#define` palette section + dwm/slstatus/slock entries referencing macros. See existing themes for format.

### Available filters in templates

- `{{ VAR }}` — direct substitution
- `{{ VAR | hex_to_rgb }}` → `"R, G, B"` (for rofi rgba())
- `{{ VAR | hex_to_rgb_s }}` → `"R;G;B"` (for ANSI escape sequences)

## DWM session startup flow

1. `/usr/share/xsessions/dwm.desktop` (created by `setup/generate-dwm-desktop.sh`) → `Exec=dwm-start.sh`
2. `dwm-start.sh` in `~/.local/bin/`:
   - Sets XDG/IM env vars, loads Xresources, generates app themes (first run only)
   - Starts: xsettingsd, dunst, nm-applet, fcitx5, blueman-applet, pasystray, slstatus, xfce4-clipman, picom, xwallpaper
   - `exec dwm`

## Shell configuration

`setup/update-bashrc.sh` adds a snippet to `~/.bashrc` that sources `~/.bashrc.d/*.sh`. The bashrc.d fragments are in `dotfiles/.bashrc.d/`.

## Commands to know

```bash
# Full install (as regular user)
./install.sh

# Single component (example)
bash setup/install-dwm.sh

# Redeploy dotfiles only
bash setup/deploy-dotfiles.sh

# Config backup/restore
bash tools/config-manager.sh backup
bash tools/config-manager.sh restore

# Switch theme
~/.local/bin/switch-theme.sh <theme-name>
```

## opencode config

Repo-local config at `dotfiles/.config/opencode/opencode.json` — MCP chrome-devtools enabled, paste summary and formatter disabled. No project-level `opencode.json` at repo root.
