# =============================================================================
# Yazi shell wrapper
# =============================================================================
#
# Start Yazi and update the Fish working directory when leaving it.
#
# Example:
#
#   ~/Projects ❯ y
#
# Navigate inside Yazi to:
#
#   ~/Documents
#
# Press q.
#
# Fish now continues in:
#
#   ~/Documents ❯
#
# Pressing Q in Yazi quits without changing the shell directory.
#
# =============================================================================

function y

    set tmp (mktemp -t "yazi-cwd.XXXXXX")

    command yazi $argv --cwd-file="$tmp"

    if read -z cwd < "$tmp"
        and test "$cwd" != "$PWD"
        and test -d "$cwd"

        builtin cd -- "$cwd"
    end

    command rm -f -- "$tmp"

end