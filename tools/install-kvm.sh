#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../setup/utils.sh"

log_step "Installing KVM + QEMU virtualization tools..."

log_info "Checking CPU virtualization support..."
if egrep -c '(vmx|svm)' /proc/cpuinfo > /dev/null 2>&1; then
    VCPU=$(egrep -c '(vmx|svm)' /proc/cpuinfo)
    log_info "CPU virtualization supported: $VCPU CPU(s) with VT extensions"
else
    log_error "CPU virtualization not supported or not enabled in BIOS"
    exit 1
fi

log_info "Installing KVM and QEMU packages..."
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager

log_info "Adding current user to libvirt and kvm groups..."
sudo usermod -aG libvirt "$USER"
sudo usermod -aG kvm "$USER"

log_info "Configuring libvirt service..."
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

log_info "Verifying KVM installation..."
if sudo virsh list --all > /dev/null 2>&1; then
    log_info "Libvirt service is running correctly"
else
    log_error "Libvirt service verification failed"
    exit 1
fi

log_info "Checking KVM acceleration..."
if sudo kvm-ok 2>/dev/null || [ -e /dev/kvm ]; then
    log_info "KVM acceleration is available"
else
    log_warn "KVM acceleration may not be available"
fi

log_info "KVM + QEMU installation complete"
log_info "Note: You may need to log out and back in for group changes to take effect"
log_info "You can manage VMs with: virt-manager (GUI) or virsh (CLI)"

exit 0
