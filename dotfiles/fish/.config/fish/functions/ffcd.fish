# Fuzzy-find a directory below the current one (or below the argument) and
# enter it. Unlike `z`, this searches the tree, not the history.
function ffcd --description "Fuzzy-find and enter a directory"
    set -l root .
    set -q argv[1]; and set root $argv[1]

    set -l selected (
        fd --type d --hidden --follow --max-depth 7 \
            --exclude .git --exclude node_modules --exclude .venv \
            --exclude target --exclude .cache \
            . "$root" |
        fzf --prompt="Directory > " \
            --preview='eza -lah --group-directories-first --icons=auto -- {} 2>/dev/null | head -200'
    )

    test -n "$selected"; and cd -- "$selected"
end
