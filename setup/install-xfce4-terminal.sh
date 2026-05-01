#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing xfce4-terminal..."

log_info "Installing xfce4-terminal..."
if ! sudo apt install xfce4-terminal -y; then
    log_error "Failed to install xfce4-terminal"
    exit 1
fi

log_info "Setting xfce4-terminal as Nemo's default terminal..."
gsettings set org.cinnamon.desktop.default-applications.terminal exec "xfce4-terminal"

log_info "xfce4-terminal installation complete"
exit 0
