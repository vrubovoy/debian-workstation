-- =============================================================================
-- Neovim options
-- =============================================================================
--
-- Global editing behaviour for the Debian workstation.
--
-- Project-specific formatting should preferably be defined by `.editorconfig`.
-- Neovim has native EditorConfig support and enables it by default.
--
-- =============================================================================

local opt = vim.opt


-- =============================================================================
-- Encoding
-- =============================================================================
--
-- Neovim internally works in UTF-8.
--
-- Explicitly prefer Unix line endings for new files while still allowing
-- existing DOS/Windows files to be detected correctly.

opt.fileformats = { "unix", "dos" }


-- =============================================================================
-- Line numbers
-- =============================================================================

-- Show normal absolute line numbers.
opt.number = true

-- Relative numbers are intentionally disabled.
--
-- They are excellent for some Vim-heavy workflows, but absolute line numbers
-- are more useful when reading compiler errors, logs and source locations.
opt.relativenumber = false

-- Stable width for the line-number column.
opt.numberwidth = 4


-- =============================================================================
-- Indentation
-- =============================================================================
--
-- Default workstation indentation:
--
--   Tab display width:  4
--   Indent width:       4
--   Insert spaces:      yes
--
-- `.editorconfig` can override these values per project.

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4

opt.expandtab = true

-- Automatically continue the current indentation on new lines.
opt.autoindent = true

-- Use filetype-aware indentation rules provided by Neovim.
opt.smartindent = false


-- =============================================================================
-- Text display
-- =============================================================================

-- Long source-code lines should remain physically visible rather than being
-- wrapped visually across multiple screen rows.
opt.wrap = false

-- Keep some context above and below the cursor.
opt.scrolloff = 5

-- Same concept horizontally.
opt.sidescrolloff = 8

-- Visually mark the current line.
opt.cursorline = true

-- Keep a permanent sign column.
--
-- This prevents the text from shifting horizontally if diagnostics or other
-- signs are displayed in the future.
opt.signcolumn = "yes"

-- Soft guide for source-code line length.
opt.colorcolumn = "100"

-- Hide the traditional '~' characters after the end of the file.
opt.fillchars:append({
    eob = " ",
})


-- =============================================================================
-- Search
-- =============================================================================

-- Highlight all matches.
opt.hlsearch = true

-- Highlight matches while the search expression is still being entered.
opt.incsearch = true

-- Searches are case-insensitive by default...
opt.ignorecase = true

-- ...unless the expression contains an uppercase character.
opt.smartcase = true


-- =============================================================================
-- Substitution
-- =============================================================================
--
-- Show a live preview of :substitute changes in a separate preview split.
--
-- Example:
--
--   :%s/foo/bar/g

opt.inccommand = "split"


-- =============================================================================
-- Clipboard
-- =============================================================================
--
-- Use the X11 system clipboard as the normal Neovim clipboard.
--
-- `xclip` is installed as part of the workstation package set.
--
-- This means ordinary:
--
--   y
--   yy
--   p
--
-- can interoperate naturally with graphical applications.

opt.clipboard = "unnamedplus"


-- =============================================================================
-- Mouse
-- =============================================================================
--
-- Mouse support is useful for:
--
--   - selecting windows;
--   - resizing splits;
--   - positioning the cursor;
--   - scrolling.
--
-- It does not interfere with the normal keyboard-first Vim workflow.

opt.mouse = "a"


-- =============================================================================
-- Undo and recovery
-- =============================================================================

-- Preserve undo history after the file is closed.
opt.undofile = true

-- Keep swap files enabled.
--
-- Swap files protect unsaved work if Neovim or the system crashes.
opt.swapfile = true

-- Separate backup files are unnecessary because:
--
--   - swap protects unsaved edits;
--   - persistent undo protects edit history;
--   - source files should normally be under version control.
opt.backup = false
opt.writebackup = false


-- =============================================================================
-- External file changes
-- =============================================================================

-- Automatically notice files changed by another program where possible.
opt.autoread = true


-- =============================================================================
-- Windows and splits
-- =============================================================================

-- Vertical splits open on the right.
opt.splitright = true

-- Horizontal splits open below.
opt.splitbelow = true

-- Keep all windows reasonably sized after terminal resizing.
opt.equalalways = true


-- =============================================================================
-- Command-line completion
-- =============================================================================

-- Enhanced command-line completion.
opt.wildmenu = true

-- First complete as much as possible, then display all candidates.
opt.wildmode = "longest:full,full"


-- =============================================================================
-- Completion
-- =============================================================================
--
-- These settings also provide sensible behaviour if native LSP/completion is
-- added later.

opt.completeopt = {
    "menu",
    "menuone",
    "noselect",
}


-- =============================================================================
-- Timing
-- =============================================================================

-- Faster CursorHold/update events without being excessively aggressive.
opt.updatetime = 250

-- Keep mapping sequences responsive.
opt.timeoutlen = 400


-- =============================================================================
-- Confirmation
-- =============================================================================
--
-- Commands such as :q with unsaved changes can display a confirmation instead
-- of only failing with an error.

opt.confirm = true


-- =============================================================================
-- Search tools
-- =============================================================================
--
-- Use ripgrep for Neovim's :grep command.
--
-- Example:
--
--   :grep MyClass
--   :copen
--
-- Results are loaded directly into the quickfix list.

if vim.fn.executable("rg") == 1 then
    opt.grepprg = "rg --vimgrep --smart-case"
    opt.grepformat = "%f:%l:%c:%m"
end


-- =============================================================================
-- Colors
-- =============================================================================

-- Explicitly enable 24-bit RGB colors.
--
-- Neovim 0.10 normally enables this automatically in capable terminals, but
-- the explicit setting documents that our Graphite Blue theme requires it.
opt.termguicolors = true

opt.background = "dark"


-- =============================================================================
-- Messages / interface
-- =============================================================================

-- Suppress the startup splash message.
opt.shortmess:append("I")

-- Always show the normal status line when windows are present.
opt.laststatus = 2

-- Show the tab line only when more than one tab exists.
opt.showtabline = 1