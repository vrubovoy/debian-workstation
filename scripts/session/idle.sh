#!/usr/bin/env bash
# Suspend after 15 minutes without keyboard or mouse input, but not while
# sound is playing. i3 starts it; xss-lock locks the screen before the sleep.

set -Eeuo pipefail

TIMEOUT=$(( 15 * 60 ))
INTERVAL=30

sound_playing() {
    grep -qs RUNNING /proc/asound/card*/pcm*p/sub*/status
}

while sleep "$INTERVAL"; do
    if (( $(xprintidle) / 1000 >= TIMEOUT )) && ! sound_playing; then
        systemctl suspend || continue

        # Restart the idle count after resume, so the system does not go back
        # to sleep before anyone touches it.
        sleep 10
        xset s reset
    fi
done
