#!/usr/bin/env bash

# =============================================================================
# X11 input configuration
# =============================================================================
#
# Installs the workstation's persistent libinput configuration for X.Org.
#
# The configuration applies to device classes rather than specific hardware
# names and therefore survives replacement of the physical mouse or touchpad.
#
# A full X11 session restart is required after changing this configuration.
#
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Repository
# =============================================================================

SCRIPT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
    pwd
)"

ROOT_DIR="$(
    cd -- "$SCRIPT_DIR/../.."
    pwd
)"


SOURCE="$ROOT_DIR/system/x11/xorg.conf.d/90-workstation-input.conf"
TARGET="/etc/X11/xorg.conf.d/90-workstation-input.conf"


# =============================================================================
# Validation
# =============================================================================

if [[ ! -f "$SOURCE" ]]; then
    printf 'Input configuration is missing:\n\n' >&2
    printf '  %s\n' "$SOURCE" >&2
    exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
    printf 'Required command is missing: sudo\n' >&2
    exit 1
fi


# =============================================================================
# Install
# =============================================================================

printf 'Installing X11 input configuration...\n'

sudo install \
    -Dm644 \
    "$SOURCE" \
    "$TARGET"


printf '\nInstalled:\n\n'
printf '  %s\n\n' "$TARGET"

printf 'Restart the graphical X11 session before testing the new settings.\n'