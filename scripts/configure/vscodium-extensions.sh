#!/usr/bin/env bash
# Offer the extensions from packages/vscodium-extensions.txt that are not
# installed yet, one by one. VSCodium installs them from Open VSX.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

if ! command -v codium >/dev/null; then
    info 'VSCodium is not installed; no extensions to offer.'
    exit 0
fi

declare -A installed=()
missing=()

while read -r extension; do
    installed["${extension,,}"]=1
done < <(codium --list-extensions 2>/dev/null)

while read -r extension; do
    [[ -n "${installed["${extension,,}"]:-}" ]] || missing+=("$extension")
done < <(manifest "$ROOT_DIR/packages/vscodium-extensions.txt")

if (( ${#missing[@]} == 0 )); then
    info 'VSCodium extensions are installed.'
    exit 0
fi

ask "Review ${#missing[@]} VSCodium extensions that are not installed?" || exit 0

for extension in "${missing[@]}"; do
    ask "Install $extension?" || continue

    codium --install-extension "$extension" ||
        warn "$extension failed to install; it may be missing from Open VSX."
done
