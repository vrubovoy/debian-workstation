#!/usr/bin/env bash
# ******************************************************************************
# @file    external-packages.sh
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Installs and updates the releases from packages/external.txt.
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

# Versions of the archive installs, which nothing else records.
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

# A version without a leading "v", Debian epoch or revision, so that GitHub tags
# and dpkg versions compare.
plain_version() {
    local version="${1#v}"

    version="${version#*:}"
    printf '%s\n' "${version%-*}"
}

# Fills in the newest GitHub release: tag, URL and the SHA-256 GitHub publishes.
resolve_latest() {
    local repo release tag

    repo="$(sed -nE 's#^https://github.com/([^/]+/[^/]+)/releases/.*#\1#p' <<< "$url")"
    release="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest")" || return 1

    tag="$(jq -r .tag_name <<< "$release")"
    version="${tag#v}"
    url="${url//\{tag\}/$tag}"
    url="${url//\{version\}/$version}"
    sha256="$(jq -r --arg name "${url##*/}" \
        '.assets[] | select(.name == $name) | .digest // ""' <<< "$release")"
    sha256="${sha256#sha256:}"

    [[ -n "$sha256" ]]
}

install_release() {
    local package="$1" version="$2" sha256="$3" url="$4" depends="$5"
    local file="$TMP_DIR/${url##*/}" deps=()
    local stage previous binary

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

    if [[ "$url" == *.tar.gz || "$url" == *.tar.xz ]]; then
        # The command, in bin/ (Neovim) or at the top (Telegram), is linked
        # into /usr/local/bin, ahead of Debian's in PATH.
        stage="$(sudo mktemp -d "/opt/.${package}.XXXXXX")"
        previous="${stage}.previous"
        if ! sudo tar -xf "$file" -C "$stage" --strip-components=1; then
            sudo rm -rf -- "$stage"
            die "Could not unpack $package; the installed version was kept."
        fi

        binary="bin/$package"
        [[ -x "$stage/$binary" ]] || binary="$package"
        if [[ ! -x "$stage/$binary" ]]; then
            sudo rm -rf -- "$stage"
            die "No executable for $package in the release archive."
        fi

        if [[ -e "/opt/$package" ]]; then
            sudo mv -- "/opt/$package" "$previous"
        fi
        if ! sudo mv -- "$stage" "/opt/$package"; then
            [[ ! -e "$previous" ]] || sudo mv -- "$previous" "/opt/$package"
            die "Could not activate $package; the installed version was restored."
        fi
        sudo ln -sfn "/opt/$package/$binary" "/usr/local/bin/$package"

        sudo mkdir -p "$STATE_DIR"
        printf '%s\n' "$version" | sudo tee "$STATE_DIR/$package" >/dev/null
        [[ ! -e "$previous" ]] || sudo rm -rf -- "$previous"
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

    if [[ -n "$current" && "$(plain_version "$current")" == "$(plain_version "$version")" ]]; then
        info "$package $version is installed."
        continue
    fi

    if [[ -z "$current" ]] && ! ask "Install $package $version?"; then
        continue
    fi

    install_release "$package" "$version" "$sha256" "$url" "$depends"
done
