#!/bin/bash
log()    { echo "[$(date +'%H:%M:%S')] $*"; }
err()    { echo "[$(date +'%H:%M:%S')] ERROR: $*" >&2; }


export XDG_CURRENT_DESKTOP=dwm
export XDG_SESSION_DESKTOP=dwm

LOGDIR="$HOME/.local/share/dwm"
LOGFILE="$LOGDIR/dwm.log"
mkdir -p "$LOGDIR"
[ -f "$LOGFILE" ] && [ "$(stat -c%s "$LOGFILE")" -gt 1048576 ] && mv "$LOGFILE" "$LOGFILE.old"
exec > >(tee -a "$LOGFILE") 2>&1
log "=== DWM session starting (PID: $$) ==="

# ---------- X 基础设置 ----------
log "Setting X basic settings (dpms, screensaver)..."
xset -dpms && log "dpms disabled" || err "failed to disable dpms"
xset s off && log "screensaver disabled" || err "failed to disable screensaver"
xset s noblank && log "blanking disabled" || err "failed to disable blanking"

# xrandr --output HDMI-0 --mode 2560x1080 --rate 60 --primary &




# ---------- Xresources 主题 ----------
log "Loading theme configuration..."
if [ -f "$HOME/.config/theme" ]; then
    THEME=$(cat "$HOME/.config/theme")
    log "Theme loaded from config: $THEME"
else
    THEME="tokyonight"
    log "No theme config found, using default: $THEME"
fi



# 只在配置文件缺失时才生成（新系统首次启动）
if [ ! -f "$HOME/.config/rofi/theme.rasi" ]; then
    log "Generating app themes (first run)..."
    if [ -f "$HOME/.local/bin/generate-app-themes.py" ]; then
        theme_file="$HOME/.Xresources.d/${THEME}"
        if [ -f "$theme_file" ]; then
            python3 "$HOME/.local/bin/generate-app-themes.py" "$theme_file" && log "App themes generated successfully" || err "Failed to generate app themes"
        else
            err "Theme file not found: $theme_file"
        fi
    else
        err "generate-app-themes.py not found"
    fi
else
    log "App themes already exist, skipping generation"
fi


# Xresources 使用完整主题名
if [ -f "$HOME/.Xresources.d/${THEME}" ]; then
    log "Merging Xresources for theme: $THEME"
    xrdb -merge "$HOME/.Xresources.d/${THEME}" && log "Xresources merged successfully" || err "Failed to merge Xresources"
else
    err "Xresources theme file not found: $HOME/.Xresources.d/${THEME}"
fi


# ---------- 权限与环境 ----------
log "Starting PolicyKit authentication agent..."
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
[ $? -eq 0 ] && log "polkit agent started (PID: $!)" || err "Failed to start polkit agent"

log "Starting gnome-keyring-daemon..."
eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh) && log "gnome-keyring started" || err "Failed to start gnome-keyring"
export SSH_AUTH_SOCK
log "SSH_AUTH_SOCK exported: $SSH_AUTH_SOCK"


# XSettings 守护进程 (GTK 主题/字体设置)
if command -v xsettingsd >/dev/null; then
    log "Starting xsettingsd..."
    pkill -x xsettingsd 2>/dev/null || true
    xsettingsd &
    log "xsettingsd started (PID: $!)"
else
    err "xsettingsd not found, GTK theme settings may not work"
fi

log "Starting dunst notification daemon..."
dunst &
log "dunst started (PID: $!)"

log "Starting nm-applet..."
nm-applet &
log "nm-applet started (PID: $!)"

log "Starting fcitx5 input method..."
fcitx5 -d &
log "fcitx5 started (PID: $!)"

# 判断是否有蓝牙，如果有则启动蓝牙图标
if rfkill list bluetooth >/dev/null 2>&1; then
    log "Bluetooth detected, starting blueman-applet..."
    blueman-applet &
    log "blueman-applet started (PID: $!)"
else
    log "No Bluetooth detected, skipping blueman-applet"
fi

log "Starting pasystray (PulseAudio)..."
pasystray &
log "pasystray started (PID: $!)"

log "Starting slstatus..."
slstatus &
log "slstatus started (PID: $!)"

# picom -b &
# log "picom started (PID: $!)"


# 壁纸 (使用 feh)
if command -v feh >/dev/null; then
    log "Setting wallpaper..."
    WALLPAPER_CONF="$HOME/.config/wallpaper.conf"
    DEFAULT_WALLPAPER="$HOME/.config/walls/black-nord.png"

    if [[ -f "$WALLPAPER_CONF" ]] && [[ -s "$WALLPAPER_CONF" ]]; then
        WALLPAPER=$(cat "$WALLPAPER_CONF")
        log "Wallpaper from config: $WALLPAPER"
    else
        WALLPAPER="$DEFAULT_WALLPAPER"
        log "Using default wallpaper: $WALLPAPER"
    fi

    if [[ -f "$WALLPAPER" ]]; then
        feh --bg-fill "$WALLPAPER" && log "Wallpaper set successfully" || err "Failed to set wallpaper: $WALLPAPER"
    else
        err "Wallpaper file not found: $WALLPAPER"
    fi
else
    err "feh not found, wallpaper not set"
fi



log "=== Starting DWM (PID: $$) ==="
exec dwm
