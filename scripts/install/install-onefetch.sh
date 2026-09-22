#!/usr/bin/env bash

# =============================================================================
# Onefetch installer
# =============================================================================
#
# Installs the pinned Onefetch Debian package from the official GitHub release.
#
# The pinned version is read from packages/external.txt so the manifest remains
# the single source of truth for the workstation release.
#
# Onefetch currently publishes a Debian package for amd64. Other architectures
# are rejected explicitly rather than silently installing a different artifact.
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Repository / version
# =============================================================================

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
EXTERNAL_MANIFEST="$ROOT_DIR/packages/external.txt"

ONEFETCH_VERSION="$(
    awk '$1 == "onefetch" { print $2; exit }' "$EXTERNAL_MANIFEST"
)"

if [[ -z "$ONEFETCH_VERSION" ]]; then
    printf 'Onefetch version is missing from: %s\n' "$EXTERNAL_MANIFEST" >&2
    exit 1
fi


# =============================================================================
# Dependencies
# =============================================================================

for command in curl dpkg dpkg-deb sudo; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Required command is missing: %s\n' "$command" >&2
        exit 1
    fi
done


# =============================================================================
# Architecture
# =============================================================================

architecture="$(dpkg --print-architecture)"

if [[ "$architecture" != "amd64" ]]; then
    printf 'Onefetch .deb installation currently supports amd64 only.\n' >&2
    printf 'Detected architecture: %s\n' "$architecture" >&2
    exit 1
fi


# =============================================================================
# Existing installation
# =============================================================================

if command -v onefetch >/dev/null 2>&1; then
    installed_version="$(
        onefetch --version 2>/dev/null |
            awk '{ print $2 }' |
            head -n 1
    )"

    if [[ "$installed_version" == "$ONEFETCH_VERSION" ]]; then
        printf 'Onefetch %s is already installed.\n' "$ONEFETCH_VERSION"
        exit 0
    fi

    printf 'Installed Onefetch version: %s\n' "${installed_version:-unknown}"
    printf 'Requested Onefetch version: %s\n\n' "$ONEFETCH_VERSION"
fi


# =============================================================================
# Download
# =============================================================================

package="onefetch_amd64.deb"
url="https://github.com/o2sh/onefetch/releases/download/${ONEFETCH_VERSION}/${package}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

cd "$tmp_dir"

printf 'Downloading Onefetch %s...\n' "$ONEFETCH_VERSION"

curl \
    --fail \
    --location \
    --retry 3 \
    --retry-delay 2 \
    --output "$package" \
    "$url"


# =============================================================================
# Package validation
# =============================================================================
#
# The exact release URL is pinned and downloaded over HTTPS. Before handing the
# package to APT, also verify its Debian metadata matches the requested package,
# version and architecture.

package_name="$(dpkg-deb --field "$package" Package)"
package_version="$(dpkg-deb --field "$package" Version)"
package_architecture="$(dpkg-deb --field "$package" Architecture)"

if [[ "$package_name" != "onefetch" ]]; then
    printf 'Unexpected Debian package name: %s\n' "$package_name" >&2
    exit 1
fi

if [[ "$package_version" != "$ONEFETCH_VERSION" ]]; then
    printf 'Unexpected Onefetch package version: %s\n' "$package_version" >&2
    exit 1
fi

if [[ "$package_architecture" != "$architecture" ]]; then
    printf 'Unexpected Onefetch package architecture: %s\n' \
        "$package_architecture" >&2
    exit 1
fi


# =============================================================================
# Install
# =============================================================================

printf 'Installing Onefetch...\n'

sudo apt-get install -y "./${package}"

if ! command -v onefetch >/dev/null 2>&1; then
    printf 'Onefetch installation failed.\n' >&2
    exit 1
fi

printf '\nInstalled:\n\n'
onefetch --version
