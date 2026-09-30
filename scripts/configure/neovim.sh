#!/usr/bin/env bash
# Neovim plugins at the versions in dotfiles/nvim/.config/nvim/lazy-lock.json,
# downloaded now so the first start does not. They need Neovim 0.11 or later,
# the optional upstream release; Debian's 0.10 runs without them.

set -Eeuo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

if ! command -v nvim >/dev/null ||
   ! nvim --headless --clean +'lua os.exit(vim.fn.has("nvim-0.11") == 1 and 0 or 1)'; then
    info 'Neovim 0.11 or later is not installed; plugins skipped.'
    exit 0
fi

info 'Installing Neovim plugins'
nvim --headless '+Lazy! restore' +qa
