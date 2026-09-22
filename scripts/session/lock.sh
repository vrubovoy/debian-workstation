#!/usr/bin/env bash
# Lock the X session with i3lock over the wallpaper. Used by Super+L, the power
# menu and xss-lock (idle timeout and suspend).

set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../.." && pwd)"
WALLPAPER="$ROOT_DIR/assets/wallpapers/default.jpg"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/workstation"

# i3lock shows a PNG as is, so the wallpaper is fitted to every monitor once
# and cached for the current monitor layout.
lock_image() {
    local screen geometry image monitors=()
    local args=(-respect-parentheses)

    screen="$(xrandr | awk '/ current / { gsub(",", ""); print $8 "x" $10; exit }')"
    mapfile -t monitors < <(xrandr --listactivemonitors | awk 'NR > 1 { print $3 }' | sed -E 's#/[0-9]+##g')
    [[ -n "$screen" && ${#monitors[@]} -gt 0 ]] || return 1

    image="$CACHE_DIR/lock-$(IFS=_; printf '%s' "${monitors[*]}").png"

    if [[ ! -f "$image" || "$WALLPAPER" -nt "$image" ]]; then
        args+=(-size "$screen" "xc:#111318")

        for geometry in "${monitors[@]}"; do
            args+=("(" "$WALLPAPER" -resize "${geometry%%+*}^" -gravity center -extent "${geometry%%+*}" ")"
                   -gravity northwest -geometry "+${geometry#*+}" -composite)
        done

        mkdir -p "$CACHE_DIR"
        rm -f -- "$CACHE_DIR"/lock-*.png
        magick "${args[@]}" "$image" || return 1
    fi

    printf '%s\n' "$image"
}

# Already locked, e.g. a manual lock right before suspend. Exiting releases the
# sleep lock xss-lock handed over, while the running i3lock keeps the session
# locked.
if pgrep -x i3lock >/dev/null; then
    exit 0
fi

# --nofork keeps i3lock in the foreground: xss-lock waits for it before
# letting the system suspend. The color shows if the image cannot be made.
args=(--nofork --color=111318 --ignore-empty-password --show-failed-attempts --show-keyboard-layout)

if [[ -f "$WALLPAPER" ]] && image="$(lock_image)"; then
    args+=(--image="$image")
fi

exec i3lock "${args[@]}"
