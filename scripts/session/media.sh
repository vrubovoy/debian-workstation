#!/usr/bin/env bash

# =============================================================================
# Workstation media control
# =============================================================================
#
# Controls MPRIS-compatible media players through Playerctl.
#
# Supported actions:
#
#   play-pause
#   next
#   previous
#
# playerctld runs as part of the i3 session and makes Playerctl target the
# player with the most recent activity.
#
# No notification is displayed here intentionally:
#
#   - media players usually provide their own UI;
#   - repeated track-control notifications create unnecessary visual noise;
#   - volume and brightness remain the only desktop OSD controls.
#
# =============================================================================

set -Eeuo pipefail


case "${1:-}" in

    play-pause|next|previous)

        # --no-messages suppresses harmless "no player found" diagnostics when
        # nothing supporting MPRIS is currently running.
        playerctl \
            --no-messages \
            "${1}" \
            >/dev/null 2>&1 \
            || true
        ;;

    *)
        printf \
            'Usage: %s {play-pause|next|previous}\n' \
            "$(basename "$0")" \
            >&2

        exit 2
        ;;

esac