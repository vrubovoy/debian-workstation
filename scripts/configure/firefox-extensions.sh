#!/usr/bin/env bash

# =============================================================================
# Firefox extensions
# =============================================================================
#
# Offers the workstation's recommended Firefox extensions one by one.
#
# The script does not silently install browser extensions.
#
# When an extension is accepted, its addons.mozilla.org page is opened in
# Firefox ESR and Firefox performs the normal interactive installation.
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

EXTENSIONS_FILE="$ROOT_DIR/packages/firefox-extensions.txt"


# =============================================================================
# Dependencies
# =============================================================================

if ! command -v firefox-esr >/dev/null 2>&1; then
    printf 'Firefox ESR is not installed.\n' >&2
    exit 1
fi

if [[ ! -f "$EXTENSIONS_FILE" ]]; then
    printf 'Firefox extension list is missing:\n\n' >&2
    printf '  %s\n' "$EXTENSIONS_FILE" >&2
    exit 1
fi


# =============================================================================
# Interactive setup
# =============================================================================
#
# File descriptor 3 is used for the extension list so normal stdin remains
# connected to the terminal.
#
# This avoids the classic shell bug where read() consumes the next line of the
# input file instead of the user's answer.

while IFS='|' read -r name url <&3 || [[ -n "$name" ]]; do

    name="${name%$'\r'}"
    url="${url%$'\r'}"

    # Skip comments and blank lines.
    [[ -z "$name" ]] && continue
    [[ "$name" == \#* ]] && continue

    printf '\n%s\n' "$name"

    read -r -p "Open this extension for installation? [Y/n] " answer

    case "${answer,,}" in
        ""|y|yes)
            firefox-esr --new-tab "$url" >/dev/null 2>&1 &
            printf 'Opened in Firefox.\n'
            ;;

        *)
            printf 'Skipped.\n'
            ;;
    esac

done 3< "$EXTENSIONS_FILE"


printf '\nFirefox extension setup complete.\n'
printf 'Complete installation from the opened Firefox tabs.\n'