#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing rofi and launcher tools..."

APT_packages=(
    rofi  
)

log_info "Installing official packages..."
if ! sudo apt install "${APT_packages[@]}" -y; then
    log_error "Failed to install some official packages"
    exit 1
fi

log_info "rofi and launcher tools installation complete"
exit 0