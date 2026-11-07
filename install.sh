#!/usr/bin/env bash
# ******************************************************************************
# @file    install.sh
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Installs and configures the workstation; safe to run again.
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/scripts/lib/common.sh"

case "${1:-}" in
    "")
        ;;
    -h|--help)
        printf 'Usage: ./install.sh\n\nInstalls and configures the workstation.\n'
        exit 0
        ;;
    *)
        printf 'Usage: ./install.sh\n' >&2
        exit 2
        ;;
esac

[[ $EUID -ne 0 ]] || die 'Run install.sh as your normal user, not as root.'

# shellcheck source=/dev/null
source /etc/os-release

if [[ "${ID:-}" != debian || "${VERSION_ID:-}" != 13 ]]; then
    die "Debian 13 is required; this is ${PRETTY_NAME:-an unknown system}."
fi

command -v sudo >/dev/null || die 'sudo is not installed; install it as root and add yourself to the sudo group.'

sudo "$ROOT_DIR/scripts/install/system.sh" "$(id -un)"
"$ROOT_DIR/scripts/install/user.sh"

step 'Personal setup'
"$ROOT_DIR/scripts/configure/git.sh"
"$ROOT_DIR/scripts/configure/ssh.sh"
"$ROOT_DIR/scripts/configure/nvidia.sh"
"$ROOT_DIR/scripts/configure/external-packages.sh"
"$ROOT_DIR/scripts/configure/neovim.sh"
[[ -e "$FIREFOX_SELECTION" ]] || "$ROOT_DIR/scripts/configure/firefox-extensions.sh"
"$ROOT_DIR/scripts/configure/vscodium-extensions.sh"

step 'Done'
info 'Reboot to start LightDM and i3 with the new configuration.'

if ask 'Reboot now?' no; then
    sudo systemctl reboot
fi
