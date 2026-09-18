# =============================================================================
# Fish environment
# =============================================================================
#
# Environment variables and user PATH shared by interactive shell sessions.
#
# =============================================================================


# =============================================================================
# User executables
# =============================================================================

# Workstation helper scripts live here.
fish_add_path --prepend "$HOME/.local/bin"


# =============================================================================
# Editors
# =============================================================================

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SUDO_EDITOR nvim


# =============================================================================
# Pager
# =============================================================================

set -gx PAGER less
set -gx LESS "-R"


# =============================================================================
# bat
# =============================================================================
#
# ANSI makes bat use the terminal's own Graphite Blue palette rather than
# introducing another unrelated colorscheme.

set -gx BAT_THEME ansi


# =============================================================================
# GnuPG
# =============================================================================
#
# Required when GnuPG falls back to terminal-based interaction and useful for
# tools invoking GPG from the interactive shell.

if status is-interactive
    set -gx GPG_TTY (tty)
end


# =============================================================================
# Locale
# =============================================================================
#
# Do not override LANG/LC_* here.
#
# Locale belongs to the operating-system configuration and should remain
# consistent outside Fish as well.