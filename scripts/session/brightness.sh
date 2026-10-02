#!/usr/bin/env bash
# Brightness up/down with a Dunst OSD: the backlight on a laptop, the monitors
# over DDC/CI (ddcutil) on a desktop. Does nothing if neither is available.

set -Eeuo pipefail

STEP=5
BUSES="${XDG_RUNTIME_DIR:-/tmp}/workstation-brightness.buses"

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

# I2C buses of the monitors that answer DDC/CI. Detection is slow, so it runs
# once per boot, or again after a monitor stops answering.
ddc_buses() {
    if [[ ! -s "$BUSES" ]]; then
        ddc detect --terse | awk '
            /^Display [0-9]+/ { display = 1; next }
            /^[^ ]/ { display = 0 }
            display && /I2C bus:/ { sub(/.*\/dev\/i2c-/, ""); print }' > "$BUSES"
    fi

    cat -- "$BUSES"
}

case "${1:-}" in
    up)   direction=1  value="+$STEP%" ;;
    down) direction=-1 value="$STEP%-" ;;
    *)
        printf 'Usage: %s {up|down}\n' "${0##*/}" >&2
        exit 2
        ;;
esac

if backlight info >/dev/null 2>&1; then
    backlight -q set "$value"
    percent="$(backlight -m info | awk -F, '{ sub(/%/, "", $4); print $4; exit }')"
else
    # Presses that arrive while a change is written are dropped instead of
    # piling up while the key is held.
    exec 9>"${XDG_RUNTIME_DIR:-/tmp}/workstation-brightness.lock"
    flock -n 9 || exit 0

    mapfile -t buses < <(ddc_buses)
    (( ${#buses[@]} > 0 )) || exit 0

    # "VCP 10 C <current> <max>"; ddcutil may print diagnostics before it.
    if ! read -r current max < <(ddc --bus "${buses[0]}" getvcp 10 --terse |
                                 awk '$1 == "VCP" && $5 > 0 { print $4, $5 }'); then
        rm -f -- "$BUSES"
        exit 0
    fi

    # Every monitor gets the first one's new level; at least one unit per step.
    step=$(( max * STEP / 100 > 0 ? max * STEP / 100 : 1 ))
    level=$(( current + direction * step ))
    level=$(( level < 0 ? 0 : level > max ? max : level ))

    for bus in "${buses[@]}"; do
        ddc --bus "$bus" setvcp 10 "$level" >/dev/null || rm -f -- "$BUSES"
    done

    percent=$(( level * 100 / max ))
fi

dunstify -a "Desktop OSD" -u low -t 1200 \
    -i display-brightness-symbolic \
    -h string:x-dunst-stack-tag:brightness \
    -h "int:value:$percent" \
    "Brightness" "$percent%"
