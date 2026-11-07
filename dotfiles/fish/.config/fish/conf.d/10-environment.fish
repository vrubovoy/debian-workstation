# ******************************************************************************
# @file    10-environment.fish
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Fish environment: PATH, editor, pager and tool colors.
# @path    ~/.config/fish/conf.d/10-environment.fish
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

fish_add_path --prepend "$HOME/.local/bin"

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SUDO_EDITOR nvim

set -gx PAGER less
set -gx LESS -R

# eza's default colors without its bold, which Kitty would draw as italic.
set -gx EZA_COLORS (string join : \
    di=34 ex=32 bd=33 cd=33 so=31 'mp=34;4' \
    ur=33 uw=31 'ux=32;4' ue=32 uu=33 gu=33 lc=31 Gd=33 \
    vi=35 lo=36 cr=32 'bu=33;4' sc=33 xx=90 sn=32 df=32)

# bat follows the terminal's own palette.
set -gx BAT_THEME ansi

# Lets pinentry ask for GPG passphrases in the terminal when needed.
if status is-interactive
    set -gx GPG_TTY (tty)
end
