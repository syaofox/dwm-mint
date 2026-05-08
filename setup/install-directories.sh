#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Creating common directories..."

dirs=(
    "$HOME/tmp"
    "$HOME/project"
    "/mnt/dnas/backup"
    "/mnt/dnas/data"
    "/mnt/dnas/download"
    "/mnt/dnas/wd12t"
    "/mnt/xiaoxin/data"
)

for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_info "Created: $dir"
    else
        log_info "Already exists: $dir"
    fi
done
