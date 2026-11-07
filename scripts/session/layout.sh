#!/usr/bin/env bash
# ******************************************************************************
# @file    layout.sh
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Shows the keyboard layout that Alt+Space switched to.
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

set -Eeuo pipefail

# The active XKB group, read through libX11; no Debian tool prints it.
group="$(python3 - <<'PY'
import ctypes, ctypes.util

x11 = ctypes.CDLL(ctypes.util.find_library("X11"))
x11.XOpenDisplay.restype = ctypes.c_void_p
x11.XkbGetState.argtypes = [ctypes.c_void_p, ctypes.c_uint, ctypes.c_void_p]

display = x11.XOpenDisplay(None)
if not display:
    raise SystemExit("cannot open the X display")

state = (ctypes.c_ubyte * 18)()
x11.XkbGetState(display, 0x100, state)
print(state[0])
PY
)"

IFS=, read -ra layouts < <(setxkbmap -query | awk '$1 == "layout:" { print $2 }')
layout="${layouts[group]:-}"

case "$layout" in
    us) name="English" ;;
    ru) name="Русский" ;;
    *)  name="${layout^^}" ;;
esac

dunstify -a "Desktop OSD" -u low -t 1200 \
    -i input-keyboard-symbolic \
    -h string:x-dunst-stack-tag:layout \
    "Layout" "$name"
