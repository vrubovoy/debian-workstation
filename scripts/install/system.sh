#!/usr/bin/env bash
# System part of the installer; install.sh runs it once through sudo:
#
#   sudo scripts/install/system.sh [USER]
#
# Files under system/ are copied to the same path under /. A replaced file is
# kept once as *.debian-workstation.bak.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

YAZI_KEY_URL="https://yazi-rs.github.io/builds/yazi-keyring.gpg"

backup_once() {
    if [[ -e "$1" && ! -e "$1$BACKUP_SUFFIX" ]]; then
        cp -a -- "$1" "$1$BACKUP_SUFFIX"
    fi
}

deploy() {
    backup_once "$2"
    install -Dm644 -- "$1" "$2"
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

install_releases() {
    local arch package version arches url file

    arch="$(dpkg --print-architecture)"

    while read -r package version arches url; do
        if [[ ",$arches," != *",$arch,"* ]]; then
            warn "$package has no $arch build; skipped."
            continue
        fi

        if [[ "$(dpkg-query -W -f='${db:Status-Abbrev}${Version}' "$package" 2>/dev/null)" == "ii $version" ]]; then
            info "$package $version is already installed."
            continue
        fi

        url="${url//\{version\}/$version}"
        url="${url//\{arch\}/$arch}"
        file="$TMP_DIR/${url##*/}"

        info "Downloading $package $version"
        curl -fL --retry 3 -o "$file" "$url"

        # VSCodium publishes a checksum next to each package; Onefetch does not.
        if curl -fsL -o "$file.sha256" "$url.sha256"; then
            (cd "$TMP_DIR" && sha256sum --check --quiet "${file##*/}.sha256")
        fi

        if [[ "$(dpkg-deb -f "$file" Package)" != "$package" ||
              "$(dpkg-deb -f "$file" Version)" != "$version" ]]; then
            die "$url does not contain $package $version."
        fi

        apt-get install -y "$file"
    done < <(manifest "$ROOT_DIR/packages/external.txt")
}

deploy_files() {
    local source

    while IFS= read -r -d '' source; do
        deploy "$source" "/${source#"$ROOT_DIR/system/"}"
    done < <(find "$ROOT_DIR/system" -type f -print0)

    # The deployed policies also carry the extensions selected on this machine.
    render_firefox_policies > "$TMP_DIR/policies.json"
    install -m644 "$TMP_DIR/policies.json" /etc/firefox/policies/policies.json
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

    # Lets APT's unprivileged _apt user read the downloaded packages.
    chmod 755 "$TMP_DIR"

    step 'APT repositories'
    setup_repositories

    step 'Packages'
    install_packages

    step 'Pinned releases'
    install_releases

    step 'System files'
    deploy_files

    step 'Services'
    enable_services

    step "Login shell for $user"
    set_login_shell "$user"
}

# Sourcing only defines the steps; CI uses that to check the package lists.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
