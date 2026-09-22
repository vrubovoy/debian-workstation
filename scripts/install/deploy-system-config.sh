#!/usr/bin/env bash

# =============================================================================
# System configuration deployment
# =============================================================================
#
# Installs repository-managed configuration into privileged system locations.
#
# Existing mutable system files which are replaced wholesale are backed up once
# with the suffix `.debian-workstation.bak` before the first replacement.
# Re-running the script is therefore safe and does not create backup chains.
# =============================================================================

set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"


backup_once()
{
    local target="$1"
    local backup="${target}.debian-workstation.bak"

    if [[ ! -e "$target" || -e "$backup" ]]; then
        return 0
    fi

    printf 'Backing up %s -> %s\n' "$target" "$backup"
    sudo cp -a -- "$target" "$backup"
}


install_file()
{
    local source="$1"
    local target="$2"

    sudo install -Dm644 -- "$source" "$target"
}


# =============================================================================
# Mutable base-system files
# =============================================================================

backup_once /etc/network/interfaces
backup_once /etc/default/keyboard

install_file \
    "$ROOT_DIR/system/network/interfaces" \
    /etc/network/interfaces

install_file \
    "$ROOT_DIR/system/etc/default/keyboard" \
    /etc/default/keyboard


# =============================================================================
# LightDM
# =============================================================================

install_file \
    "$ROOT_DIR/system/lightdm/lightdm-gtk-greeter.conf" \
    /etc/lightdm/lightdm-gtk-greeter.conf

install_file \
    "$ROOT_DIR/system/lightdm/themes/GraphiteBlue-LightDM/gtk-3.0/gtk.css" \
    /usr/share/themes/GraphiteBlue-LightDM/gtk-3.0/gtk.css


# =============================================================================
# Firefox
# =============================================================================

install_file \
    "$ROOT_DIR/system/firefox/policies.json" \
    /etc/firefox/policies/policies.json


# =============================================================================
# X11 / libinput
# =============================================================================
#
# Keep input deployment in its dedicated helper so manual reapplication and the
# full installer always use exactly the same code path.

"$ROOT_DIR/scripts/configure/input.sh"


# =============================================================================
# Services
# =============================================================================
#
# Enable the services for the next boot. They are intentionally not restarted
# here because changing networking/display-manager state underneath a running
# installation session would be disruptive.

sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service
sudo systemctl enable lightdm.service

printf '\nSystem configuration deployed successfully.\n'
