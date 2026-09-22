-- =============================================================================
-- Neovim
-- =============================================================================
--
-- Built-in features only, no plugins. Project indentation comes from
-- .editorconfig when present (Neovim reads it natively).
--
-- Path:  ~/.config/nvim/init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("workstation.options")
require("workstation.keymaps")
require("workstation.autocmds")

vim.cmd.colorscheme("graphite-blue")
