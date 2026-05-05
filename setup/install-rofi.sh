#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing rofi from source (meson build)..."

BUILD_DEPS=(
    meson
    ninja-build
    pkg-config
    flex
    bison
    check
    libpango1.0-dev
    libcairo2-dev
    libglib2.0-dev
    libgdk-pixbuf-2.0-dev
    libstartup-notification0-dev
    libxkbcommon-dev
    libxkbcommon-x11-dev
    libxcb-util-dev
    libxcb-ewmh-dev
    libxcb-icccm4-dev
    libxcb-randr0-dev
    libxcb-xinerama0-dev
    libxcb-xkb-dev
    libxcb-cursor-dev
    xcb-proto
    libwayland-dev
    wayland-protocols
    libxcb-imdkit-dev
)

log_info "Installing build dependencies..."
sudo apt install "${BUILD_DEPS[@]}" -y

if dpkg -s rofi &>/dev/null; then
    log_info "Removing apt-installed rofi to avoid conflicts..."
    sudo apt remove -y rofi
fi

REPO_URL="https://github.com/davatorium/rofi.git"
BUILD_DIR="/tmp/rofi"

if [[ -d "$BUILD_DIR" ]]; then
    if [[ -d "$BUILD_DIR/.git" ]]; then
        log_info "Updating repository..."
        cd "$BUILD_DIR"
        git checkout next 2>/dev/null || true
        git pull
        git submodule update --init
    else
        log_info "Directory exists but not a git repository, re-cloning..."
        rm -rf "$BUILD_DIR"
        git clone --recursive -b next "$REPO_URL" "$BUILD_DIR"
        cd "$BUILD_DIR"
    fi
else
    git clone --recursive -b next "$REPO_URL" "$BUILD_DIR"
    cd "$BUILD_DIR"
fi

meson setup build --prefix /usr
ninja -C build
sudo ninja -C build install

cd - > /dev/null || true

log_info "rofi installation complete"
exit 0