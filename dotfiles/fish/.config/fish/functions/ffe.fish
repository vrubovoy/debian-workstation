# =============================================================================
# Fish — ffe
# =============================================================================
#
# Fuzzy-find files (Tab selects several) and open them in $EDITOR.
#
# Path:  ~/.config/fish/functions/ffe.fish

function ffe --description "Fuzzy-find files and open them in the editor"
    set -l root .
    set -q argv[1]; and set root $argv[1]

    set -l selected (
        fd --type f --hidden --follow --max-depth 5 \
            --exclude .git --exclude node_modules --exclude .venv \
            --exclude target --exclude .cache \
            --print0 . "$root" |
        fzf --read0 --print0 --multi --prompt="Edit > " \
            --preview='bat --color=always --style=numbers --line-range=:400 -- {} 2>/dev/null' |
        string split0
    )

    test (count $selected) -gt 0; and $EDITOR -- $selected
end
