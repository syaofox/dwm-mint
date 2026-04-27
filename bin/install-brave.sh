#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing Brave Browser..."

log_info "Running official Brave installer..."
if ! curl -fsS https://dl.brave.com/install.sh | sh; then
    log_error "Failed to install Brave Browser"
    exit 1
fi

log_info "Brave Browser installation complete"
exit 0