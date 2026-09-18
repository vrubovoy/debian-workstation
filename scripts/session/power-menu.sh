#!/usr/bin/env bash

# =============================================================================
# Workstation power menu
# =============================================================================
#
# Graphical session and power controls using Rofi.
#
# Actions:
#
#   Lock
#   Suspend
#   Logout
#   Reboot
#   Power off
#
# Potentially destructive actions require explicit confirmation.
#
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Menu
# =============================================================================

MENU_ITEMS=$(
    printf '%s\n' \
        "Lock" \
        "Suspend" \
        "Logout" \
        "Reboot" \
        "Power off"
)


choice="$(
    printf '%s\n' "$MENU_ITEMS" |
        rofi \
            -dmenu \
            -i \
            -p "Session"
)" || exit 0


# =============================================================================
# Confirmation
# =============================================================================

confirm() {

    local action="$1"
    local answer

    answer="$(
        printf '%s\n' \
            "No" \
            "Yes" |
            rofi \
                -dmenu \
                -i \
                -p "$action?"
    )" || return 1

    [[ "$answer" == "Yes" ]]
}


# =============================================================================
# Actions
# =============================================================================

case "$choice" in

    "Lock")

        exec ~/.local/bin/workstation-lock
        ;;


    "Suspend")

        # xss-lock receives the systemd-logind sleep request and makes sure
        # i3lock has secured the session before suspend actually proceeds.

        exec systemctl suspend
        ;;


    "Logout")

        confirm "Logout" || exit 0

        exec i3-msg exit
        ;;


    "Reboot")

        confirm "Reboot" || exit 0

        exec systemctl reboot
        ;;


    "Power off")

        confirm "Power off" || exit 0

        exec systemctl poweroff
        ;;


    *)
        # Escape or an unexpected value simply closes the menu.
        exit 0
        ;;

esac