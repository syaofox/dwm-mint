#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing fd-find..."

get_latest_fd_version() {
    curl -sL https://api.github.com/repos/sharkdp/fd/releases/latest | grep '"tag_name"' | cut -d'"' -f4
}

LATEST_VERSION="${FD_VERSION:-$(get_latest_fd_version)}"
: "${LATEST_VERSION:?Failed to detect latest fd version}"
LATEST_VER_NUM="${LATEST_VERSION#v}"

if command -v fd >/dev/null 2>&1; then
    INSTALLED_VERSION=$(fd --version 2>/dev/null | awk '{print $NF}' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [ "$INSTALLED_VERSION" = "$LATEST_VER_NUM" ] && [ "$FORCE_UPGRADE" != true ]; then
        log_info "fd ${INSTALLED_VERSION} is already the latest version"
        exit 0
    fi
    if [ "$FORCE_UPGRADE" != true ]; then
        log_info "fd is already installed (version ${INSTALLED_VERSION})"
        exit 0
    fi
fi

FD_DEB="/tmp/fd-musl_${LATEST_VER_NUM}_amd64.deb"

log_info "Downloading fd ${LATEST_VERSION}..."
if ! curl -L -o "$FD_DEB" "https://github.com/sharkdp/fd/releases/download/${LATEST_VERSION}/fd-musl_${LATEST_VER_NUM}_amd64.deb"; then
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