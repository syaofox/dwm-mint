#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing fish shell..."

log_info "Installing fish from official repo..."
if ! sudo apt install -y fish; then
    log_error "Failed to install fish"
    exit 1
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