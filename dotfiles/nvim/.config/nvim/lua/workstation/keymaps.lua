-- =============================================================================
-- Neovim key mappings
-- =============================================================================
--
-- Philosophy:
--
--   - Preserve standard Vim behaviour wherever possible.
--   - Add only mappings which clearly improve daily editing.
--   - Do not build a plugin-like command layer inside the editor.
--
-- Leader:
--
--   Space
--
-- =============================================================================

local map = vim.keymap.set


local function opts(description)
    return {
        silent = true,
        desc = description,
    }
end


-- =============================================================================
-- Search
-- =============================================================================

-- Escape clears highlighted search results.
--
-- Escape keeps all of its normal behaviour in Insert/Visual mode.
map(
    "n",
    "<Esc>",
    "<cmd>nohlsearch<CR>",
    opts("Clear search highlighting")
)


-- =============================================================================
-- Files
-- =============================================================================

map(
    "n",
    "<leader>w",
    "<cmd>write<CR>",
    opts("Write file")
)

map(
    "n",
    "<leader>q",
    "<cmd>quit<CR>",
    opts("Quit window")
)


-- =============================================================================
-- Window navigation
-- =============================================================================
--
-- Ctrl + H/J/K/L moves between Neovim splits.
--
-- These combinations do not collide with the i3 bindings because i3 uses
-- Super for window-manager navigation.

map("n", "<C-h>", "<C-w>h", opts("Focus left window"))
map("n", "<C-j>", "<C-w>j", opts("Focus lower window"))
map("n", "<C-k>", "<C-w>k", opts("Focus upper window"))
map("n", "<C-l>", "<C-w>l", opts("Focus right window"))


-- =============================================================================
-- Split management
-- =============================================================================

map(
    "n",
    "<leader>sv",
    "<cmd>vsplit<CR>",
    opts("Vertical split")
)

map(
    "n",
    "<leader>sh",
    "<cmd>split<CR>",
    opts("Horizontal split")
)

map(
    "n",
    "<leader>se",
    "<C-w>=",
    opts("Equalize splits")
)

map(
    "n",
    "<leader>sx",
    "<cmd>close<CR>",
    opts("Close split")
)


-- =============================================================================
-- Buffer navigation
-- =============================================================================
--
-- [b / ]b follow Vim's general convention:
--
--   [something -> previous
--   ]something -> next

map(
    "n",
    "[b",
    "<cmd>bprevious<CR>",
    opts("Previous buffer")
)

map(
    "n",
    "]b",
    "<cmd>bnext<CR>",
    opts("Next buffer")
)

map(
    "n",
    "<leader>bd",
    "<cmd>bdelete<CR>",
    opts("Delete buffer")
)


-- =============================================================================
-- Visual indentation
-- =============================================================================
--
-- Standard < and > normally leave Visual mode after indenting.
--
-- Re-selecting the region makes repeated indentation significantly easier.

map(
    "v",
    "<",
    "<gv",
    opts("Indent left and keep selection")
)

map(
    "v",
    ">",
    ">gv",
    opts("Indent right and keep selection")
)