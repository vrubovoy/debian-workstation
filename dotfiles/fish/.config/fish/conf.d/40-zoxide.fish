# ******************************************************************************
# @file    40-zoxide.fish
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   zoxide: `z` jumps to visited directories; Yazi shares its database.
# @path    ~/.config/fish/conf.d/40-zoxide.fish
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

if status is-interactive; and type -q zoxide
    zoxide init fish | source
end
