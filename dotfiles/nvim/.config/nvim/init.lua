-- *****************************************************************************
-- @file    init.lua
-- @author  Vrubovoy (github.com/vrubovoy)
-- @brief   Neovim: options, keys, plugins and language servers.
-- @path    ~/.config/nvim/init.lua
-- *****************************************************************************
-- Copyright (c) 2026 Vrubovoy. MIT License, see LICENSE.
-- *****************************************************************************

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("workstation.options")
require("workstation.keymaps")
require("workstation.autocmds")

vim.cmd.colorscheme("graphite-blue")

-- The plugins need Neovim 0.11 or later, the optional upstream release;
-- Debian's 0.10 runs with the built-in features only.
if vim.fn.has("nvim-0.11") == 1 then
    if require("workstation.plugins") then
        require("workstation.lsp").setup()
    end
end
