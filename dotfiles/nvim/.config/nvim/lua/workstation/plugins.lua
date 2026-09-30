-- =============================================================================
-- Neovim — plugins
-- =============================================================================
--
-- Managed by lazy.nvim at the versions in lazy-lock.json next to init.lua.
-- :Lazy update moves them forward and rewrites that file in the repository.
-- The installer downloads them beforehand (scripts/configure/neovim.sh).
--
-- Path:  ~/.config/nvim/lua/workstation/plugins.lua

local path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- lazy.nvim itself starts at its commit in lazy-lock.json too; it does not
-- move itself on :Lazy restore.
if not vim.uv.fs_stat(path) then
    local ok, lock = pcall(function()
        local file = vim.fn.stdpath("config") .. "/lazy-lock.json"
        return vim.json.decode(table.concat(vim.fn.readfile(file), "\n"))
    end)
    local commit = ok and lock["lazy.nvim"] and lock["lazy.nvim"].commit

    vim.fn.system({
        "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", path,
    })

    if vim.v.shell_error == 0 and commit then
        vim.fn.system({ "git", "-C", path, "checkout", "--quiet", commit })
    end

    if vim.v.shell_error ~= 0 then
        vim.fn.delete(path, "rf")
        vim.notify("lazy.nvim could not be downloaded; starting without plugins.",
            vim.log.levels.WARN)
        return
    end
end

vim.opt.rtp:prepend(path)

-- nvim-tree takes the place of netrw.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lazy").setup({
    spec = {
        -- Language servers: Mason installs them, nvim-lspconfig describes how
        -- to start them. None is enabled here; see lua/workstation/lsp.lua.
        { "mason-org/mason.nvim", opts = {} },
        { "neovim/nvim-lspconfig", lazy = false },
        {
            "mason-org/mason-lspconfig.nvim",
            dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
            opts = { automatic_enable = false },
        },

        {
            "saghen/blink.cmp",
            version = "1.*",
            event = { "InsertEnter", "CmdlineEnter" },
            opts = {
                -- Tab accepts, as in VSCodium.
                keymap = { preset = "super-tab" },
                completion = { documentation = { auto_show = true } },
                fuzzy = { implementation = "prefer_rust_with_warning" },
            },
        },

        {
            "nvim-tree/nvim-tree.lua",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            -- Loaded at startup so `nvim <directory>` opens it.
            lazy = false,
            keys = {
                { "<leader>e", "<cmd>NvimTreeFindFileToggle<CR>", desc = "File explorer" },
            },
            opts = {
                renderer = {
                    root_folder_label = false,
                    indent_markers = { enable = true },
                },
                filters = { custom = { "^\\.git$" } },
            },
        },

        {
            "ibhagwan/fzf-lua",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            cmd = "FzfLua",
            keys = {
                { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find files" },
                { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Search in files" },
                { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Find buffers" },
                { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
                { "<leader>fh", "<cmd>FzfLua helptags<CR>", desc = "Find help" },
            },
            opts = {},
        },

        {
            "lewis6991/gitsigns.nvim",
            event = { "BufReadPre", "BufNewFile" },
            opts = {
                on_attach = function(buffer)
                    local gitsigns = require("gitsigns")

                    local function map(lhs, rhs, desc)
                        vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc })
                    end

                    map("]h", function() gitsigns.nav_hunk("next") end, "Next change")
                    map("[h", function() gitsigns.nav_hunk("prev") end, "Previous change")
                    map("<leader>hp", gitsigns.preview_hunk, "Preview change")
                    map("<leader>hs", gitsigns.stage_hunk, "Stage change")
                    map("<leader>hr", gitsigns.reset_hunk, "Reset change")
                    map("<leader>hb", gitsigns.blame_line, "Blame line")
                end,
            },
        },
    },

    install = { colorscheme = { "graphite-blue" } },
    change_detection = { notify = false },
    rocks = { enabled = false },
})
