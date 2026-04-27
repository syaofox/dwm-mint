#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing fzf..."

if [ -d "$HOME/.fzf" ]; then
    log_info "fzf is already installed at ~/.fzf"
    exit 0
fi

log_info "Cloning fzf repository..."
if ! git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; then
    log_error "Failed to clone fzf repository"
    exit 1
fi

log_info "Running fzf install script..."
if ! ~/.fzf/install; then
    log_error "Failed to run fzf install script"
    exit 1
fi

log_info "fzf installation complete"
exit 0