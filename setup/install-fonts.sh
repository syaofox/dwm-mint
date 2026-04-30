#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing fonts..."


log_step "Installing UbuntuMono..."
FONT_DIR="${HOME}/.local/share/fonts/UbuntuMono"
mkdir -p "${FONT_DIR}"
if unzip -o "/home/syaofox/dwm-mint/res/UbuntuMono.zip" -d "${FONT_DIR}" >/dev/null 2>&1; then
    log_info "UbuntuMono installed to ${FONT_DIR}"
else
    log_error "Failed to install UbuntuMono"
    exit 1
fi

log_step "Installing JetBrainsMono..."
FONT_DIR="${HOME}/.local/share/fonts/JetBrainsMono"
mkdir -p "${FONT_DIR}"
if tar -xf "/home/syaofox/dwm-mint/res/JetBrainsMono.tar.xz" -C "${FONT_DIR}" >/dev/null 2>&1; then
    log_info "JetBrainsMono installed to ${FONT_DIR}"
else
    log_error "Failed to install JetBrainsMono"
    exit 1
fi

log_info "Refreshing font cache..."
fc-cache -fv 2>/dev/null || true

log_info "Fonts installation complete"
exit 0