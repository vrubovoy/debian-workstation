#!/usr/bin/env bash

# =============================================================================
# VSCodium extensions
# =============================================================================
#
# Installs extensions listed in:
#
#   packages/vscodium-extensions.txt
#
# Each extension is offered individually.
#
# This intentionally preserves the interactive behaviour of the previous
# workstation bootstrap instead of installing every extension automatically.
#
# VSCodium uses Open VSX as its default extension registry.
#
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Repository
# =============================================================================

SCRIPT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
    pwd
)"

ROOT_DIR="$(
    cd -- "$SCRIPT_DIR/../.."
    pwd
)"

EXTENSIONS_FILE="$ROOT_DIR/packages/vscodium-extensions.txt"


# =============================================================================
# Dependencies
# =============================================================================

if ! command -v codium >/dev/null 2>&1; then
    printf 'VSCodium is not installed.\n' >&2
    exit 1
fi

if [[ ! -f "$EXTENSIONS_FILE" ]]; then
    printf 'Extension list is missing:\n\n'
    printf '  %s\n' "$EXTENSIONS_FILE" >&2
    exit 1
fi


# =============================================================================
# Existing extensions
# =============================================================================

mapfile -t installed_extensions < <(
    codium --list-extensions 2>/dev/null |
        tr '[:upper:]' '[:lower:]'
)


is_installed()
{
    local extension="$1"
    local installed

    extension="${extension,,}"

    for installed in "${installed_extensions[@]}"; do
        if [[ "$installed" == "$extension" ]]; then
            return 0
        fi
    done

    return 1
}


# =============================================================================
# Installation
# =============================================================================

while IFS= read -r extension || [[ -n "$extension" ]]; do

    # Remove CR in case the file was edited on another platform.
    extension="${extension%$'\r'}"

    # Skip comments and blank lines.
    [[ -z "$extension" ]] && continue
    [[ "$extension" == \#* ]] && continue


    printf '\n%s\n' "$extension"


    if is_installed "$extension"; then
        printf 'Already installed.\n'
        continue
    fi


    read -r -p "Install this extension? [Y/n] " answer </dev/tty

    case "${answer,,}" in
        ""|y|yes)
            if codium --install-extension "$extension"; then
                printf 'Installed: %s\n' "$extension"

                installed_extensions+=("${extension,,}")
            else
                printf '\nWARNING: Failed to install: %s\n' "$extension" >&2
                printf 'The extension may not be available from Open VSX.\n' >&2
            fi
            ;;

        *)
            printf 'Skipped.\n'
            ;;
    esac

done < "$EXTENSIONS_FILE"


printf '\nVSCodium extension setup complete.\n'