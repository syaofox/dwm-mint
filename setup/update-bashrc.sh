#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOTFILES_DIR="$PROJECT_ROOT/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    log_error "dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

log_step "Configure Bash environment..."

BASHRC="$HOME/.bashrc"
need_bashrc_entry=false
if [[ ! -f "$BASHRC" ]]; then
    need_bashrc_entry=true
else
    if ! grep -q '~/.bashrc.d' "$BASHRC" 2>/dev/null; then
        need_bashrc_entry=true
    fi
fi

if [[ "$need_bashrc_entry" == "true" ]]; then
    cat >> "$BASHRC" << 'EOF'

# Load all .sh files from ~/.bashrc.d/
if [ -d "$HOME/.bashrc.d" ]; then
    for file in "$HOME/.bashrc.d"/*.sh; do
        [ -r "$file" ] && source "$file"
    done
    unset file
fi
EOF
    log_info "Added ~/.bashrc.d loading code"
else
    log_info "~/.bashrc already contains ~/.bashrc.d loading code"
fi

if [[ ! -f "$HOME/.bashrc.d/ps1/current" ]]; then
    log_info "Generating initial PS1 configuration..."
    THEME=$(cat "$HOME/.config/theme" 2>/dev/null || echo "tokyonight")
    theme_file="$HOME/.Xresources.d/${THEME}"
    if [[ -f "$HOME/.local/bin/generate-app-themes.py" ]] && [[ -f "$theme_file" ]]; then
        python3 "$HOME/.local/bin/generate-app-themes.py" "$theme_file"
        log_info "PS1 configuration generated for theme: $THEME"
    else
        log_warn "Could not generate PS1: theme file or generator not found"
    fi
fi

log_info "Bash environment configuration completed"
exit 0