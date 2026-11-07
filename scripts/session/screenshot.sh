#!/usr/bin/env bash
# ******************************************************************************
# @file    screenshot.sh
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Screenshot of an area, a window or the screen, saved and copied.
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

set -Eeuo pipefail

MODE="${1:-area}"

# Graphite Blue accent #7AA2F7 as RGBA in 0..1, the format slop expects.
SELECTION_COLOR="0.478,0.635,0.969,0.80"

directory="$(xdg-user-dir PICTURES 2>/dev/null || true)"
directory="${directory:-$HOME/Pictures}/Screenshots"
file="$directory/$(date '+%Y-%m-%d_%H-%M-%S_%3N').png"

# Capture into a temporary file so a cancelled selection leaves nothing behind.
tmp="$(mktemp --suffix=.png)"
trap 'rm -f -- "$tmp"' EXIT

case "$MODE" in
    area)
        maim --hidecursor --select --bordersize=2 --color="$SELECTION_COLOR" "$tmp" || exit 0
        ;;
    window)
        maim --hidecursor --window="$(xdotool getactivewindow)" "$tmp"
        ;;
    screen)
        maim --hidecursor "$tmp"
        ;;
    *)
        printf 'Usage: %s {area|window|screen}\n' "${0##*/}" >&2
        exit 2
        ;;
esac

[[ -s "$tmp" ]] || exit 1

mkdir -p "$directory"
mv -- "$tmp" "$file"

xclip -selection clipboard -target image/png -in < "$file"

dunstify -a "Desktop OSD" -u low -t 2500 \
    -i camera-photo-symbolic \
    -h string:x-dunst-stack-tag:screenshot \
    "Screenshot saved" "$file"
