# =============================================================================
# Fish — zoxide
# =============================================================================
#
# `z` jumps to directories from history; Yazi uses the same database.
#
# Path:  ~/.config/fish/conf.d/40-zoxide.fish

if status is-interactive; and type -q zoxide
    zoxide init fish | source
end
