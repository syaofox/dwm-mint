#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


log_step "Installing Node.js via nvm..."

export NVM_DIR="$HOME/.config/nvm"

if [ ! -d "$NVM_DIR" ]; then
    mkdir -p "$NVM_DIR"
fi

if [ "$EUID" -eq 0 ]; then
    log_error "Error: Do not run this script as root. Please run it as a regular user."
    exit 1
fi

nvm_installed() {
    command -v nvm >/dev/null 2>&1 || [ -f "$NVM_DIR/nvm.sh" ]
}

node_installed() {
    [ -d "$NVM_DIR" ] && [ -f "$NVM_DIR/nvm.sh" ] && bash -c "source \"$NVM_DIR/nvm.sh\" && nvm list 25" 2>/dev/null | grep -q "v25"
}

if ! nvm_installed; then
    log_info "Installing nvm..."
    export NVM_DIR="$HOME/.config/nvm"
    bash -c 'export NVM_DIR="$HOME/.config/nvm" && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash'
    export NVM_DIR="$HOME/.config/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

if node_installed && [ "$FORCE_UPGRADE" != true ]; then
    log_info "Node.js 25 is already installed via nvm"
    exit 0
fi

if [ "$FORCE_UPGRADE" = true ] && node_installed; then
    log_info "Upgrading Node.js 25..."
    bash -c "source \"$NVM_DIR/nvm.sh\" && nvm install 25 --reinstall-packages-from=25 && nvm alias default 25"
else
    log_info "Installing Node.js 25..."
    bash -c "source \"$NVM_DIR/nvm.sh\" && nvm install 25 && nvm alias default 25"
fi

log_info "Node.js has been successfully installed!"
exit 0