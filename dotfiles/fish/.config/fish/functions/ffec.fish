# =============================================================================
# Fuzzy content search and edit
# =============================================================================
#
# Search file contents recursively with ripgrep.
#
# Workflow:
#
#   search expression
#        ↓
#      ripgrep
#        ↓
#        FZF
#        ↓
#    bat preview
#        ↓
# Neovim at matching line
#
# =============================================================================

function ffec --description "Search file contents and open the selected match"

    if not type -q rg
        echo "ffec: ripgrep is not installed" >&2
        return 127
    end

    if not type -q fzf
        echo "ffec: fzf is not installed" >&2
        return 127
    end


    # -------------------------------------------------------------------------
    # Search expression
    # -------------------------------------------------------------------------

    set -l query (string join " " -- $argv)

    if test -z "$query"

        read \
            --prompt-str="Search > " \
            query

    end


    if test -z "$query"
        return 0
    end


    # -------------------------------------------------------------------------
    # Search
    # -------------------------------------------------------------------------

    set -l selected (
        rg \
            --line-number \
            --column \
            --no-heading \
            --smart-case \
            --color=never \
            -- \
            "$query" |

        fzf \
            --delimiter=: \
            --prompt="Match > " \
            --preview='bat --color=always --style=numbers --highlight-line {2} -- {1} 2>/dev/null' \
            --preview-window='right,60%,+{2}-5'
    )


    if test -z "$selected"
        return 0
    end


    # -------------------------------------------------------------------------
    # Extract location
    # -------------------------------------------------------------------------

    set -l fields (string split -m 3 ":" -- "$selected")

    set -l file   "$fields[1]"
    set -l line   "$fields[2]"
    set -l column "$fields[3]"


    # -------------------------------------------------------------------------
    # Editor
    # -------------------------------------------------------------------------

    # The workstation editor is Neovim, so we can position the cursor at the
    # exact ripgrep line and column.

    nvim \
        "+call cursor($line, $column)" \
        -- \
        "$file"

end