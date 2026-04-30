#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing fcitx5..."

apt_packages=(
    fcitx5
    fcitx5-chinese-addons
    fcitx5-frontend-gtk2
    fcitx5-frontend-gtk3
    fcitx5-frontend-gtk4
    fcitx5-frontend-qt5
    fcitx5-frontend-qt6
    fcitx5-material-color
)

log_info "Installing official packages..."
if ! sudo apt install -y "${apt_packages[@]}"; then
    log_error "Failed to install some official packages"
    exit 1
fi

log_info "fcitx5 installation complete"
exit 0