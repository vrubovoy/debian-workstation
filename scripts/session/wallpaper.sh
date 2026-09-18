#!/usr/bin/env bash

# =============================================================================
# Workstation wallpaper
# =============================================================================
#
# Sets the desktop background for the i3/X11 session.
#
# Primary behaviour:
#   - Load the repository-managed wallpaper with Feh.
#
# Fallback behaviour:
#   - If the wallpaper file is missing, use the Graphite Blue background color
#     instead of leaving the X11 root window with an undefined/default pattern.
#
# The script determines the repository location through its own real path.
# Therefore the repository itself does not have to live in a hard-coded
# directory such as ~/Projects.
#
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Paths
# =============================================================================

# Resolve symlinks first.
#
# The command is expected to normally be invoked through:
#
#   ~/.local/bin/workstation-wallpaper
#
# which points to this repository script.
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"

SCRIPT_DIR="$(cd -- "$(dirname -- "$SCRIPT_PATH")" && pwd)"

# scripts/session/wallpaper.sh
#        ↑
#        └── repository root is two directories above scripts/session.
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

WALLPAPER="$ROOT_DIR/assets/wallpapers/default.jpg"


# =============================================================================
# Appearance
# =============================================================================

# Same base background used throughout Graphite Blue.
FALLBACK_COLOR="#111318"


# =============================================================================
# Wallpaper
# =============================================================================

if [[ -f "$WALLPAPER" ]]; then

    # --bg-fill
    #   Preserve aspect ratio and fill the entire display.
    #   Cropping is preferred over letterboxing.
    #
    # --no-fehbg
    #   Do not generate ~/.fehbg.
    #
    # ~/.fehbg would duplicate configuration already managed by this
    # repository and would introduce another hidden state file.
    exec feh \
        --no-fehbg \
        --bg-fill \
        "$WALLPAPER"

else

    # Missing wallpaper must not break the graphical session.
    #
    # Fall back to the same dark Graphite Blue background used by i3,
    # LightDM, Kitty, Rofi and Dunst.
    exec xsetroot -solid "$FALLBACK_COLOR"

fi