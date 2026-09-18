-- =============================================================================
-- Neovim configuration
-- =============================================================================
--
-- Debian workstation terminal editor.
--
-- Design goals:
--   - Fast and predictable editing.
--   - No external plugins in the base configuration.
--   - Good defaults for C/C++, shell scripts and system configuration files.
--   - Native system clipboard integration.
--   - Persistent undo.
--   - Project formatting controlled by EditorConfig when available.
--   - Graphite Blue appearance consistent with the desktop.
--
-- =============================================================================


-- =============================================================================
-- Leader keys
-- =============================================================================
--
-- Leader must be defined before mappings are loaded.
--
-- Space is intentionally retained from the previous Vim configuration.

vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- =============================================================================
-- Configuration modules
-- =============================================================================

require("workstation.options")
require("workstation.keymaps")
require("workstation.autocmds")


-- =============================================================================
-- Appearance
-- =============================================================================

vim.cmd.colorscheme("graphite-blue")