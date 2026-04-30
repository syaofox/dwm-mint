#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing Opencode..."


if command -v "opencode" >/dev/null 2>&1 ; then
    log_info "opencode is already installed"
    exit 0
fi

log_info "Installing opencode via official installer..."
if ! curl -fsSL https://opencode.ai/install | bash; then
    log_error "Failed to install opencode"
    exit 1
fi


log_info "opencode installation complete"
exit 0