#!/usr/bin/env bash

# =============================================================================
# Workstation screen lock
# =============================================================================
#
# Locks the current X11 session using i3lock.
#
# This script is the single entry point for all locking operations:
#
#   - Super + L
#   - automatic idle locking through xss-lock
#   - loginctl lock-session
#   - suspend / hibernate preparation
#
# Design goals:
#   - minimal dependencies;
#   - predictable behaviour;
#   - no screenshots of the current desktop;
#   - Graphite Blue appearance;
#   - correct systemd-logind suspend integration.
#
# =============================================================================

set -Eeuo pipefail


# =============================================================================
# Appearance
# =============================================================================

# Graphite Blue base background.
#
# i3lock expects the color without a leading '#'.
BACKGROUND_COLOR="111318"


# =============================================================================
# Duplicate protection
# =============================================================================
#
# Do not start another locker when the session is already locked.
#
# This can happen, for example, if the user manually locks the session shortly
# before systemd-logind requests a suspend lock.
#
# Exiting here is safe: any inherited sleep-delay file descriptor is closed
# automatically when this process exits, while the already running i3lock
# continues protecting the session.

if pgrep -x i3lock >/dev/null 2>&1; then
    exit 0
fi


# =============================================================================
# Lock
# =============================================================================
#
# --nofork
#   Keep i3lock attached to this process.
#
#   This is essential for xss-lock, which waits for the locker and integrates
#   it with systemd-logind.
#
# --color
#   Replace the desktop with a solid Graphite Blue background.
#
#   A solid color is intentionally preferred over a screenshot:
#     - no desktop contents are exposed;
#     - no screenshot utility is required;
#     - no ImageMagick dependency is required;
#     - behaviour is identical on every display resolution.
#
# --ignore-empty-password
#   Pressing Enter accidentally does not submit an empty password to PAM and
#   trigger an unnecessary authentication delay.
#
# --show-failed-attempts
#   Display the number of failed authentication attempts.
#
# --show-keyboard-layout
#   Display the currently active XKB layout.
#
# The normal i3lock unlock indicator remains enabled. It provides useful
# feedback while typing and while PAM verifies the password.

exec i3lock \
    --nofork \
    --color="$BACKGROUND_COLOR" \
    --ignore-empty-password \
    --show-failed-attempts \
    --show-keyboard-layout