#!/usr/bin/env bash
set -euo pipefail

timestamp() { date +"%Y%m%d-%H%M%S"; }

info() { printf "[INFO] %s\n" "$*"; }
warn() { printf "[WARN] %s\n" "$*"; }

write_xsession() {
  local target="$HOME/.xsession"
  if [ -f "$target" ]; then
    local bak="${target}.bak-$(timestamp)"
    cp -f "$target" "$bak"
    info "已备份现有 ~/.xsession -> $bak"
  fi

  cat >"$target" <<'EOF'
#!/bin/sh
# start GNOME Keyring Daemon and export SSH agent variables
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO
exec dwm
EOF

  chmod 0644 "$target"
  info "已写入 $target"
}

write_desktop_file() {
  local target="/usr/share/xsessions/dwm.desktop"
  if [ -f "$target" ]; then
    local bak="${target}.bak-$(timestamp)"
    sudo cp -f "$target" "$bak"
    info "已备份现有 dwm.desktop -> $bak"
  fi

  sudo install -d -m 0755 "/usr/share/xsessions"
  sudo tee "$target" >/dev/null <<'EOF'
[Desktop Entry]
Name=dwm
Comment=dynamic window manager
Exec=/etc/X11/Xsession
TryExec=/usr/bin/dwm
Type=XSession
DesktopNames=dwm
EOF
  sudo chmod 0644 "$target"
  info "已写入 $target"
}

post_notes() {
  info "完成。请在登录界面选择会话：dwm。"
  info "若未显示：确认 /usr/bin/dwm 存在，且 $HOME/.xsession 与 /usr/share/xsessions/dwm.desktop 权限正确。"
}

main() {
  write_xsession
  write_desktop_file
  post_notes
}

main "$@"


