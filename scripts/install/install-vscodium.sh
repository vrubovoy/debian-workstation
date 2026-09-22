#!/usr/bin/env bash

# =============================================================================
# VSCodium installer
# =============================================================================
#
# Installs a pinned VSCodium release directly from the official GitHub
# Releases page.
#
# The workstation deliberately does not depend on the VSCodium APT repository.
# This keeps installation reproducible and avoids relying on an additional
# package mirror.
#
# Supported Debian architectures:
#
#   amd64
#   arm64
#   armhf
#
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Repository / version
# =============================================================================

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
EXTERNAL_MANIFEST="$ROOT_DIR/packages/external.txt"

VSCODIUM_VERSION="$(
    awk '$1 == "vscodium" { print $2; exit }' "$EXTERNAL_MANIFEST"
)"

if [[ -z "$VSCODIUM_VERSION" ]]; then
    printf 'VSCodium version is missing from: %s\n' "$EXTERNAL_MANIFEST" >&2
    exit 1
fi


# =============================================================================
# Dependencies
# =============================================================================

for command in curl sha256sum dpkg sudo; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Required command is missing: %s\n' "$command" >&2
        exit 1
    fi
done


# =============================================================================
# Architecture
# =============================================================================

architecture="$(dpkg --print-architecture)"

case "$architecture" in
    amd64|arm64|armhf)
        ;;
    *)
        printf 'Unsupported architecture: %s\n' "$architecture" >&2
        exit 1
        ;;
esac


# =============================================================================
# Package
# =============================================================================

package="codium_${VSCODIUM_VERSION}_${architecture}.deb"

base_url="https://github.com/VSCodium/vscodium/releases/download/${VSCODIUM_VERSION}"

package_url="${base_url}/${package}"
checksum_url="${package_url}.sha256"


# =============================================================================
# Existing installation
# =============================================================================

if command -v codium >/dev/null 2>&1; then
    installed_version="$(
        dpkg-query \
            -W \
            -f='${Version}' \
            codium \
            2>/dev/null || true
    )"

    if [[ "$installed_version" == "$VSCODIUM_VERSION" ]]; then
        printf 'VSCodium %s is already installed.\n' "$VSCODIUM_VERSION"
        exit 0
    fi

    printf 'Installed VSCodium version: %s\n' "${installed_version:-unknown}"
    printf 'Requested VSCodium version: %s\n\n' "$VSCODIUM_VERSION"
fi


# =============================================================================
# Temporary workspace
# =============================================================================

tmp_dir="$(mktemp -d)"

cleanup()
{
    rm -rf "$tmp_dir"
}

trap cleanup EXIT


cd "$tmp_dir"


# =============================================================================
# Download
# =============================================================================

printf 'Downloading VSCodium %s for %s...\n' \
    "$VSCODIUM_VERSION" \
    "$architecture"

curl \
    --fail \
    --location \
    --retry 3 \
    --retry-delay 2 \
    --output "$package" \
    "$package_url"

curl \
    --fail \
    --location \
    --retry 3 \
    --retry-delay 2 \
    --output "${package}.sha256" \
    "$checksum_url"


# =============================================================================
# Verify
# =============================================================================

printf 'Verifying package checksum...\n'

sha256sum --check "${package}.sha256"


# =============================================================================
# Install
# =============================================================================
#
# apt is deliberately used instead of dpkg -i so package dependencies are
# resolved automatically.

printf 'Installing VSCodium...\n'

sudo apt-get install -y "./${package}"


# =============================================================================
# Verify installation
# =============================================================================

if ! command -v codium >/dev/null 2>&1; then
    printf 'VSCodium installation failed: codium command is unavailable.\n' >&2
    exit 1
fi


printf '\nInstalled:\n\n'
codium --version | head -n 1