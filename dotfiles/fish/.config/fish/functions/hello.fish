# =============================================================================
# Workstation greeting
# =============================================================================
#
# Display the workstation system summary.
#
# Kitty supports Fastfetch image rendering through its graphics protocol.
# Other terminals receive the same information without the graphical logo.
#
# =============================================================================

function hello --description "Display workstation system information"

    if not type -q fastfetch
        return 0
    end


    if test "$TERM" = "xterm-kitty"

        command fastfetch

    else

        command fastfetch --logo none

    end

end