#!/usr/bin/env bash
# Session and power menu in Rofi. Logout, reboot and power-off ask for
# confirmation.

set -Eeuo pipefail

menu() {
    rofi -dmenu -i -p "$1"
}

confirm() {
    [[ "$(printf 'No\nYes\n' | menu "$1?")" == Yes ]]
}

choice="$(printf 'Lock\nSuspend\nLogout\nReboot\nPower off\n' | menu Session)" || exit 0

case "$choice" in
    Lock)
        exec workstation-lock
        ;;
    Suspend)
        # xss-lock locks the session before the system goes to sleep.
        exec systemctl suspend
        ;;
    Logout)
        confirm Logout || exit 0
        exec i3-msg exit
        ;;
    Reboot)
        confirm Reboot || exit 0
        exec systemctl reboot
        ;;
    "Power off")
        confirm "Power off" || exit 0
        exec systemctl poweroff
        ;;
esac
