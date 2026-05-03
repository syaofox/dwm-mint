#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing uv Python package manager..."

UV_BIN_DIR="$HOME/.local/bin"

if command -v "$UV_BIN_DIR/uv" >/dev/null 2>&1 || grep -q "$UV_BIN_DIR" "$HOME/.bashrc" 2>/dev/null; then
    if [ "$FORCE_UPGRADE" = true ]; then
        log_info "Upgrading uv..."
        "$UV_BIN_DIR/uv" self update || log_warn "uv self update failed, trying full reinstall"
        if command -v "$UV_BIN_DIR/uv" >/dev/null 2>&1; then
            log_info "uv upgrade complete"
            exit 0
        fi
    else
        log_info "uv is already installed at ${UV_BIN_DIR}"
        exit 0
    fi
fi

log_info "Installing uv via official installer..."
if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
    log_error "Failed to install uv"
    exit 1
fi

log_info "Adding uv to PATH..."
BASHRC="$HOME/.bashrc"
if ! grep -q "$UV_BIN_DIR" "$BASHRC" 2>/dev/null; then
    echo "export PATH=\"\$PATH:${UV_BIN_DIR}\"" >> "$BASHRC"
fi

log_info "uv installation complete"
exit 0