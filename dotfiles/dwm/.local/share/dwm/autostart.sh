#!/bin/bash
log()    { echo "[$(date +'%H:%M:%S')] $*"; }
err()    { echo "[$(date +'%H:%M:%S')] ERROR: $*" >&2; }


LOGDIR="$HOME/.local/share/dwm"
LOGFILE="$LOGDIR/dwm.log"
mkdir -p "$LOGDIR"
[ -f "$LOGFILE" ] && [ "$(stat -c%s "$LOGFILE")" -gt 1048576 ] && mv "$LOGFILE" "$LOGFILE.old"
exec > >(tee -a "$LOGFILE") 2>&1
log "=== DWM session starting (PID: $$) ==="


# 1. 虽然已经在 .xprofile 导出了，但在脚本里再次同步给 systemd/dbus 是最稳妥的
# 这样通过 systemctl --user 启动的应用也能拿到正确变量
if command -v dbus-update-activation-environment >/dev/null; then
    log "Updating DBus activation environment..."
    dbus-update-activation-environment --systemd --all
fi

# 2. 启动 Polkit (Cinnamon 必带组件)[cite: 1]
# 注意：不需要再次 eval keyring 了，因为 dwm 已经从 .xprofile 继承了变量
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &


log "Starting xsettingsd..."
xsettingsd &

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
pasystray >/dev/null 2>&1 &
log "pasystray started (PID: $!)"

log "Starting slstatus..."
slstatus &
log "slstatus started (PID: $!)"

log "Starting xfce4-clipman (clipboard manager)..."
xfce4-clipman &
log "xfce4-clipman started (PID: $!)"

log "Starting  picom (compositor)..."
picom -b &
log "picom started (PID: $!)"


# 壁纸 
if command -v xwallpaper >/dev/null; then
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

    xwallpaper --zoom "$WALLPAPER" &

else
    err "xwallpaper not found, wallpaper not set"
fi


systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
