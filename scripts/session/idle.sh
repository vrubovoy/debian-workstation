#!/usr/bin/env bash
# ******************************************************************************
# @file    idle.sh
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Locks and suspends on idle, but stays awake during media playback.
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

set -Eeuo pipefail

TIMEOUT=$(( 15 * 60 ))
INTERVAL=30

media_playing() {
    # MPRIS also covers silent video in Firefox, where there is no audio stream.
    if playerctl --all-players status 2>/dev/null | grep -qx Playing; then
        return 0
    fi

    # PipeWire sees audio from players without MPRIS (and from other sinks).
    pw-dump 2>/dev/null | jq -e 'any(.[];
        .type == "PipeWire:Interface:Node" and
        .info.props["media.class"] == "Stream/Output/Audio" and
        .info.state == "running"
    )' >/dev/null 2>&1
}

# A virtual machine is left to its host.
if systemd-detect-virt --quiet --vm; then
    exit 0
fi

if ! command -v xprintidle >/dev/null; then
    notify-send "Idle suspend is off" "xprintidle is not installed; run install.sh."
    exit 1
fi

while sleep "$INTERVAL"; do
    if media_playing; then
        # xss-lock and DPMS use the same X idle timer as xprintidle. Keep all
        # three from firing while media plays; after it stops, count afresh.
        xset s reset || exit 0
        continue
    fi

    # Ends with the X session.
    idle="$(xprintidle)" || exit 0

    if (( idle / 1000 >= TIMEOUT )); then
        systemctl suspend || continue

        # Restart the idle count after resume, so the system does not go back
        # to sleep before anyone touches it.
        sleep 10
        xset s reset
    fi
done
