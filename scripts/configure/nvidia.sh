#!/usr/bin/env bash
# The proprietary NVIDIA driver from packages/nvidia.txt, offered on machines
# with an NVIDIA GPU.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

# The vendor IDs of the display controllers (PCI class 0x03....).
gpu_vendors() {
    local device

    for device in /sys/bus/pci/devices/*; do
        [[ -r "$device/class" && "$(<"$device/class")" == 0x03* ]] || continue
        printf '%s\n' "$(<"$device/vendor")"
    done
}

# The fifth byte of the SecureBoot EFI variable is 1 when it is on.
secure_boot_enabled() {
    local variable=(/sys/firmware/efi/efivars/SecureBoot-*)

    [[ -r "${variable[0]}" && "$(od -An -tu1 -j4 -N1 -- "${variable[0]}" | tr -d ' ')" == 1 ]]
}

mapfile -t vendors < <(gpu_vendors)

if [[ " ${vendors[*]} " != *" 0x10de "* ]]; then
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
    exit 0
fi

# Next to integrated graphics, nouveau can power an idle NVIDIA card off; the
# proprietary driver cannot on cards older than Turing.
default=yes
(( ${#vendors[@]} == 1 )) || default=no

ask 'Install the proprietary NVIDIA driver?' "$default" || exit 0

sudo apt-get install -y "${packages[@]}"
sudo systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service

# The driver blacklists nouveau, which the initramfs would otherwise load.
sudo update-initramfs -u

if secure_boot_enabled; then
    warn 'Secure Boot is on; enroll the DKMS key with mokutil --import /var/lib/dkms/mok.pub.'
fi
