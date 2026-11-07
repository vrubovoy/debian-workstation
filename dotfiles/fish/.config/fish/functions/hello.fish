# ******************************************************************************
# @file    hello.fish
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   hello: the system summary, with the image logo in Kitty.
# @path    ~/.config/fish/functions/hello.fish
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

function hello --description "Show system information"
    type -q fastfetch; or return 0

    if test "$TERM" = xterm-kitty
        fastfetch
    else
        fastfetch --logo none
    end
end
