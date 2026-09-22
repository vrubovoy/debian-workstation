#!/usr/bin/env bash
# Session menu as a row of tiles in Rofi; 1–5 pick a tile directly. Power off,
# reboot and log out ask for confirmation, which goes ahead after five seconds.

set -Eeuo pipefail

ICONS="$HOME/.config/rofi/icons"

# "Label:icon" arguments become Rofi rows with icons.
tiles() {
    local tile

    for tile in "$@"; do
        printf '%s\0icon\x1f%s/%s.svg\n' "${tile%:*}" "$ICONS" "${tile#*:}"
    done
}

menu() {
    rofi -dmenu -i -kb-select-1 1 -kb-select-2 2 -kb-select-3 3 -kb-select-4 4 -kb-select-5 5 "$@"
}

confirm() {
    [[ "$(tiles "$1:$2" "Cancel:cancel" | menu -theme power-confirm -p "$1 in 5 seconds")" == "$1" ]]
}

choice="$(tiles "Power off:power" "Reboot:reboot" "Suspend:suspend" "Lock:lock" "Log out:logout" |
    menu -theme power-menu -p Session)" || exit 0

case "$choice" in
    "Power off")
        confirm "Power off" power || exit 0
        exec systemctl poweroff
        ;;
    Reboot)
        confirm Reboot reboot || exit 0
        exec systemctl reboot
        ;;
    Suspend)
        # xss-lock locks the session before the system goes to sleep.
        exec systemctl suspend
        ;;
    Lock)
        exec workstation-lock
        ;;
    "Log out")
        confirm "Log out" logout || exit 0
        exec i3-msg exit
        ;;
esac
