# =============================================================================
# Fuzzy file editor
# =============================================================================
#
# Find files using fd, preview them using bat and open the selected files in
# the workstation editor.
#
# Multiple files can be selected with Tab inside FZF.
#
# =============================================================================

function ffe --description "Fuzzy-find files and open them in the editor"

    if not type -q fd
        echo "ffe: fd is not installed" >&2
        return 127
    end

    if not type -q fzf
        echo "ffe: fzf is not installed" >&2
        return 127
    end


    set -l root "."

    if test (count $argv) -gt 0
        set root "$argv[1]"
    end


    set -l selected (
        fd \
            --type f \
            --hidden \
            --follow \
            --max-depth 5 \
            --exclude .git \
            --exclude node_modules \
            --exclude .venv \
            --exclude target \
            --exclude .cache \
            --print0 \
            . "$root" |

        fzf \
            --read0 \
            --print0 \
            --multi \
            --prompt="Edit > " \
            --preview='bat --color=always --style=numbers --line-range=:400 -- {} 2>/dev/null' |

        string split0
    )


    if test (count $selected) -eq 0
        return 0
    end


    $EDITOR -- $selected

end