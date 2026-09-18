#!/usr/bin/env bash

# =============================================================================
# Workstation brightness control
# =============================================================================
#
# Controls the first available backlight device through brightnessctl.
#
# Supported actions:
#
#   up       increase brightness by 5%
#   down     decrease brightness by 5%
#
# If the machine has no controllable backlight device, the script exits
# silently. This keeps the same workstation configuration usable on both
# laptops and desktop PCs.
#
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Constants
# =============================================================================

STEP="5%"
OSD_TIMEOUT="1200"


# =============================================================================
# Helpers
# =============================================================================

get_brightness_percent() {
    local state

    state="$(brightnessctl -m info 2>/dev/null | head -n 1)" || return 1

    [[ -n "$state" ]] || return 1

    BRIGHTNESS_PERCENT="$(
        awk -F',' '
            {
                gsub(/%/, "", $4)
                print $4
            }
        ' <<< "$state"
    )"

    [[ "$BRIGHTNESS_PERCENT" =~ ^[0-9]+$ ]]
}


notify_brightness() {
    get_brightness_percent || return 0

    dunstify \
        -a "Desktop OSD" \
        -u low \
        -t "$OSD_TIMEOUT" \
        -i "display-brightness-symbolic" \
        -h string:x-dunst-stack-tag:brightness \
        -h int:value:"$BRIGHTNESS_PERCENT" \
        "Brightness" \
        "${BRIGHTNESS_PERCENT}%"
}


usage() {
    printf 'Usage: %s {up|down}\n' "$(basename "$0")" >&2
    exit 2
}


# =============================================================================
# Device availability
# =============================================================================

# Desktop systems may have no backlight device at all.
if ! brightnessctl -m info >/dev/null 2>&1; then
    exit 0
fi


# =============================================================================
# Action
# =============================================================================

case "${1:-}" in

    up)
        brightnessctl -q set "+${STEP}"
        ;;

    down)
        brightnessctl -q set "${STEP}-"
        ;;

    *)
        usage
        ;;

esac


notify_brightness