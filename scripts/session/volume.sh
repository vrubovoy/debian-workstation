#!/usr/bin/env bash

# =============================================================================
# Workstation volume control
# =============================================================================
#
# Controls PipeWire audio through WirePlumber's `wpctl`.
#
# Supported actions:
#
#   up         increase output volume by 5%
#   down       decrease output volume by 5%
#   mute       toggle output mute
#   mic-mute   toggle microphone mute
#
# Volume is capped at 100%.
#
# Every action displays a transient Dunst OSD notification. Notifications with
# the same stack tag replace each other instead of filling the screen.
#
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Constants
# =============================================================================

SINK="@DEFAULT_AUDIO_SINK@"
SOURCE="@DEFAULT_AUDIO_SOURCE@"

STEP="5%"
VOLUME_LIMIT="1.0"

OSD_TIMEOUT="1200"


# =============================================================================
# Helpers
# =============================================================================

get_audio_state() {
    local target="$1"
    local output

    output="$(wpctl get-volume "$target" 2>/dev/null)" || return 1

    AUDIO_PERCENT="$(
        awk '{ printf "%.0f", $2 * 100 }' <<< "$output"
    )"

    if grep -q '\[MUTED\]' <<< "$output"; then
        AUDIO_MUTED=true
    else
        AUDIO_MUTED=false
    fi
}


notify_volume() {
    get_audio_state "$SINK" || return 0

    local icon
    local body
    local progress

    if [[ "$AUDIO_MUTED" == true ]]; then
        icon="audio-volume-muted-symbolic"
        body="Muted"
        progress=0

    elif (( AUDIO_PERCENT >= 67 )); then
        icon="audio-volume-high-symbolic"
        body="${AUDIO_PERCENT}%"
        progress="$AUDIO_PERCENT"

    elif (( AUDIO_PERCENT >= 34 )); then
        icon="audio-volume-medium-symbolic"
        body="${AUDIO_PERCENT}%"
        progress="$AUDIO_PERCENT"

    else
        icon="audio-volume-low-symbolic"
        body="${AUDIO_PERCENT}%"
        progress="$AUDIO_PERCENT"
    fi

    dunstify \
        -a "Desktop OSD" \
        -u low \
        -t "$OSD_TIMEOUT" \
        -i "$icon" \
        -h string:x-dunst-stack-tag:volume \
        -h int:value:"$progress" \
        "Volume" \
        "$body"
}


notify_microphone() {
    get_audio_state "$SOURCE" || return 0

    local body
    local progress

    if [[ "$AUDIO_MUTED" == true ]]; then
        body="Muted"
        progress=0
    else
        body="${AUDIO_PERCENT}%"
        progress="$AUDIO_PERCENT"
    fi

    dunstify \
        -a "Desktop OSD" \
        -u low \
        -t "$OSD_TIMEOUT" \
        -i "audio-input-microphone-symbolic" \
        -h string:x-dunst-stack-tag:microphone \
        -h int:value:"$progress" \
        "Microphone" \
        "$body"
}


refresh_i3status() {
    # SIGUSR1 interrupts the current i3status sleep interval and forces an
    # immediate refresh.
    pkill -USR1 -x i3status 2>/dev/null || true
}


usage() {
    printf 'Usage: %s {up|down|mute|mic-mute}\n' "$(basename "$0")" >&2
    exit 2
}


# =============================================================================
# Action
# =============================================================================

case "${1:-}" in

    up)
        # Increasing the volume also unmutes the output.
        wpctl set-mute "$SINK" 0
        wpctl set-volume "$SINK" "${STEP}+" --limit "$VOLUME_LIMIT"

        notify_volume
        ;;

    down)
        wpctl set-volume "$SINK" "${STEP}-"

        notify_volume
        ;;

    mute)
        wpctl set-mute "$SINK" toggle

        notify_volume
        ;;

    mic-mute)
        wpctl set-mute "$SOURCE" toggle

        notify_microphone
        ;;

    *)
        usage
        ;;

esac


refresh_i3status