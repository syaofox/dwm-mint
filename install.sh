#!/bin/bash
[[ $EUID -eq 0 ]] && err "Please do not run this script as root. Use a regular user account with sudo privileges."

source "$(dirname "${BASH_SOURCE[0]}")/setup/utils.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to ask user what to do on failure
ask_on_failure() {
    local step_name="$1"
    log_error "${step_name} failed"
    echo ""
    log_info "What would you like to do?"
    echo "  [r] Retry this step"
    echo "  [s] Skip this step"
    echo "  [e] Exit installation"
    echo ""
    read -p "Enter your choice [r/s/e]: " choice

    case $choice in
        r|R) return 1 ;;
        s|S) log_info "Skipping: ${step_name}"; echo ""; return 0 ;;
        e|E) log_info "Exiting installation..."; exit 1 ;;
        *) echo "Invalid choice. Please try again."; ask_on_failure "$step_name" ;;
    esac
}

# Function to run a step with error handling
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


run_step "Uninstall LibreOffice" "./setup/uninstall-libreOffice.sh"
run_step "Optimize system services" "./setup/optimize_services.sh"
run_step "Upgrade system dependencies" "./setup/upgrade-deps.sh"
run_step "Install system dependencies" "./setup/install-deps.sh"
run_step "Create common directories" "./setup/install-directories.sh"

run_step "Install GSettings and xsettings daemon" "./setup/install-gsettings.sh"
run_step "Install fcitx5" "./setup/install-fcitx5.sh"
run_step "Install Neovim" "./setup/install-neovim.sh"
# run_step "Install wezterm" "./setup/install-wezterm.sh"
run_step "Install kitty" "./setup/install-kitty.sh"
# run_step "Install xfce4-terminal" "./setup/install-xfce4-terminal.sh"
run_step "Install Visual Studio Code" "./setup/install-vscode.sh"
# run_step "Install Brave Browser" "./setup/install-brave.sh"
run_step "Install Brave Browser Origin" "./setup/install-brave-origin-nightly.sh"
run_step "Install Docker and Docker Compose" "./setup/install-docker.sh"
run_step "Install lazydocker" "./setup/install-lazydocker.sh"
run_step "Install uv Python package manager" "./setup/install-uv.sh"
run_step "Install Node.js via nvm" "./setup/install-nodejs.sh"
run_step "Install opencode" "./setup/install-opencode.sh"

run_step "Install fzf" "./setup/install-fzf.sh" 
run_step "Install fd-find" "./setup/install-fd.sh"
run_step "Install rofi" "./setup/install-rofi.sh"
run_step "Install yazi" "./setup/install-yazi.sh"

run_step "Compile and install DWM" "./setup/install-dwm.sh"
run_step "Compile and install slstatus" "./setup/install-slstatus.sh"
run_step "Compile and install slock" "./setup/install-slock.sh"
run_step "Compile and install wallpick" "./setup/install-wallpick.sh"

run_step "Install fonts" "./setup/install-fonts.sh"


run_step "Update bashrc" "./setup/update-bashrc.sh"
run_step "Deploy configuration files" "./setup/deploy-dotfiles.sh"
run_step "Generate DWM desktop entry" "./setup/generate-dwm-desktop.sh"
run_step "Update user groups" "./setup/update-usergroup.sh"
run_step "Install fish shell" "./setup/install-fish.sh"




echo ""
log_info "═══════════════════════════════════════"
log_info "✓ All installation steps completed!"
log_info "═══════════════════════════════════════"
echo ""
log_info "Please reboot your system to apply all changes."

