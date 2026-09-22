# =============================================================================
# Fish — fzf
# =============================================================================
#
# Key bindings: Ctrl+R history, Ctrl+T files, Alt+C directories.
#
# Path:  ~/.config/fish/conf.d/50-fzf.fish

if status is-interactive; and type -q fzf
    set -gx FZF_CTRL_T_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'

    set -gx FZF_DEFAULT_OPTS \
        '--height=45% --layout=reverse --border=rounded' \
        '--info=inline' \
        '--pointer=> --marker=+' \
        '--color=bg+:#222630,bg:#111318,spinner:#56B6C2,hl:#89B4FA' \
        '--color=fg:#E6E9EF,header:#8E98A8,info:#8E98A8,pointer:#7AA2F7' \
        '--color=marker:#98C379,fg+:#E6E9EF,prompt:#7AA2F7,hl+:#89B4FA'

    fzf --fish | source
end
