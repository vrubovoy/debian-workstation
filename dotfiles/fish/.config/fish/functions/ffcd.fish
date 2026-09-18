# =============================================================================
# Fuzzy directory navigation
# =============================================================================
#
# Search directories below the current directory using:
#
#   fd -> fzf -> cd
#
# Unlike Zoxide:
#
#   z foo
#
# which searches directory history, ffcd searches the actual directory tree
# below the current working directory.
#
# =============================================================================

function ffcd --description "Fuzzy-find and enter a directory"

    if not type -q fd
        echo "ffcd: fd is not installed" >&2
        return 127
    end

    if not type -q fzf
        echo "ffcd: fzf is not installed" >&2
        return 127
    end


    set -l root "."

    if test (count $argv) -gt 0
        set root "$argv[1]"
    end


    set -l selected (
        fd \
            --type d \
            --hidden \
            --follow \
            --max-depth 7 \
            --exclude .git \
            --exclude node_modules \
            --exclude .venv \
            --exclude target \
            --exclude .cache \
            . "$root" |
        fzf \
            --prompt="Directory > " \
            --preview='eza -lah --group-directories-first --icons=auto -- {} 2>/dev/null | head -200'
    )


    if test -n "$selected"
        builtin cd -- "$selected"
    end

end