#!/usr/bin/env bash
# Suspend after 15 minutes without keyboard or mouse input, but not while
# sound is playing or in a virtual machine. i3 starts it; xss-lock locks the
# screen before the sleep.

set -Eeuo pipefail

TIMEOUT=$(( 15 * 60 ))
INTERVAL=30

sound_playing() {
    grep -qs RUNNING /proc/asound/card*/pcm*p/sub*/status
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
    # Ends with the X session.
    idle="$(xprintidle)" || exit 0

    if (( idle / 1000 >= TIMEOUT )) && ! sound_playing; then
        systemctl suspend || continue

        # Restart the idle count after resume, so the system does not go back
        # to sleep before anyone touches it.
        sleep 10
        xset s reset
    fi
done
