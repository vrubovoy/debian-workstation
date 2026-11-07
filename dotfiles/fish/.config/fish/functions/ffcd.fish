# ******************************************************************************
# @file    ffcd.fish
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   ffcd: fuzzy-find a directory below the current one and enter it.
# @path    ~/.config/fish/functions/ffcd.fish
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

function ffcd --description "Fuzzy-find and enter a directory"
    set -l root .
    set -q argv[1]; and set root $argv[1]

    set -l selected (
        fd --type d --hidden --follow --max-depth 7 \
            --exclude .git --exclude node_modules --exclude .venv \
            --exclude target --exclude .cache \
            . "$root" |
        fzf --prompt="Directory > " \
            --preview='eza -lah --group-directories-first --icons=auto -- {} 2>/dev/null | head -200'
    )

    test -n "$selected"; and cd -- "$selected"
end
