-- =============================================================================
-- Neovim — autocommands
-- =============================================================================
--
-- Autocommands that apply to every file type.
--
-- Path:  ~/.config/nvim/lua/workstation/autocmds.lua

local group = vim.api.nvim_create_augroup("WorkstationConfig", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    desc = "Highlight yanked text",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    desc = "Restore the last cursor position",
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')

        if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- With 'autoread', reloads files changed outside Neovim when there are no
-- conflicting unsaved edits.
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = group,
    desc = "Check for files changed outside Neovim",
    command = "checktime",
})
