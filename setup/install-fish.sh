#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing fish shell..."

FISH_DEB_URL="https://launchpad.net/~fish-shell/+archive/ubuntu/release-4/+files/fish_4.6.0-1~noble_amd64.deb"

log_info "Downloading fish deb package..."
curl -fsSL "$FISH_DEB_URL" -o /tmp/fish.deb

log_info "Installing fish..."
sudo dpkg -i /tmp/fish.deb || sudo apt install -y -f

log_info "Installing fisher..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

log_info "Changing default shell to fish..."
if ! sudo chsh -s /usr/bin/fish "$(whoami)"; then
    log_error "Failed to change shell"
    exit 1
fi

log_info "Installing fisher plugins..."
if ! fish -c "fisher update"; then
    log_error "Failed to install fisher plugins"
    exit 1
fi

log_info "fish installed successfully"

exit 0