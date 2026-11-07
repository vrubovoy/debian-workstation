# ******************************************************************************
# @file    config.fish
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Fish shell; settings live in conf.d/, commands in functions/.
# @path    ~/.config/fish/config.fish
# @apply   exec fish
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

if status is-interactive; and type -q starship
    starship init fish | source
end
