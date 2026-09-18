#!/usr/bin/env bash

# =============================================================================
# X11 idle policy
# =============================================================================
#
# Configures inactivity and display-power behaviour for the i3/X11 session.
#
# Policy:
#
#   10 minutes idle
#       -> XScreenSaver event
#       -> xss-lock
#       -> workstation-lock
#
#   15 minutes idle
#       -> DPMS powers the displays off
#
# Any keyboard or mouse activity resets both timers.
#
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Idle timeout
# =============================================================================

# Lock after 10 minutes (600 seconds) of inactivity.
#
# The second value is the X11 screen-saver cycle interval.
# Zero means there is no additional cycle before xss-lock starts the locker.

xset s 600 0


# =============================================================================
# Display power management
# =============================================================================

# Enable DPMS.
xset +dpms

# DPMS timeouts:
#
#   standby = 0
#   suspend = 0
#   off     = 900 seconds
#
# We use only the modern "off" state. The old X11 standby/suspend display
# states do not provide useful behaviour on a modern workstation.

xset dpms 0 0 900