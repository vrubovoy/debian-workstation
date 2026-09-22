#!/usr/bin/env bash
# Optional upstream releases from packages/external.txt, pinned by version and
# SHA-256 (amd64 builds). Installed ones are brought to the pinned version; the
# others are offered one by one.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

# Versions of the .run installs, which dpkg does not know about.
STATE_DIR="/etc/debian-workstation/releases"

installed_version() {
    local package="$1" url="$2"

    if [[ "$url" == *.deb ]]; then
        dpkg-query -W -f='${db:Status-Abbrev}${Version}' "$package" 2>/dev/null | sed -n 's/^ii //p' || true
    elif [[ -d "/opt/$package" && -f "$STATE_DIR/$package" ]]; then
        cat -- "$STATE_DIR/$package"
    fi
}

install_release() {
    local package="$1" version="$2" sha256="$3" url="$4" depends="$5"
    local file="$TMP_DIR/${url##*/}" deps=()

    if [[ "$depends" != - ]]; then
        IFS=, read -ra deps <<< "$depends"
        sudo apt-get install -y "${deps[@]}"
    fi

    info "Downloading $package $version"
    curl -fL --retry 3 -o "$file" "$url"
    sha256sum --check --quiet <<< "$sha256  $file" ||
        die "$url does not match the SHA-256 pinned in packages/external.txt."

    if [[ "$url" == *.deb ]]; then
        sudo apt-get install -y "$file"
        return
    fi

    # A Qt installer (AmneziaVPN) will not install into a non-empty directory.
    # A copy already there, older or installed by hand, goes with its own
    # maintenance tool; then the new one installs headless into /opt.
    chmod +x "$file"

    if [[ -x "/opt/$package/maintenancetool" ]]; then
        sudo env QT_QPA_PLATFORM=offscreen "/opt/$package/maintenancetool" purge \
            --accept-licenses --accept-messages --confirm-command
    fi

    sudo env QT_QPA_PLATFORM=offscreen "$file" install --root "/opt/$package" \
        --accept-licenses --accept-messages --confirm-command

    sudo mkdir -p "$STATE_DIR"
    printf '%s\n' "$version" | sudo tee "$STATE_DIR/$package" >/dev/null
}

if [[ "$(dpkg --print-architecture)" != amd64 ]]; then
    info 'The optional releases are amd64 builds; skipped.'
    exit 0
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Lets APT's unprivileged _apt user read the downloaded packages.
chmod 755 "$TMP_DIR"

mapfile -t releases < <(manifest "$ROOT_DIR/packages/external.txt")

for release in "${releases[@]}"; do
    read -r package version sha256 url depends <<< "$release"
    current="$(installed_version "$package" "$url")"

    if [[ "$current" == "$version" ]]; then
        info "$package $version is installed."
        continue
    fi

    if [[ -z "$current" ]] && ! ask "Install $package $version?"; then
        continue
    fi

    install_release "$package" "$version" "$sha256" "$url" "$depends"
done
