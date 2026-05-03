#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing fzf..."

log_info "Installing fzf via apt..."
if ! sudo apt install -y fzf; then
    log_error "Failed to install fzf"
    exit 1
fi

log_info "Cloning fzf repository for shell integration files..."
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
elif [ "$FORCE_UPGRADE" = true ]; then
    log_info "Updating fzf shell integration..."
    git -C "$HOME/.fzf" pull --ff-only || log_warn "Failed to update fzf repo, skipping"
fi

log_info "fzf installation complete"
exit 0
