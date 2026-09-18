# =============================================================================
# FZF
# =============================================================================
#
# Interactive fuzzy finding for Fish.
#
# Native bindings provided by FZF include:
#
#   Ctrl + R     command history
#   Ctrl + T     files
#   Alt  + C     directories
#
# Custom workstation functions such as ffcd/ffe/ffec build on top of the same
# tools but provide richer previews and explicit commands.
#
# =============================================================================

if status is-interactive
    and type -q fzf

    # -------------------------------------------------------------------------
    # Search sources
    # -------------------------------------------------------------------------

    # fd is exposed through ~/.local/bin/fd on Debian, because the Debian
    # package itself names the executable `fdfind`.

    set -gx FZF_CTRL_T_COMMAND \
        'fd --type f --hidden --follow --exclude .git'

    set -gx FZF_ALT_C_COMMAND \
        'fd --type d --hidden --follow --exclude .git'


    # -------------------------------------------------------------------------
    # Graphite Blue
    # -------------------------------------------------------------------------

    set -gx FZF_DEFAULT_OPTS \
        '--height=45% --layout=reverse --border=rounded' \
        '--info=inline' \
        '--pointer=> --marker=+' \
        '--color=bg+:#222630,bg:#111318,spinner:#56B6C2,hl:#89B4FA' \
        '--color=fg:#E6E9EF,header:#8E98A8,info:#8E98A8,pointer:#7AA2F7' \
        '--color=marker:#98C379,fg+:#E6E9EF,prompt:#7AA2F7,hl+:#89B4FA'


    # -------------------------------------------------------------------------
    # Fish integration
    # -------------------------------------------------------------------------

    fzf --fish | source

end