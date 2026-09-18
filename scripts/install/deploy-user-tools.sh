#!/usr/bin/env bash

# =============================================================================
# User command deployment
# =============================================================================
#
# Exposes repository-managed session helpers through ~/.local/bin and installs
# the Debian fd-find compatibility shim expected by Yazi and Fish functions.
#
# This script is intentionally safe to run repeatedly.
# =============================================================================

set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DIR"

link_command() {
    local source="$1"
    local target="$2"

    if [[ -e "$target" && ! -L "$target" ]]; then
        printf 'Refusing to replace non-symlink: %s\n' "$target" >&2
        return 1
    fi

    ln -sfn "$source" "$target"
}

link_command "$ROOT_DIR/scripts/session/wallpaper.sh"  "$BIN_DIR/workstation-wallpaper"
link_command "$ROOT_DIR/scripts/session/idle.sh"       "$BIN_DIR/workstation-idle"
link_command "$ROOT_DIR/scripts/session/lock.sh"       "$BIN_DIR/workstation-lock"
link_command "$ROOT_DIR/scripts/session/volume.sh"     "$BIN_DIR/workstation-volume"
link_command "$ROOT_DIR/scripts/session/brightness.sh" "$BIN_DIR/workstation-brightness"
link_command "$ROOT_DIR/scripts/session/media.sh"      "$BIN_DIR/workstation-media"
link_command "$ROOT_DIR/scripts/session/screenshot.sh" "$BIN_DIR/workstation-screenshot"
link_command "$ROOT_DIR/scripts/session/power-menu.sh" "$BIN_DIR/workstation-power-menu"

# Debian ships fd-find as /usr/bin/fdfind, while Yazi and the Fish helpers
# expect the upstream command name `fd`.
if command -v fd >/dev/null 2>&1; then
    :
elif [[ -x /usr/bin/fdfind ]]; then
    link_command /usr/bin/fdfind "$BIN_DIR/fd"
else
    printf 'Warning: neither fd nor /usr/bin/fdfind is available.\n' >&2
fi
