#!/usr/bin/env bash

# =============================================================================
# Debian APT repositories
# =============================================================================
#
# Installs the repository-managed Debian 13 deb822 source definition.
#
# The original /etc/apt/sources.list.d/debian.sources is backed up once before
# replacement. Legacy /etc/apt/sources.list entries are not modified silently;
# if active Debian archive entries are found there, the script stops so the
# operator can resolve the ambiguity explicitly.
# =============================================================================

set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE="$ROOT_DIR/system/apt/sources/debian.sources"
TARGET="/etc/apt/sources.list.d/debian.sources"
BACKUP="${TARGET}.debian-workstation.bak"

if [[ ! -f "$SOURCE" ]]; then
    printf 'Debian repository definition is missing: %s\n' "$SOURCE" >&2
    exit 1
fi

# Debian 13 normally uses debian.sources. Do not create duplicate archive
# definitions by silently retaining active legacy Debian entries.
if [[ -f /etc/apt/sources.list ]] && \
   grep -Eq '^[[:space:]]*deb[[:space:]].*(deb\.debian\.org|security\.debian\.org|ftp\.[^[:space:]]*\.debian\.org)' \
       /etc/apt/sources.list; then
    printf 'Active Debian archive entries were found in /etc/apt/sources.list.\n' >&2
    printf 'Disable/migrate those legacy entries before running the installer.\n' >&2
    exit 1
fi

if [[ -e "$TARGET" && ! -e "$BACKUP" ]]; then
    printf 'Backing up %s -> %s\n' "$TARGET" "$BACKUP"
    sudo cp -a -- "$TARGET" "$BACKUP"
fi

sudo install -Dm644 -- "$SOURCE" "$TARGET"

printf 'Debian APT repositories configured.\n'
