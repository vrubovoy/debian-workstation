# System summary. The image logo needs Kitty's graphics protocol.
function hello --description "Show system information"
    type -q fastfetch; or return 0

    if test "$TERM" = xterm-kitty
        fastfetch
    else
        fastfetch --logo none
    end
end
