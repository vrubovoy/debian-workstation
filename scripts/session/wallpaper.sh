#!/usr/bin/env bash
# Desktop background: assets/wallpapers/default.jpg, or the Graphite Blue base
# color if the image is missing.

set -Eeuo pipefail

# Resolve the ~/.local/bin symlink to find the repository.
ROOT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../.." && pwd)"
WALLPAPER="$ROOT_DIR/assets/wallpapers/default.jpg"

if [[ -f "$WALLPAPER" ]]; then
    # --no-fehbg: the repository, not ~/.fehbg, is the source of truth.
    exec feh --no-fehbg --bg-fill "$WALLPAPER"
fi

exec xsetroot -solid "#111318"
