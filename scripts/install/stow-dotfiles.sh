#!/usr/bin/env bash

# =============================================================================
# Dotfile deployment
# =============================================================================
#
# Deploys all managed user configuration with GNU Stow.
# Directory folding is deliberately disabled so runtime/private files cannot be
# redirected into the repository through a directory-level symlink.
# =============================================================================

set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
DOTFILES_DIR="$ROOT_DIR/dotfiles"

command -v stow >/dev/null 2>&1 || {
    printf 'GNU Stow is required. Install package: stow\n' >&2
    exit 1
}

# These directories can contain private or mutable data and must always remain
# real directories in the home directory.
mkdir -p "$HOME/.ssh" "$HOME/.gnupg"
chmod 700 "$HOME/.ssh" "$HOME/.gnupg"

packages=(
    codium
    dunst
    fastfetch
    fish
    git
    gnupg
    gtk
    i3
    i3status
    kitty
    nvim
    picom
    rofi
    ssh
    starship
    xsession
    yazi
)

for package in "${packages[@]}"; do
    stow --no-folding \
        --dir "$DOTFILES_DIR" \
        --target "$HOME" \
        "$package"
done
