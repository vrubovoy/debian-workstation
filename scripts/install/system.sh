#!/usr/bin/env bash
# System part of the installer; install.sh runs it once through sudo:
#
#   sudo scripts/install/system.sh [USER]
#
# Files under system/ are copied to the same path under /. The system's own
# version of a replaced file is kept as *.debian-workstation.bak.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

YAZI_KEY_URL="https://yazi-rs.github.io/builds/yazi-keyring.gpg"
MANAGED_FILES="/etc/debian-workstation/managed-files"

backup_once() {
    if [[ -e "$1" && ! -e "$1$BACKUP_SUFFIX" ]]; then
        cp -a -- "$1" "$1$BACKUP_SUFFIX"
    fi
}

# Only the first deployment of a path backs it up and records it in
# $MANAGED_FILES, so a backup is always the system's own version, never an
# earlier copy from this repository.
deploy() {
    local source="$1" target="$2"

    if ! grep -qxF -- "$target" "$MANAGED_FILES" 2>/dev/null; then
        backup_once "$target"
        mkdir -p "$(dirname -- "$MANAGED_FILES")"
        printf '%s\n' "$target" >> "$MANAGED_FILES"
    fi

    install -Dm644 -- "$source" "$target"
}

setup_repositories() {
    local sources="$ROOT_DIR/system/etc/apt/sources.list.d"
    local legacy=/etc/apt/sources.list
    local debian_entry='^[[:space:]]*deb(-src)?[[:space:]].*(deb\.debian\.org|security\.debian\.org|ftp\.[^[:space:]]*\.debian\.org)'

    # The managed sources use HTTPS, so APT needs CA certificates first; get
    # them from the sources the system was installed with.
    apt-get update
    apt-get install -y ca-certificates curl

    # debian.sources replaces the Debian entries of an old one-line
    # sources.list; comment them out so APT does not read both. Other entries stay.
    if grep -Eqs "$debian_entry" "$legacy"; then
        backup_once "$legacy"
        sed -Ei "/$debian_entry/s/^/# /" "$legacy"
    fi

    deploy "$sources/debian.sources" /etc/apt/sources.list.d/debian.sources
    curl -fsSL -o /usr/share/keyrings/yazi-keyring.gpg "$YAZI_KEY_URL"
    deploy "$sources/yazi.list" /etc/apt/sources.list.d/yazi.list
    apt-get update
}

# Extra arguments go to apt-get; CI passes --simulate.
# shellcheck disable=SC2120
install_packages() {
    local packages

    mapfile -t packages < <(
        manifest "$ROOT_DIR"/packages/{base,desktop,applications,development}.txt
    )

    apt-get install -y "$@" "${packages[@]}"
}

deploy_files() {
    local source target

    while IFS= read -r -d '' source; do
        target="/${source#"$ROOT_DIR/system/"}"

        case "$target" in
            # Deployed before the packages by setup_repositories.
            /etc/apt/*)
                continue
                ;;
            # Also carries the extensions selected on this machine.
            /etc/firefox-esr/policies/policies.json)
                source="$TMP_DIR/policies.json"
                render_firefox_policies > "$source"
                ;;
        esac

        deploy "$source" "$target"
    done < <(find "$ROOT_DIR/system" -type f -print0)
}

setup_boot_menu() {
    command -v update-grub >/dev/null || return 0

    magick "$ROOT_DIR/assets/wallpapers/default.jpg" -resize 1920x1080^ -gravity center \
        -extent 1920x1080 -interlace none -quality 90 /boot/grub/workstation.jpg
    update-grub
}

# Enabled for the next boot only: restarting networking or the display
# manager here would cut off the running installation.
enable_services() {
    systemctl enable NetworkManager.service bluetooth.service lightdm.service
}

set_login_shell() {
    local user="$1" fish

    fish="$(command -v fish)"

    if [[ "$(getent passwd "$user" | cut -d: -f7)" != "$fish" ]]; then
        chsh -s "$fish" "$user"
    fi
}

main() {
    local user="${1:-${SUDO_USER:-}}"

    [[ $EUID -eq 0 ]] || die 'Run as root: sudo scripts/install/system.sh [USER]'

    if [[ -z "$user" || "$user" == root ]] || ! id -u "$user" >/dev/null 2>&1; then
        die "Not a workstation user: '$user'."
    fi

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT

    step 'APT repositories'
    setup_repositories

    step 'Packages'
    install_packages

    step 'System files'
    deploy_files

    step 'Boot menu'
    setup_boot_menu

    step 'Services'
    enable_services

    step "Login shell for $user"
    set_login_shell "$user"
}

# Sourcing only defines the steps; CI uses that to check the package lists.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
