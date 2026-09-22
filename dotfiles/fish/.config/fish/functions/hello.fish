# =============================================================================
# Fish — hello
# =============================================================================
#
# System summary. The image logo needs Kitty's graphics protocol.
#
# Path:  ~/.config/fish/functions/hello.fish

function hello --description "Show system information"
    type -q fastfetch; or return 0

    if test "$TERM" = xterm-kitty
        fastfetch
    else
        fastfetch --logo none
    end
end
