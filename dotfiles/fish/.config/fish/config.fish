# =============================================================================
# Fish configuration
# =============================================================================
#
# Debian workstation interactive shell.
#
# Design goals:
#   - Keep the main configuration extremely small.
#   - Split environment, colors and abbreviations into conf.d/.
#   - Use Starship as a minimal prompt.
#   - Keep shell behaviour independent from CachyOS/HyDE.
#
# =============================================================================


# =============================================================================
# Interactive shell
# =============================================================================

if status is-interactive

    # -------------------------------------------------------------------------
    # Starship prompt
    # -------------------------------------------------------------------------

    if type -q starship
        starship init fish | source
    end

end