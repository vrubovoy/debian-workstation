#!/usr/bin/env bash

# =============================================================================
# Clipboard history
# =============================================================================
#
# Presents CopyQ clipboard history through Rofi.
#
# CopyQ is responsible for:
#
#   - monitoring the X11 clipboard;
#   - persistent history storage;
#   - restoring the complete clipboard item, including non-text MIME data.
#
# Rofi is used only as a searchable frontend.
#
# Selecting an item restores it to the clipboard. The item is not pasted
# automatically; paste normally with Ctrl+V afterwards.
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Dependencies
# =============================================================================

if ! command -v copyq >/dev/null 2>&1; then
    notify-send \
        "Clipboard" \
        "CopyQ is not installed."

    exit 1
fi

if ! command -v rofi >/dev/null 2>&1; then
    notify-send \
        "Clipboard" \
        "Rofi is not installed."

    exit 1
fi


# =============================================================================
# CopyQ availability
# =============================================================================

if ! pgrep -x copyq >/dev/null 2>&1; then
    notify-send \
        "Clipboard" \
        "Clipboard history service is not running."

    exit 1
fi


# =============================================================================
# Build menu
# =============================================================================
#
# Each Rofi line has the following internal representation:
#
#   COPYQ_INDEX<TAB>PREVIEW
#
# The numeric index is kept so the selected Rofi entry can be mapped directly
# back to the original CopyQ item.
#
# Embedded newlines and tabs are collapsed because Rofi's dmenu protocol uses
# one line per selectable item.
#
# Non-text clipboard entries remain selectable. CopyQ restores the complete
# original item even when Rofi can only display a generic textual preview.

items="$(
    copyq eval -- '
        var count = size();

        if (count > 200)
            count = 200;

        for (var i = 0; i < count; ++i) {
            var text = str(read(i));

            text = text.replace(/[\r\n\t]+/g, " ");
            text = text.replace(/^ +| +$/g, "");

            if (!text)
                text = "[non-text clipboard item]";

            if (text.length > 160)
                text = text.substring(0, 157) + "...";

            print(i + "\t" + text + "\n");
        }
    '
)"


# =============================================================================
# Empty history
# =============================================================================

if [[ -z "$items" ]]; then
    notify-send \
        "Clipboard" \
        "Clipboard history is empty."

    exit 0
fi


# =============================================================================
# Selection
# =============================================================================

selection="$(
    printf '%s' "$items" |
        rofi \
            -dmenu \
            -i \
            -matching fuzzy \
            -p "Clipboard"
)" || exit 0


# The CopyQ row number is everything before the first tab.
index="${selection%%$'\t'*}"


# =============================================================================
# Validation
# =============================================================================

if [[ ! "$index" =~ ^[0-9]+$ ]]; then
    notify-send \
        "Clipboard" \
        "Invalid clipboard selection."

    exit 1
fi


# =============================================================================
# Restore
# =============================================================================
#
# select() restores the complete CopyQ item to the clipboard rather than only
# the textual preview shown by Rofi.

copyq select "$index"


notify-send \
    -h string:x-dunst-stack-tag:clipboard \
    "Clipboard" \
    "Clipboard item restored."