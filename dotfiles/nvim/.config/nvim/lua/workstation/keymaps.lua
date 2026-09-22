-- Key mappings: a few additions on top of standard Vim behaviour.

local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlighting")

map("n", "<leader>w", "<cmd>write<CR>", "Write file")
map("n", "<leader>q", "<cmd>quit<CR>", "Quit window")

-- Ctrl+H/J/K/L between splits; i3 uses Super, so nothing collides.
map("n", "<C-h>", "<C-w>h", "Focus left window")
map("n", "<C-j>", "<C-w>j", "Focus lower window")
map("n", "<C-k>", "<C-w>k", "Focus upper window")
map("n", "<C-l>", "<C-w>l", "Focus right window")

map("n", "<leader>sv", "<cmd>vsplit<CR>", "Vertical split")
map("n", "<leader>sh", "<cmd>split<CR>", "Horizontal split")
map("n", "<leader>se", "<C-w>=", "Equalize splits")
map("n", "<leader>sx", "<cmd>close<CR>", "Close split")

map("n", "[b", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "]b", "<cmd>bnext<CR>", "Next buffer")
map("n", "<leader>bd", "<cmd>bdelete<CR>", "Delete buffer")

-- Keep the selection after indenting so it can be repeated.
map("v", "<", "<gv", "Indent left and keep selection")
map("v", ">", ">gv", "Indent right and keep selection")
