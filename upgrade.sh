#!/bin/bash
[[ $EUID -eq 0 ]] && echo "Please do not run this script as root. Use a regular user account with sudo privileges." && exit 1

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/setup/utils.sh"

export FORCE_UPGRADE=true

cd "$SCRIPT_DIR"

ask_on_failure() {
    local step_name="$1"
    log_error "${step_name} failed"
    echo ""
    log_info "What would you like to do?"
    echo "  [r] Retry this step"
    echo "  [s] Skip this step"
    echo "  [e] Exit upgrade"
    echo ""
    read -p "Enter your choice [r/s/e]: " choice

    case $choice in
        r|R) return 1 ;;
        s|S) log_info "Skipping: ${step_name}"; echo ""; return 0 ;;
        e|E) log_info "Exiting upgrade..."; exit 1 ;;
        *) echo "Invalid choice. Please try again."; ask_on_failure "$step_name" ;;
    esac
}

run_step() {
    local step_name="$1"
    shift
    local cmd="$@"

    while true; do
        log_info "Running: ${step_name}..."
        if bash -c "$cmd"; then
            log_info "${step_name} completed successfully!"
            echo ""
            return 0
        else
            ask_on_failure "$step_name" || continue
            return 0
        fi
    done
}

log_info "Starting upgrade of all non-apt components..."
echo ""

run_step "Compile and upgrade DWM"       "./setup/install-dwm.sh"
run_step "Compile and upgrade slstatus"  "./setup/install-slstatus.sh"
run_step "Compile and upgrade slock"     "./setup/install-slock.sh"

run_step "Upgrade rofi"                  "./setup/install-rofi.sh"
run_step "Upgrade Neovim"                "./setup/install-neovim.sh"
run_step "Upgrade fd-find"               "./setup/install-fd.sh"
run_step "Upgrade uv"                    "./setup/install-uv.sh"
run_step "Upgrade Node.js"               "./setup/install-nodejs.sh"
run_step "Upgrade lazydocker"            "./setup/install-lazydocker.sh"
run_step "Upgrade opencode"              "./setup/install-opencode.sh"
run_step "Upgrade yazi"                  "./setup/install-yazi.sh"
run_step "Upgrade fzf shell integration" "./setup/install-fzf.sh"
# run_step "Upgrade fonts"                 "./setup/install-fonts.sh"

echo ""
log_info "═══════════════════════════════════════"
log_info "✓ All upgrades completed!"
log_info "═══════════════════════════════════════"
echo ""
log_info "Run 'sudo apt upgrade' separately for apt-managed packages."
