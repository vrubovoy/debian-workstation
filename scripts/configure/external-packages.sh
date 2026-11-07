#!/usr/bin/env bash
# Optional upstream releases from packages/external.txt (amd64 builds), pinned
# by version and SHA-256 or following the latest GitHub release. Installed ones
# are brought to that version; the others are offered one by one.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

# Versions of the .tar.gz installs, which nothing else records.
STATE_DIR="/etc/debian-workstation/releases"

installed_version() {
    local package="$1" url="$2"

    if [[ "$url" == *.deb ]]; then
        dpkg-query -W -f='${db:Status-Abbrev}${Version}' "$package" 2>/dev/null | sed -n 's/^ii //p' || true
    elif [[ "$url" == *.run ]]; then
        # Recorded by the Qt installer, also for a copy installed by hand.
        sed -n 's:.*<Version>\(.*\)</Version>.*:\1:p' "/opt/$package/components.xml" 2>/dev/null |
            head -n 1 || true
    elif [[ -d "/opt/$package" && -f "$STATE_DIR/$package" ]]; then
        cat -- "$STATE_DIR/$package"
    fi
}

# A "latest" entry: the newest GitHub release. Its tag replaces {version} in the
# URL, and its SHA-256 is the digest GitHub publishes for the file.
resolve_latest() {
    local repo release

    repo="$(sed -nE 's#^https://github.com/([^/]+/[^/]+)/releases/.*#\1#p' <<< "$url")"
    release="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest")" || return 1

    version="$(jq -r .tag_name <<< "$release")"
    url="${url//\{version\}/$version}"
    sha256="$(jq -r --arg name "${url##*/}" \
        '.assets[] | select(.name == $name) | .digest // ""' <<< "$release")"
    sha256="${sha256#sha256:}"

    [[ -n "$sha256" ]]
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
        die "$url does not match its SHA-256."

    if [[ "$url" == *.deb ]]; then
        sudo apt-get install -y "$file"
        return
    fi

    if [[ "$url" == *.tar.gz ]]; then
        # A release archive (Neovim) replaces the previous one in /opt; its
        # command goes into /usr/local/bin, ahead of Debian's in PATH.
        sudo rm -rf "/opt/$package"
        sudo mkdir -p "/opt/$package"
        sudo tar -xzf "$file" -C "/opt/$package" --strip-components=1
        sudo ln -sfn "/opt/$package/bin/$package" "/usr/local/bin/$package"

        sudo mkdir -p "$STATE_DIR"
        printf '%s\n' "$version" | sudo tee "$STATE_DIR/$package" >/dev/null
    else
        # The Qt installer (AmneziaVPN) needs an empty directory, so an earlier
        # copy is removed with its own maintenance tool first.
        chmod +x "$file"

        if [[ -x "/opt/$package/maintenancetool" ]]; then
            sudo env QT_QPA_PLATFORM=offscreen "/opt/$package/maintenancetool" purge \
                --accept-licenses --accept-messages --confirm-command
        fi

        sudo env QT_QPA_PLATFORM=offscreen "$file" install --root "/opt/$package" \
            --accept-licenses --accept-messages --confirm-command
    fi
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

    if [[ "$version" == latest ]] && ! resolve_latest; then
        warn "No latest release of $package found on GitHub; skipped."
        continue
    fi

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
