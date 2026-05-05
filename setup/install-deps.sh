#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing system dependencies..."


APT_packages=(

    # imagemagick     
    # 
    # xsel

    build-essential python3-dev libx11-dev libxinerama-dev libxft-dev libxrandr-dev
    x11-xserver-utils 
    dunst xwallpaper pasystray picom 
    xfce4-clipman xdotool
    maim xclip rofi ffmpeg 
    lxappearance  xdg-desktop-portal

    # 归档工具
    unzip 7zip

    # 存储与网络
    nfs-common

    # Qt 与 Portal
    qt5ct 
 
    # CLI 工具
    #  jq 
    ripgrep  zoxide  thefuck trash-cli htop nvtop
    
    # 音频工具
    alsa-utils pavucontrol pasystray

    # 其他
    papirus-icon-theme adwaita-icon-theme-full gnome-icon-theme numlockx
    cava 

)

log_info "Installing official packages..."
if ! sudo apt install -y "${APT_packages[@]}"; then
    log_error "Failed to install some official packages"
    exit 1
fi



log_info "System dependencies installation complete"
exit 0