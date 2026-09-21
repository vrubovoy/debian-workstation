# =============================================================================
# Fish abbreviations
# =============================================================================
#
# Frequently used interactive command abbreviations.
#
# Unlike aliases, abbreviations expand visibly in the command line before the
# command is executed. The resulting shell history therefore remains explicit
# and readable.
#
# =============================================================================


# =============================================================================
# Directory navigation
# =============================================================================

abbr --add ..  'cd ..'
abbr --add ... 'cd ../..'

abbr --add .3 'cd ../../..'
abbr --add .4 'cd ../../../..'
abbr --add .5 'cd ../../../../..'


# =============================================================================
# Filesystem
# =============================================================================

abbr --add mkdir 'mkdir -p'


# =============================================================================
# Filesystem overview
# =============================================================================
#
# Keep the real POSIX/GNU `df` command untouched.

abbr --add disk duf


# =============================================================================
# eza
# =============================================================================
#
# Keep the familiar ls/l/ll/ld/lt command vocabulary while using eza
# underneath.

abbr --add ls 'eza --group-directories-first --icons=auto'

abbr --add l \
    'eza -la --group-directories-first --icons=auto'

abbr --add ll \
    'eza -lah --git --group-directories-first --icons=auto'

abbr --add ld \
    'eza -lahD --group-directories-first --icons=auto'

abbr --add lt \
    'eza --tree --level=2 --group-directories-first --icons=auto'


# =============================================================================
# Git
# =============================================================================

abbr --add g git

# Lazygit TUI.
abbr --add lg lazygit


# =============================================================================
# Build
# =============================================================================

abbr --add m  'make -j8'
abbr --add mc 'make clean'


# =============================================================================
# Python
# =============================================================================
#
# Debian consistently provides python3. We keep the old `p` abbreviation but
# point it at the explicit Debian interpreter name.

abbr --add p python3

# Open VSCodium.
abbr --add vc codium
