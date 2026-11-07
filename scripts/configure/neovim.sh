#!/usr/bin/env bash
# ******************************************************************************
# @file    neovim.sh
# @author  Vrubovoy (github.com/vrubovoy)
# @brief   Downloads the Neovim plugins at their pinned versions.
# ******************************************************************************
# Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
# ******************************************************************************

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
