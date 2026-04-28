#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing Neovim..."

INSTALL_DIR="/opt/nvim"
NVIM_BIN_DIR="${INSTALL_DIR}-linux-x86_64/bin"

if command -v "$NVIM_BIN_DIR/nvim" >/dev/null 2>&1 || grep -q "$NVIM_BIN_DIR" "$HOME/.bashrc" 2>/dev/null; then
    log_info "Neovim is already installed at ${NVIM_BIN_DIR}"
    exit 0
fi

ARCHIVE="nvim-linux-x86_64.tar.gz"
URL="https://github.com/neovim/neovim/releases/latest/download/${ARCHIVE}"

log_info "Downloading Neovim..."
if ! curl -LO "$URL"; then
    log_error "Failed to download Neovim"
    exit 1
fi

log_info "Installing Neovim to ${INSTALL_DIR}..."
if ! sudo rm -rf "$INSTALL_DIR" || ! sudo tar -C /opt -xzf "$ARCHIVE"; then
    log_error "Failed to install Neovim"
    rm -f "$ARCHIVE"
    exit 1
fi

rm -f "$ARCHIVE"

BASHRC="$HOME/.bashrc"

if ! grep -q "$NVIM_BIN_DIR" "$BASHRC" 2>/dev/null; then
    log_info "Adding Neovim to PATH in ~/.bashrc..."
    echo "export PATH=\"\$PATH:${NVIM_BIN_DIR}\"" >> "$BASHRC"
fi

PROFILE_D="/etc/profile.d/neovim.sh"
if ! sudo test -f "$PROFILE_D" 2>/dev/null || ! sudo grep -q "$NVIM_BIN_DIR" "$PROFILE_D" 2>/dev/null; then
    log_info "Adding Neovim to PATH system-wide in ${PROFILE_D}..."
    echo "export PATH=\"\$PATH:${NVIM_BIN_DIR}\"" | sudo tee "$PROFILE_D" > /dev/null
    sudo chmod 644 "$PROFILE_D"
fi

if ! sudo test -f /usr/local/bin/nvim 2>/dev/null; then
    log_info "Creating symlink /usr/local/bin/nvim..."
    sudo ln -sf "${NVIM_BIN_DIR}/nvim" /usr/local/bin/nvim
fi

log_info "Neovim installation complete"
exit 0