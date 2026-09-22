fish_add_path --prepend "$HOME/.local/bin"

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SUDO_EDITOR nvim

set -gx PAGER less
set -gx LESS -R

# bat follows the terminal's own palette.
set -gx BAT_THEME ansi

# Lets pinentry ask for GPG passphrases in the terminal when needed.
if status is-interactive
    set -gx GPG_TTY (tty)
end
