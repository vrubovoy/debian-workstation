#!/usr/bin/env bash
# Choose the optional Firefox extensions listed in packages/firefox-extensions.txt.
#
# The choice is kept in /etc/debian-workstation/firefox-extensions and written
# into the Firefox policies: selected extensions are installed on the next
# Firefox start, deselected ones become ordinary removable extensions.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

command -v jq >/dev/null || die 'jq is not installed; run install.sh first.'

selected=()

while read -r id _ name; do
    default=yes

    if [[ -e "$FIREFOX_SELECTION" ]] && ! grep -qxF -- "$id" "$FIREFOX_SELECTION"; then
        default=no
    fi

    if ask "Install the Firefox extension $name?" "$default"; then
        selected+=("$id")
    fi
done < <(manifest "$ROOT_DIR/packages/firefox-extensions.txt")

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

sudo mkdir -p "$(dirname -- "$FIREFOX_SELECTION")"
printf '%s' "${selected[@]/%/$'\n'}" | sudo tee "$FIREFOX_SELECTION" >/dev/null

render_firefox_policies > "$tmp"
sudo install -Dm644 "$tmp" /etc/firefox-esr/policies/policies.json

info 'Restart Firefox to apply the selection.'
