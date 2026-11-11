#!/usr/bin/env bash
# ******************************************************************************
# @file    installer.sh
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Checks backups, repeated deployment and generated Firefox policies.
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

set -Eeuo pipefail

# shellcheck source=scripts/install/system.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../scripts/install/system.sh"

tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
MANAGED_FILES="$tmp/managed-files"
FIREFOX_SELECTION="$tmp/firefox-extensions"

printf 'original\n' > "$tmp/target"
printf 'managed\n' > "$tmp/source"
deploy "$tmp/source" "$tmp/target"
[[ "$(<"$tmp/target$BACKUP_SUFFIX")" == original ]]
[[ "$(<"$tmp/target")" == managed ]]
[[ "$(<"$MANAGED_FILES")" == "$tmp/target" ]]

printf 'updated\n' > "$tmp/source"
deploy "$tmp/source" "$tmp/target"
[[ "$(<"$tmp/target$BACKUP_SUFFIX")" == original ]]
[[ "$(<"$tmp/target")" == updated ]]
[[ "$(wc -l < "$MANAGED_FILES")" == 1 ]]

render_firefox_policies | jq -e '.policies.ExtensionSettings == null' >/dev/null
printf '%s\n' 'foxyproxy@eric.h.jung' > "$FIREFOX_SELECTION"
render_firefox_policies | jq -e '
    .policies.ExtensionSettings | keys == ["foxyproxy@eric.h.jung"]
' >/dev/null

info 'Installer checks passed.'
