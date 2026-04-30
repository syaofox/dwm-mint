#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing GSettings and xsettings daemon..."

APT_PACKAGES=(

    xsettingsd
)

log_info "Installing GSettings packages..."
if ! sudo apt install "${APT_PACKAGES[@]}" -y; then
    log_error "Failed to install GSettings packages"
    exit 1
fi

log_info "GSettings installation complete"
exit 0
