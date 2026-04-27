#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing Visual Studio Code..."

log_info "Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y wget gpg

log_info "Adding Microsoft GPG key..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
sudo install -D -o root -g root -m 644 /tmp/microsoft.gpg /usr/share/keyrings/microsoft.gpg
rm -f /tmp/microsoft.gpg

log_info "Adding VS Code repository..."
echo "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64 arm64 armhf
Signed-By: /usr/share/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null

log_info "Installing VS Code..."
sudo apt update
sudo apt install -y apt-transport-https
sudo apt update
sudo apt install -y code

log_info "Visual Studio Code installation complete"
exit 0