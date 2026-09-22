#!/usr/bin/env bash
# User part of the installer: dotfiles, workstation-* commands, default
# applications and GSettings. Runs as the normal user.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

DOTFILES_DIR="$ROOT_DIR/dotfiles"
BIN_DIR="$HOME/.local/bin"

# Every directory under dotfiles/ is a Stow package. Files already in the way
# are moved aside once. --no-folding links files, never directories, so
# private files created in ~/.ssh or ~/.gnupg cannot end up in the repository.
link_dotfiles() {
    local source target packages=()

    mkdir -p "$HOME/.ssh" "$HOME/.gnupg"
    chmod 700 "$HOME/.ssh" "$HOME/.gnupg"

    while IFS= read -r -d '' source; do
        target="$HOME/${source#"$DOTFILES_DIR"/*/}"

        if [[ -e "$target" || -L "$target" ]] &&
           [[ "$(readlink -f -- "$target")" != "$(readlink -f -- "$source")" ]]; then
            [[ ! -e "$target$BACKUP_SUFFIX" ]] ||
                die "$target is in the way and $target$BACKUP_SUFFIX already exists."

            info "Moving $target to $target$BACKUP_SUFFIX"
            mv -- "$target" "$target$BACKUP_SUFFIX"
        fi
    done < <(find "$DOTFILES_DIR" -mindepth 2 -type f -print0)

    for source in "$DOTFILES_DIR"/*/; do
        packages+=("$(basename -- "$source")")
    done

    stow --restow --no-folding --dir "$DOTFILES_DIR" --target "$HOME" "${packages[@]}"
}

# scripts/session/NAME.sh becomes ~/.local/bin/workstation-NAME.
link_commands() {
    local script target

    mkdir -p "$BIN_DIR"

    for script in "$ROOT_DIR"/scripts/session/*.sh; do
        target="$BIN_DIR/workstation-$(basename -- "$script" .sh)"

        [[ ! -e "$target" || -L "$target" ]] || die "$target exists and is not a symlink."
        ln -sfn -- "$script" "$target"
    done

    # Links to helpers removed from the repository.
    find "$BIN_DIR" -maxdepth 1 -name 'workstation-*' -xtype l -delete

    # Debian ships fd as `fdfind`; Yazi and the Fish functions call `fd`.
    if ! command -v fd >/dev/null && [[ -x /usr/bin/fdfind ]]; then
        ln -sfn /usr/bin/fdfind "$BIN_DIR/fd"
    fi
}

set_default_applications() {
    xdg-user-dirs-update
    xdg-mime default thunar.desktop inode/directory
    xdg-mime default firefox-esr.desktop text/html x-scheme-handler/http x-scheme-handler/https
}

apply_gsettings() {
    local schema="org.gnome.desktop.interface"

    gsettings set "$schema" color-scheme 'prefer-dark'
    gsettings set "$schema" gtk-theme 'Adwaita-dark'
    gsettings set "$schema" icon-theme 'Adwaita'
    gsettings set "$schema" cursor-theme 'Adwaita'
    gsettings set "$schema" cursor-size 24
    gsettings set "$schema" font-name 'Ubuntu Bold 13'
    gsettings set "$schema" monospace-font-name 'Ubuntu Mono Bold 13'
}

[[ $EUID -ne 0 ]] || die 'Run as the normal user, not root.'

step 'Dotfiles'
link_dotfiles

step 'Commands'
link_commands

step 'Default applications'
set_default_applications

step 'GSettings'
# dconf needs a session bus; on a TTY there may be none yet.
if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    apply_gsettings
else
    export -f apply_gsettings
    dbus-run-session -- bash -c apply_gsettings
fi
