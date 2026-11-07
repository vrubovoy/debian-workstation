#!/usr/bin/env bash
# ******************************************************************************
# @file    clipboard.sh
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Clipboard history: `start` runs CopyQ, no argument opens Rofi.
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

set -Eeuo pipefail

HISTORY_SIZE=200

notify() {
    notify-send -h string:x-dunst-stack-tag:clipboard "Clipboard" "$1"
}

start() {
    # hide_main_window: without a tray icon CopyQ would otherwise "minimize"
    # its window, which i3 shows.
    copyq --start-server config \
        check_clipboard true \
        check_selection false \
        copy_clipboard false \
        copy_selection false \
        maxitems "$HISTORY_SIZE" \
        disable_tray true \
        hide_main_window true \
        clipboard_notification_lines 0 \
        >/dev/null
}

menu() {
    local items selection index

    if ! copyq size >/dev/null 2>&1; then
        notify "CopyQ is not running."
        exit 1
    fi

    # "ROW<TAB>preview" lines: Rofi shows the preview and returns the row, so
    # the item is restored with all its formats.
    items="$(copyq eval -- "
        for (var i = 0; i < Math.min(size(), $HISTORY_SIZE); ++i) {
            var text = str(read(i)).replace(/\s+/g, ' ').trim() || '[non-text item]';
            if (text.length > 160)
                text = text.substring(0, 157) + '...';
            print(i + '\t' + text + '\n');
        }
    ")"

    if [[ -z "$items" ]]; then
        notify "History is empty."
        exit 0
    fi

    selection="$(rofi -dmenu -i -matching fuzzy -display-columns 2 -p "Clipboard" <<< "$items")" ||
        exit 0

    index="${selection%%$'\t'*}"
    [[ "$index" =~ ^[0-9]+$ ]] || exit 1

    copyq select "$index"
    notify "Item restored."
}

case "${1:-}" in
    start) start ;;
    "")    menu ;;
    *)
        printf 'Usage: %s [start]\n' "${0##*/}" >&2
        exit 2
        ;;
esac
