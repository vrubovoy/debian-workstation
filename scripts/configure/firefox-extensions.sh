#!/usr/bin/env bash
# ******************************************************************************
# @file    firefox-extensions.sh
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Picks the Firefox extensions and adds them to the policies.
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

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
