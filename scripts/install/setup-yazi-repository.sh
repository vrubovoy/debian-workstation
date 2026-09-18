#!/usr/bin/env bash

# =============================================================================
# Yazi APT repository
# =============================================================================
#
# Installs the official Yazi signing key and stable APT repository.
#
# =============================================================================

set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"

KEY_URL="https://yazi-rs.github.io/builds/yazi-keyring.gpg"
KEY_PATH="/usr/share/keyrings/yazi-keyring.gpg"

SOURCE_FILE="$ROOT_DIR/system/apt/sources/yazi.list"
SOURCE_PATH="/etc/apt/sources.list.d/yazi.list"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL "$KEY_URL" -o "$tmp"

sudo install \
    -Dm644 \
    "$tmp" \
    "$KEY_PATH"

sudo install \
    -Dm644 \
    "$SOURCE_FILE" \
    "$SOURCE_PATH"

sudo apt update