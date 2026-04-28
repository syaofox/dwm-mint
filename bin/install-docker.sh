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

log_step "Checking for NVIDIA GPU to enable Docker GPU support..."

if ! command -v lspci &>/dev/null; then
    log_info "Installing pciutils for hardware detection..."
    sudo apt install -y pciutils
fi

if lspci -d 10de:* | grep -q .; then
    log_info "NVIDIA GPU detected, installing NVIDIA Container Toolkit..."

    log_info "Installing prerequisites for NVIDIA Container Toolkit..."
    sudo apt update && sudo apt install -y --no-install-recommends ca-certificates curl gnupg2

    log_info "Setting up NVIDIA Container Toolkit repository..."
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb \[signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg\] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null

    sudo apt update
    sudo apt install -y nvidia-container-toolkit nvidia-container-toolkit-base libnvidia-container-tools libnvidia-container1

    log_info "Configuring Docker NVIDIA runtime..."
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker

    log_info "NVIDIA Container Toolkit installed. Note: Host NVIDIA drivers are required for GPU access."
else
    log_info "No NVIDIA GPU detected, skipping GPU dependencies"
fi

exit 0