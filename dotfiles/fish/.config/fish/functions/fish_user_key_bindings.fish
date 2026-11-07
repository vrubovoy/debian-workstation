# ******************************************************************************
# @file    fish_user_key_bindings.fish
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Fish key bindings: Ctrl+V pastes the clipboard at the prompt.
# @path    ~/.config/fish/functions/fish_user_key_bindings.fish
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

function fish_user_key_bindings
    bind ctrl-v fish_clipboard_paste
end
