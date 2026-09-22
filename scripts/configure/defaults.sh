#!/usr/bin/env bash

# =============================================================================
# User defaults
# =============================================================================
#
# Applies workstation defaults which are user state rather than dotfiles:
#
#   - XDG user directories;
#   - Thunar as the default directory handler;
#   - Firefox ESR as the default web browser;
#   - Fish as the login shell.
#
# The script is safe to execute repeatedly.
# =============================================================================

set -Eeuo pipefail

CURRENT_USER="$(id -un)"


# =============================================================================
# XDG directories
# =============================================================================

if command -v xdg-user-dirs-update >/dev/null 2>&1; then
    xdg-user-dirs-update
fi


# =============================================================================
# Default applications
# =============================================================================

if command -v xdg-mime >/dev/null 2>&1; then
    xdg-mime default thunar.desktop inode/directory

    xdg-mime default firefox-esr.desktop text/html
    xdg-mime default firefox-esr.desktop x-scheme-handler/http
    xdg-mime default firefox-esr.desktop x-scheme-handler/https
fi


# =============================================================================
# Login shell
# =============================================================================

fish_path="$(command -v fish || true)"

if [[ -z "$fish_path" ]]; then
    printf 'Fish is not installed; login shell was not changed.\n' >&2
    exit 1
fi

current_shell="$(getent passwd "$CURRENT_USER" | cut -d: -f7)"

if [[ "$current_shell" != "$fish_path" ]]; then
    printf 'Setting login shell to %s...\n' "$fish_path"
    sudo chsh -s "$fish_path" "$CURRENT_USER"
else
    printf 'Fish is already the login shell.\n'
fi

printf 'User defaults configured successfully.\n'
