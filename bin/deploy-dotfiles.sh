#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/utils.sh"

DOTFILES_DIR="$PROJECT_ROOT/dotfiles"
USER_HOME="$HOME"


log_step "Deploying dotfiles..."

if [ ! -d "$DOTFILES_DIR" ]; then
    log_error "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

for pkg_dir in "$DOTFILES_DIR"/*/; do
    [ ! -d "$pkg_dir" ] && continue

    pkg_name="$(basename "${pkg_dir%/}")"
    log_info "Deploying $pkg_name..."

    while IFS= read -r rel_path; do
        rel_path="${rel_path#./}"
        [ -z "$rel_path" ] && continue

        src="$pkg_dir$rel_path"
        target="$USER_HOME/$rel_path"

        create_symlink "$src" "$target"
    done < <(cd "$pkg_dir" && find . \( -type f -o -type l \) 2>/dev/null | grep -v '^./\.git$' | grep -v '^./\.svn$')
done

log_info "Dotfiles deployed successfully"

exit 0