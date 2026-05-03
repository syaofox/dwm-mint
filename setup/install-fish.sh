#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing fish shell..."

FISH_VERSION="4.6.0-1~noble"
FISH_DEB_URL="https://launchpad.net/~fish-shell/+archive/ubuntu/release-4/+files/fish_${FISH_VERSION}_amd64.deb"

if command -v fish >/dev/null 2>&1; then
    INSTALLED_VERSION=$(fish --version 2>/dev/null | awk '{print $NF}')
    DESIRED_VERSION="${FISH_VERSION%%-*}"
    if [ "$INSTALLED_VERSION" = "$DESIRED_VERSION" ] && [ "$FORCE_UPGRADE" != true ]; then
        log_info "fish ${INSTALLED_VERSION} is already installed, skipping deb install"
    else
        log_info "Downloading fish deb package..."
        curl -fsSL "$FISH_DEB_URL" -o /tmp/fish.deb
        log_info "Installing fish..."
        sudo dpkg -i /tmp/fish.deb || sudo apt install -y -f
    fi
else
    log_info "Downloading fish deb package..."
    curl -fsSL "$FISH_DEB_URL" -o /tmp/fish.deb
    log_info "Installing fish..."
    sudo dpkg -i /tmp/fish.deb || sudo apt install -y -f
fi

log_info "Installing fisher..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

if [ "$SHELL" != "/usr/bin/fish" ]; then
    log_info "Changing default shell to fish..."
    if ! sudo chsh -s /usr/bin/fish "$(whoami)"; then
        log_error "Failed to change shell"
        exit 1
    fi
else
    log_info "Default shell is already fish"
fi

log_info "Installing fisher plugins..."
if ! fish -c "fisher update"; then
    log_error "Failed to install fisher plugins"
    exit 1
fi

log_info "fish installed successfully"

exit 0