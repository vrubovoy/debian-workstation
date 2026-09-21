#!/usr/bin/env bash

# =============================================================================
# VSCodium APT repository
# =============================================================================
#
# Installs the official VSCodium repository signing key and repository source.
#
# Supported target:
#
#   Debian 13
#
# The repository definition itself is stored under:
#
#   system/apt/sources/vscodium.sources
#
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Paths
# =============================================================================

SCRIPT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
    pwd
)"

ROOT_DIR="$(
    cd -- "$SCRIPT_DIR/../.."
    pwd
)"

SOURCE_FILE="$ROOT_DIR/system/apt/sources/vscodium.sources"

KEYRING="/usr/share/keyrings/vscodium.gpg"
APT_SOURCE="/etc/apt/sources.list.d/vscodium.sources"


# =============================================================================
# Dependencies
# =============================================================================

for command in curl gpg sudo; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'Required command is missing: %s\n' "$command" >&2
        exit 1
    fi
done


# =============================================================================
# Validate source file
# =============================================================================

if [[ ! -f "$SOURCE_FILE" ]]; then
    printf 'VSCodium repository definition is missing:\n\n'
    printf '  %s\n' "$SOURCE_FILE" >&2
    exit 1
fi


# =============================================================================
# Signing key
# =============================================================================

printf 'Installing VSCodium repository signing key...\n'

tmp_key="$(mktemp)"

trap 'rm -f "$tmp_key"' EXIT

curl -fsSL \
    https://repo.vscodium.dev/vscodium.gpg \
    -o "$tmp_key"

gpg --dearmor \
    --yes \
    --output "${tmp_key}.gpg" \
    "$tmp_key"

sudo install \
    -Dm644 \
    "${tmp_key}.gpg" \
    "$KEYRING"

rm -f "${tmp_key}.gpg"


# =============================================================================
# Repository
# =============================================================================

printf 'Installing VSCodium APT source...\n'

sudo install \
    -Dm644 \
    "$SOURCE_FILE" \
    "$APT_SOURCE"


# =============================================================================
# Update package metadata
# =============================================================================

sudo apt update


printf '\nVSCodium repository configured successfully.\n'