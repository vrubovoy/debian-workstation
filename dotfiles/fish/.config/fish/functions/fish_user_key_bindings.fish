# =============================================================================
# Fish — key bindings
# =============================================================================
#
# Ctrl+V pastes the clipboard at the prompt. Programs such as Neovim still get
# Ctrl+V for themselves.
#
# Path:  ~/.config/fish/functions/fish_user_key_bindings.fish

function fish_user_key_bindings
    bind ctrl-v fish_clipboard_paste
end
