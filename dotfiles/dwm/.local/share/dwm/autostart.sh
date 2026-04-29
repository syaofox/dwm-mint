#!/bin/bash
log()    { echo "[$(date +'%H:%M:%S')] $*"; }
err()    { echo "[$(date +'%H:%M:%S')] ERROR: $*" >&2; }


LOGDIR="$HOME/.local/share/dwm"
LOGFILE="$LOGDIR/dwm.log"
mkdir -p "$LOGDIR"
[ -f "$LOGFILE" ] && [ "$(stat -c%s "$LOGFILE")" -gt 1048576 ] && mv "$LOGFILE" "$LOGFILE.old"
exec > >(tee -a "$LOGFILE") 2>&1
log "=== DWM session starting (PID: $$) ==="


# 设置输入法环境变量，确保在 DWM 中也能正确使用输入法
# log "Setting input method environment variables..."
# export XDG_CURRENT_DESKTOP=dwm
# export XDG_SESSION_DESKTOP=dwm
# export GTK_IM_MODULE=fcitx
# export QT_IM_MODULE=fcitx
# export XMODIFIERS=@im=fcitx
# export SDL_IM_MODULE=fcitx
# export GLFW_IM_MODULE=fcitx  # 之前日志显示为 ibus，这里强制改回
# export __GLX_VENDOR_LIBRARY_NAME=nvidia


# 注意：必须在所有 export 之后运行
if command -v dbus-update-activation-environment >/dev/null; then
    log "Updating DBus activation environment..."
    # 显式指定我们要强制同步的变量，防止被系统残留脚本覆盖为错误的值
    dbus-update-activation-environment --systemd DISPLAY XAUTHORITY \
        XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP \
        GTK_IM_MODULE QT_IM_MODULE XMODIFIERS
fi

# 3. 启动 Keyring 和 Polkit[cite: 2]
eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK
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
