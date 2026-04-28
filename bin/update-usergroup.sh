#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Updating user groups..."

sudo usermod -aG video,render $USER || exit 1

