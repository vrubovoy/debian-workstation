#!/usr/bin/env bash
# Brightness up/down with a Dunst OSD: the backlight on a laptop, the monitors
# over DDC/CI (ddcutil) on a desktop. Does nothing if neither is available.

set -Eeuo pipefail

STEP=5

# Without --class, brightnessctl falls back to keyboard LEDs when there is no
# backlight.
backlight() {
    brightnessctl --class=backlight "$@"
}

# The ddcutil package loads i2c-dev and gives the session user the monitors'
# I2C buses, so no sudo is needed.
ddc() {
    ddcutil --noverify "$@" 2>/dev/null
}

case "${1:-}" in
    up)   sign="+" value="+$STEP%" ;;
    down) sign="-" value="$STEP%-" ;;
    *)
        printf 'Usage: %s {up|down}\n' "${0##*/}" >&2
        exit 2
        ;;
esac

if backlight info >/dev/null 2>&1; then
    backlight -q set "$value"
    percent="$(backlight -m info | awk -F, '{ sub(/%/, "", $4); print $4; exit }')"
else
    # DDC/CI takes up to a second per change; presses that arrive meanwhile
    # are dropped instead of piling up while the key is held.
    exec 9>"${XDG_RUNTIME_DIR:-/tmp}/workstation-brightness.lock"
    flock -n 9 || exit 0

    mapfile -t displays < <(ddc detect --terse | awk '/^Display [0-9]+/ { print $2 }')
    (( ${#displays[@]} > 0 )) || exit 0

    for display in "${displays[@]}"; do
        ddc --display "$display" setvcp 10 "$sign" "$STEP" || true
    done

    # "VCP 10 C <current> <max>"
    percent="$(ddc --display "${displays[0]}" getvcp 10 --terse | awk '$5 > 0 { printf "%d", $4 * 100 / $5 }')"
    [[ -n "$percent" ]] || exit 0
fi

dunstify -a "Desktop OSD" -u low -t 1200 \
    -i display-brightness-symbolic \
    -h string:x-dunst-stack-tag:brightness \
    -h "int:value:$percent" \
    "Brightness" "$percent%"
