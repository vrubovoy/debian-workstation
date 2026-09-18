# =============================================================================
# Fish greeting
# =============================================================================
#
# Show Fastfetch when a new interactive Fish shell is opened.
#
# Kitty supports its own graphics protocol, so Fastfetch can display a real
# image instead of an ASCII distro logo.
#
# On terminals which do not support Kitty graphics (TTY, SSH, etc.) the same
# system information is displayed without an image.
#
# =============================================================================

function fish_greeting

    if not type -q fastfetch
        return
    end

    if test "$TERM" = "xterm-kitty"
        fastfetch
    else
        fastfetch --logo none
    end

end