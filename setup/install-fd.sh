#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing fd-find..."

if command -v fd >/dev/null 2>&1; then
    log_info "fd is already installed"
    exit 0
fi

FD_VERSION="v10.4.2"
FD_DEB="/tmp/fd-musl_10.4.2_amd64.deb"

log_info "Downloading fd deb package..."
if ! curl -L -o "$FD_DEB" "https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd-musl_10.4.2_amd64.deb"; then
    log_error "Failed to download fd deb package"
    exit 1
fi

log_info "Installing fd..."
if ! sudo dpkg -i "$FD_DEB"; then
    log_error "Failed to install fd"
    rm -f "$FD_DEB"
    exit 1
fi

rm -f "$FD_DEB"

log_info "fd installation complete"
exit 0