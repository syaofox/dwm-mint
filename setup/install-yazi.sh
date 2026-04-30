#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing yazi and dependencies..."

APT_packages=(
    ffmpeg
    7zip
    jq
    poppler-utils
    ripgrep
    zoxide
    imagemagick
)

if ! sudo apt install "${APT_packages[@]}" -y; then
    log_error "Failed to install some packages"
    exit 1
fi

log_step "Installing yazi binary..."

log_info "Fetching latest version..."
LATEST_VERSION=$(curl -sL https://api.github.com/repos/sxyazi/yazi/releases/latest | jq -r '.tag_name')
LATEST_VERSION="${LATEST_VERSION#v}"

log_info "Latest version: ${LATEST_VERSION}"

DEB_URL="https://github.com/sxyazi/yazi/releases/download/v${LATEST_VERSION}/yazi-x86_64-unknown-linux-gnu.deb"

TMPDIR=$(mktemp -d)
DEB_FILE="$TMPDIR/yazi.deb"

trap 'rm -rf "$TMPDIR"' EXIT

log_info "Downloading yazi..."
if ! curl -sL "$DEB_URL" -o "$DEB_FILE"; then
    log_error "Failed to download yazi"
    exit 1
fi

log_info "Extracting yazi binary..."
TMP_EXTRACT="$TMPDIR/extract"
mkdir -p "$TMP_EXTRACT"
dpkg -x "$DEB_FILE" "$TMP_EXTRACT"

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

YAZI_BIN="$TMP_EXTRACT/usr/bin/yazi"
YA_BIN="$TMP_EXTRACT/usr/bin/ya"

if [ -f "$YAZI_BIN" ]; then
    cp "$YAZI_BIN" "$LOCAL_BIN/yazi"
    log_info "Installed yazi to $LOCAL_BIN/yazi"
fi

if [ -f "$YA_BIN" ]; then
    cp "$YA_BIN" "$LOCAL_BIN/ya"
    log_info "Installed ya to $LOCAL_BIN/ya"
fi

log_info "Verifying installation..."
$LOCAL_BIN/yazi --version

log_info "yazi installation complete"
exit 0