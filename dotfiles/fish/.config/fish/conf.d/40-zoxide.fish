# =============================================================================
# Zoxide
# =============================================================================
#
# Smart directory history used by:
#
#   - Fish shell;
#   - Yazi's built-in Z shortcut.
#
# =============================================================================

if status is-interactive
    and type -q zoxide

    zoxide init fish | source

end