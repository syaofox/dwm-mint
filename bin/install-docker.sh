#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing Docker Engine and Docker Compose..."

log_info "Uninstalling old versions..."
sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker 2>/dev/null || true

log_info "Setting up Docker apt repository..."
sudo apt update
sudo apt install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

. /etc/os-release
echo "Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc" | sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null

log_info "Installing Docker packages..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

log_info "Configuring Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

log_info "Adding current user to docker group..."
sudo usermod -aG docker "$USER"

log_info "Verifying Docker installation..."
sudo docker run --rm hello-world

log_info "Docker and Docker Compose installation complete"
log_info "Note: You may need to log out and back in for group changes to take effect"
exit 0