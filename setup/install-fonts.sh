#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "${SCRIPT_DIR}/utils.sh"

RES_DIR="$(dirname "${SCRIPT_DIR}")/res"

log_step "Installing fonts..."

log_step "Installing UbuntuMono..."
FONT_DIR="${HOME}/.local/share/fonts/UbuntuMono"
mkdir -p "${FONT_DIR}"
if unzip -o "${RES_DIR}/UbuntuMono.zip" -d "${FONT_DIR}" >/dev/null 2>&1; then
    log_info "UbuntuMono installed to ${FONT_DIR}"
else
    log_error "Failed to install UbuntuMono"
    exit 1
fi

log_step "Installing JetBrainsMono..."
FONT_DIR="${HOME}/.local/share/fonts/JetBrainsMono"
mkdir -p "${FONT_DIR}"
if tar -xf "${RES_DIR}/JetBrainsMono.tar.xz" -C "${FONT_DIR}" >/dev/null 2>&1; then
    log_info "JetBrainsMono installed to ${FONT_DIR}"
else
    log_error "Failed to install JetBrainsMono"
    exit 1
fi

log_info "Refreshing font cache..."
fc-cache -fv 2>/dev/null || true

log_info "Fonts installation complete"
exit 0