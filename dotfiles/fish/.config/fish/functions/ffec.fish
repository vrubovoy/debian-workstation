# =============================================================================
# Fish — ffec
# =============================================================================
#
# Search file contents with ripgrep, pick a match in fzf and open Neovim at
# that line and column.
#
# Path:  ~/.config/fish/functions/ffec.fish

function ffec --description "Search file contents and open the selected match"
    set -l query (string join " " -- $argv)

    if test -z "$query"
        read --prompt-str="Search > " query
    end

    test -n "$query"; or return 0

    set -l selected (
        rg --line-number --column --no-heading --smart-case --color=never -- "$query" |
        fzf --delimiter=: --prompt="Match > " \
            --preview='bat --color=always --style=numbers --highlight-line {2} -- {1} 2>/dev/null' \
            --preview-window='right,60%,+{2}-5'
    )

    test -n "$selected"; or return 0

    set -l fields (string split -m 3 ":" -- "$selected")
    nvim "+call cursor($fields[2], $fields[3])" -- "$fields[1]"
end
