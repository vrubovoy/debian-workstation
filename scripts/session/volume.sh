#!/usr/bin/env bash
# Speaker and microphone controls through WirePlumber, with a Dunst OSD.
# Speaker volume is capped at 100%.

set -Eeuo pipefail

SINK="@DEFAULT_AUDIO_SINK@"
SOURCE="@DEFAULT_AUDIO_SOURCE@"
STEP="5%"

notify() {
    local target="$1" title="$2" state percent body icon

    state="$(wpctl get-volume "$target")" || return 0
    percent="$(awk '{ printf "%.0f", $2 * 100 }' <<< "$state")"
    body="$percent%"

    if [[ "$state" == *MUTED* ]]; then
        percent=0
        body="Muted"
    fi

    if [[ "$title" == Microphone ]]; then
        icon="audio-input-microphone-symbolic"
    elif [[ "$body" == Muted ]]; then
        icon="audio-volume-muted-symbolic"
    elif (( percent >= 67 )); then
        icon="audio-volume-high-symbolic"
    elif (( percent >= 34 )); then
        icon="audio-volume-medium-symbolic"
    else
        icon="audio-volume-low-symbolic"
    fi

    dunstify -a "Desktop OSD" -u low -t 1200 -i "$icon" \
        -h "string:x-dunst-stack-tag:${title,,}" \
        -h "int:value:$percent" \
        "$title" "$body"
}

case "${1:-}" in
    up)
        # Raising the volume also unmutes.
        wpctl set-mute "$SINK" 0
        wpctl set-volume --limit 1.0 "$SINK" "$STEP+"
        notify "$SINK" Volume
        ;;
    down)
        wpctl set-volume "$SINK" "$STEP-"
        notify "$SINK" Volume
        ;;
    mute)
        wpctl set-mute "$SINK" toggle
        notify "$SINK" Volume
        ;;
    mic-mute)
        wpctl set-mute "$SOURCE" toggle
        notify "$SOURCE" Microphone
        ;;
    *)
        printf 'Usage: %s {up|down|mute|mic-mute}\n' "${0##*/}" >&2
        exit 2
        ;;
esac

# SIGUSR1 makes i3status redraw now instead of at its next interval.
pkill -USR1 -x i3status || true
