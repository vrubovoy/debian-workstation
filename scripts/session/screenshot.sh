#!/usr/bin/env bash

# =============================================================================
# Workstation screenshot
# =============================================================================
#
# Screenshot helper for the X11/i3 workstation.
#
# Supported modes:
#
#   area
#       interactively select a rectangular region;
#
#   window
#       capture the currently focused X11 window;
#
#   screen
#       capture the complete X11 desktop/root window.
#
# Every successful screenshot is:
#
#   - saved to ~/Pictures/Screenshots;
#   - copied to the X11 clipboard as image/png;
#   - reported through Dunst.
#
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Constants
# =============================================================================

MODE="${1:-area}"

OSD_TIMEOUT="2500"


# Graphite Blue accent:
#
#   #7AA2F7
#
# maim/slop expects RGBA components in the range 0.0 ... 1.0.
SELECTION_COLOR="0.478,0.635,0.969,0.80"


# =============================================================================
# Screenshot directory
# =============================================================================

PICTURES_DIR="$(
    xdg-user-dir PICTURES 2>/dev/null || true
)"

if [[ -z "$PICTURES_DIR" ]]; then
    PICTURES_DIR="$HOME/Pictures"
fi

SCREENSHOT_DIR="$PICTURES_DIR/Screenshots"

mkdir -p "$SCREENSHOT_DIR"


# =============================================================================
# File name
# =============================================================================
#
# Milliseconds are included so two rapid screenshots never collide.

TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S_%3N')"

SCREENSHOT_PATH="$SCREENSHOT_DIR/${TIMESTAMP}.png"


# =============================================================================
# Temporary file
# =============================================================================
#
# Capture to a temporary file first.
#
# This prevents an empty/partial PNG from appearing in the screenshot
# directory if an interactive selection is cancelled.

TEMP_FILE="$(mktemp --suffix=.png)"

cleanup() {
    rm -f -- "$TEMP_FILE"
}

trap cleanup EXIT


# =============================================================================
# Capture helpers
# =============================================================================

capture_area() {

    # Interactive region selection.
    #
    # Escape cancels the selection without creating a screenshot.

    maim \
        --hidecursor \
        --select \
        --bordersize=2 \
        --color="$SELECTION_COLOR" \
        "$TEMP_FILE"
}


capture_window() {

    local window_id

    window_id="$(xdotool getactivewindow)"

    [[ -n "$window_id" ]] || return 1

    maim \
        --hidecursor \
        --window="$window_id" \
        "$TEMP_FILE"
}


capture_screen() {

    # Capturing the root window includes the complete X11 desktop.
    #
    # On a multi-monitor setup this captures the whole virtual desktop.

    maim \
        --hidecursor \
        "$TEMP_FILE"
}


# =============================================================================
# Capture
# =============================================================================

case "$MODE" in

    area)
        if ! capture_area; then
            exit 0
        fi
        ;;

    window)
        if ! capture_window; then
            exit 1
        fi
        ;;

    screen)
        if ! capture_screen; then
            exit 1
        fi
        ;;

    *)
        printf \
            'Usage: %s {area|window|screen}\n' \
            "$(basename "$0")" \
            >&2

        exit 2
        ;;

esac


# =============================================================================
# Validate result
# =============================================================================

if [[ ! -s "$TEMP_FILE" ]]; then
    exit 1
fi


# =============================================================================
# Save
# =============================================================================

mv -- "$TEMP_FILE" "$SCREENSHOT_PATH"

# TEMP_FILE no longer exists after mv.
trap - EXIT


# =============================================================================
# Clipboard
# =============================================================================
#
# Put the PNG itself into the clipboard, not merely its pathname.

xclip \
    -selection clipboard \
    -target image/png \
    -in \
    < "$SCREENSHOT_PATH"


# =============================================================================
# Notification
# =============================================================================

dunstify \
    -a "Desktop OSD" \
    -u low \
    -t "$OSD_TIMEOUT" \
    -i "camera-photo-symbolic" \
    -h string:x-dunst-stack-tag:screenshot \
    "Screenshot saved" \
    "$SCREENSHOT_PATH"