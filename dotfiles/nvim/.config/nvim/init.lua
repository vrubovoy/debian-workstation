-- =============================================================================
-- Neovim
-- =============================================================================
--
-- A file explorer, fuzzy finder, Git signs, completion and language servers
-- per project. Project indentation comes from .editorconfig when present
-- (Neovim reads it natively).
--
-- Path:  ~/.config/nvim/init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("workstation.options")
require("workstation.keymaps")
require("workstation.autocmds")

vim.cmd.colorscheme("graphite-blue")

-- The plugins need Neovim 0.11 or later, the optional upstream release;
-- Debian's 0.10 runs with the built-in features only.
if vim.fn.has("nvim-0.11") == 1 then
    require("workstation.plugins")
    require("workstation.lsp").setup()
end
