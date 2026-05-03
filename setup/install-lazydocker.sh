#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing lazydocker..."

if command -v lazydocker >/dev/null 2>&1 && [ "$FORCE_UPGRADE" != true ]; then
    log_info "lazydocker is already installed"
    exit 0
fi

log_info "Downloading and running lazydocker install script..."
if ! curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash; then
    log_error "Failed to install lazydocker"
    exit 1
fi

log_info "lazydocker installation complete"
exit 0
