#!/usr/bin/env bash
# Backlight up/down with a Dunst OSD. Exits quietly on machines without a
# backlight, so the same bindings are harmless on a desktop.

set -Eeuo pipefail

STEP="5%"

# Without --class, brightnessctl falls back to keyboard LEDs when there is no
# backlight.
backlight() {
    brightnessctl --class=backlight "$@"
}

backlight info >/dev/null 2>&1 || exit 0

case "${1:-}" in
    up)   backlight -q set "+$STEP" ;;
    down) backlight -q set "$STEP-" ;;
    *)
        printf 'Usage: %s {up|down}\n' "${0##*/}" >&2
        exit 2
        ;;
esac

percent="$(backlight -m info | awk -F, '{ sub(/%/, "", $4); print $4; exit }')"

dunstify -a "Desktop OSD" -u low -t 1200 \
    -i display-brightness-symbolic \
    -h string:x-dunst-stack-tag:brightness \
    -h "int:value:$percent" \
    "Brightness" "$percent%"
