#!/usr/bin/env bash

# =============================================================================
# CopyQ configuration
# =============================================================================
#
# Configures CopyQ as the persistent clipboard-history backend for the X11
# workstation.
#
# CopyQ itself does not provide the primary user interface. Clipboard history
# is presented through Rofi by workstation-clipboard.
#
# This script must run from a graphical X11 session because CopyQ requires
# access to the X clipboard.
#
# The script is safe to run repeatedly.
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Environment
# =============================================================================

if [[ -z "${DISPLAY:-}" ]]; then
    printf 'CopyQ configuration requires a graphical X11 session.\n' >&2
    exit 1
fi

if ! command -v copyq >/dev/null 2>&1; then
    printf 'CopyQ is not installed.\n' >&2
    exit 1
fi


# =============================================================================
# Start CopyQ
# =============================================================================
#
# CopyQ configuration is accessed through its client/server interface.
#
# Start the server when it is not already running.

if ! pgrep -x copyq >/dev/null 2>&1; then
    copyq >/dev/null 2>&1 &
fi


# Wait briefly for the CopyQ server to become available.

for _ in {1..50}; do
    if copyq size >/dev/null 2>&1; then
        break
    fi

    sleep 0.1
done

if ! copyq size >/dev/null 2>&1; then
    printf 'CopyQ did not become ready.\n' >&2
    exit 1
fi


# =============================================================================
# Clipboard monitoring
# =============================================================================

# Monitor the normal X11 clipboard used by Ctrl+C / Ctrl+V.
copyq config check_clipboard true

# Do not store the X11 PRIMARY selection.
#
# Selecting text with the mouse therefore does not pollute clipboard history.
copyq config check_selection false

# Keep PRIMARY selection and the regular clipboard independent.
copyq config copy_clipboard false
copyq config copy_selection false


# =============================================================================
# History
# =============================================================================

# Keep a useful but bounded clipboard history.
copyq config maxitems 200


# =============================================================================
# User interface
# =============================================================================
#
# Rofi is the workstation clipboard-history frontend, so CopyQ itself does not
# need a tray icon or clipboard-change notifications.

copyq config disable_tray true
copyq config clipboard_notification_lines 0

# CopyQ is started explicitly by i3.
copyq config autostart false


# Hide the CopyQ window if configuration caused it to become visible.
copyq hide >/dev/null 2>&1 || true


printf 'CopyQ configured successfully.\n'