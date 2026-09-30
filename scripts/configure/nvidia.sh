#!/usr/bin/env bash
# The proprietary NVIDIA driver from packages/nvidia.txt, offered on machines
# with an NVIDIA GPU.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

# Vendor 0x10de with a display controller class (0x03....).
has_nvidia_gpu() {
    local device

    for device in /sys/bus/pci/devices/*; do
        if [[ "$(<"$device/vendor")" == 0x10de && "$(<"$device/class")" == 0x03* ]]; then
            return 0
        fi
    done

    return 1
}

# The fifth byte of the SecureBoot EFI variable is 1 when it is on.
secure_boot_enabled() {
    local variable=(/sys/firmware/efi/efivars/SecureBoot-*)

    [[ -r "${variable[0]}" && "$(od -An -tu1 -j4 -N1 -- "${variable[0]}" | tr -d ' ')" == 1 ]]
}

if ! has_nvidia_gpu; then
    info 'No NVIDIA GPU; driver skipped.'
    exit 0
fi

mapfile -t packages < <(manifest "$ROOT_DIR/packages/nvidia.txt")
missing=()

for package in "${packages[@]}"; do
    if [[ "$(dpkg-query -W -f='${db:Status-Abbrev}' "$package" 2>/dev/null)" != "ii " ]]; then
        missing+=("$package")
    fi
done

if (( ${#missing[@]} == 0 )); then
    info 'The NVIDIA driver is installed.'
else
    ask 'Install the proprietary NVIDIA driver?' || exit 0

    sudo apt-get install -y "${packages[@]}"

    # The driver blacklists nouveau, which the initramfs would otherwise load.
    sudo update-initramfs -u

    if secure_boot_enabled; then
        warn 'Secure Boot is on; enroll the DKMS key, see docs/TROUBLESHOOTING.md.'
    fi
fi

sudo systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
