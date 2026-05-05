#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing Kitty terminal..."

log_info "Downloading and running the official kitty installer..."
if ! curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin; then
    log_error "Failed to install kitty"
    exit 1
fi

log_info "Creating symlink for kitty in ~/.local/bin..."
mkdir -p "$HOME/.local/bin"
if [ -f "$HOME/.local/kitty.app/bin/kitty" ]; then
    ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
fi

log_info "Setting kitty as Nemo's default terminal..."
gsettings set org.cinnamon.desktop.default-applications.terminal exec "kitty"

log_info "Kitty installation complete"
exit 0

