#!/usr/bin/env bash

# =============================================================================
# Desktop appearance settings
# =============================================================================
#
# Applies desktop-wide GSettings used by GTK applications.
#
# This script is safe to execute repeatedly.
#
# =============================================================================

set -Eeuo pipefail


SCHEMA="org.gnome.desktop.interface"


# =============================================================================
# Color scheme
# =============================================================================

gsettings set "$SCHEMA" color-scheme 'prefer-dark'


# =============================================================================
# GTK
# =============================================================================

gsettings set "$SCHEMA" gtk-theme 'Adwaita-dark'

gsettings set "$SCHEMA" icon-theme 'Adwaita'


# =============================================================================
# Fonts
# =============================================================================

gsettings set "$SCHEMA" font-name 'Ubuntu Bold 13'

gsettings set "$SCHEMA" monospace-font-name 'Ubuntu Mono Bold 13'


# =============================================================================
# Cursor
# =============================================================================

gsettings set "$SCHEMA" cursor-theme 'Adwaita'

gsettings set "$SCHEMA" cursor-size 24