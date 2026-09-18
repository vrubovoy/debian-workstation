-- =============================================================================
-- Neovim autocommands
-- =============================================================================
--
-- Small editor behaviours which are useful regardless of programming language.
--
-- =============================================================================


-- =============================================================================
-- Autocommand group
-- =============================================================================

local group = vim.api.nvim_create_augroup(
    "WorkstationConfig",
    { clear = true }
)


-- =============================================================================
-- Yank feedback
-- =============================================================================
--
-- Briefly highlight text after yank.
--
-- This provides immediate visual confirmation without any plugin.

vim.api.nvim_create_autocmd(
    "TextYankPost",
    {
        group = group,
        callback = function()
            vim.highlight.on_yank({
                higroup = "IncSearch",
                timeout = 150,
            })
        end,
        desc = "Highlight yanked text",
    }
)


-- =============================================================================
-- Restore cursor position
-- =============================================================================
--
-- When reopening a normal file, return to the last position stored in ShaDa.
--
-- Help, Git commit messages and similar temporary buffers are excluded by the
-- mark validity checks.

vim.api.nvim_create_autocmd(
    "BufReadPost",
    {
        group = group,

        callback = function(args)
            local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
            local line_count = vim.api.nvim_buf_line_count(args.buf)

            local line = mark[1]
            local column = mark[2]

            if line > 0 and line <= line_count then
                pcall(
                    vim.api.nvim_win_set_cursor,
                    0,
                    { line, column }
                )
            end
        end,

        desc = "Restore previous cursor position",
    }
)


-- =============================================================================
-- External file changes
-- =============================================================================
--
-- Re-check files when returning to Neovim after using another application.
--
-- Combined with 'autoread', this means externally changed files are refreshed
-- automatically when they have no conflicting unsaved changes.

vim.api.nvim_create_autocmd(
    {
        "FocusGained",
        "TermClose",
        "TermLeave",
    },
    {
        group = group,

        command = "checktime",

        desc = "Check for files modified outside Neovim",
    }
)