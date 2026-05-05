#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing Brave Origin Nightly..."

log_info "Adding Brave Nightly APT repository..."
sudo apt install -y curl

sudo curl -fsSLo /usr/share/keyrings/brave-browser-nightly-archive-keyring.gpg \
    https://brave-browser-apt-nightly.s3.brave.com/brave-browser-nightly-archive-keyring.gpg

sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-nightly.sources \
    https://brave-browser-apt-nightly.s3.brave.com/brave-browser.sources

log_info "Updating package list..."
sudo apt update

log_info "Installing brave-origin-nightly..."
sudo apt install -y brave-origin-nightly

log_info "Brave Origin Nightly installation complete"
exit 0
