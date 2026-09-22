#!/usr/bin/env bash
# Lock the X session with i3lock. Used by Super+L, the power menu and xss-lock
# (idle timeout and suspend).

set -Eeuo pipefail

# Already locked, e.g. a manual lock right before suspend. Exiting releases the
# sleep lock xss-lock handed over, while the running i3lock keeps the session
# locked.
if pgrep -x i3lock >/dev/null; then
    exit 0
fi

# --nofork keeps i3lock in the foreground: xss-lock waits for it before
# letting the system suspend. A solid color never exposes screen contents.
exec i3lock \
    --nofork \
    --color=111318 \
    --ignore-empty-password \
    --show-failed-attempts \
    --show-keyboard-layout
