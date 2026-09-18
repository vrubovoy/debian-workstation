-- =============================================================================
-- Graphite Blue — Neovim
-- =============================================================================
--
-- Native Neovim colorscheme for the Debian workstation.
--
-- No external theme plugin is required.
--
-- Palette shared with:
--
--   i3
--   i3status
--   Kitty
--   Rofi
--   Dunst
--   Picom
--   LightDM
--
-- =============================================================================


-- =============================================================================
-- Initialization
-- =============================================================================

vim.cmd("highlight clear")

if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "graphite-blue"


-- =============================================================================
-- Palette
-- =============================================================================

local c = {
    bg          = "#111318",
    surface     = "#1A1D24",
    surface_alt = "#222630",
    border      = "#303744",

    fg          = "#E6E9EF",
    muted       = "#8E98A8",
    subtle      = "#5C6370",

    accent      = "#7AA2F7",
    accent_hi   = "#89B4FA",

    red         = "#E06C75",
    green       = "#98C379",
    yellow      = "#E5C07B",
    blue        = "#7AA2F7",
    magenta     = "#C678DD",
    cyan        = "#56B6C2",

    orange      = "#D19A66",
}


local hl = vim.api.nvim_set_hl


-- =============================================================================
-- Editor
-- =============================================================================

hl(0, "Normal", {
    fg = c.fg,
    bg = c.bg,
})

hl(0, "NormalNC", {
    fg = c.fg,
    bg = c.bg,
})

hl(0, "NormalFloat", {
    fg = c.fg,
    bg = c.surface,
})

hl(0, "FloatBorder", {
    fg = c.accent,
    bg = c.surface,
})

hl(0, "CursorLine", {
    bg = c.surface,
})

hl(0, "CursorColumn", {
    bg = c.surface,
})

hl(0, "ColorColumn", {
    bg = c.surface,
})

hl(0, "LineNr", {
    fg = c.subtle,
    bg = c.bg,
})

hl(0, "CursorLineNr", {
    fg = c.accent,
    bg = c.surface,
    bold = true,
})

hl(0, "SignColumn", {
    fg = c.muted,
    bg = c.bg,
})

hl(0, "WinSeparator", {
    fg = c.border,
    bg = c.bg,
})


-- =============================================================================
-- Selection and search
-- =============================================================================

hl(0, "Visual", {
    bg = c.border,
})

hl(0, "Search", {
    fg = c.bg,
    bg = c.yellow,
})

hl(0, "IncSearch", {
    fg = c.bg,
    bg = c.accent,
    bold = true,
})

hl(0, "CurSearch", {
    fg = c.bg,
    bg = c.accent_hi,
    bold = true,
})

hl(0, "MatchParen", {
    fg = c.accent_hi,
    bg = c.surface_alt,
    bold = true,
})


-- =============================================================================
-- Interface
-- =============================================================================

hl(0, "StatusLine", {
    fg = c.fg,
    bg = c.surface_alt,
    bold = true,
})

hl(0, "StatusLineNC", {
    fg = c.muted,
    bg = c.surface,
})

hl(0, "TabLine", {
    fg = c.muted,
    bg = c.surface,
})

hl(0, "TabLineFill", {
    fg = c.muted,
    bg = c.bg,
})

hl(0, "TabLineSel", {
    fg = c.bg,
    bg = c.accent,
    bold = true,
})

hl(0, "Pmenu", {
    fg = c.fg,
    bg = c.surface,
})

hl(0, "PmenuSel", {
    fg = c.bg,
    bg = c.accent,
    bold = true,
})

hl(0, "PmenuSbar", {
    bg = c.surface_alt,
})

hl(0, "PmenuThumb", {
    bg = c.accent,
})

hl(0, "WildMenu", {
    fg = c.bg,
    bg = c.accent,
    bold = true,
})


-- =============================================================================
-- General text
-- =============================================================================

hl(0, "Comment", {
    fg = c.subtle,
    italic = true,
})

hl(0, "Constant", {
    fg = c.orange,
})

hl(0, "String", {
    fg = c.green,
})

hl(0, "Character", {
    fg = c.green,
})

hl(0, "Number", {
    fg = c.orange,
})

hl(0, "Boolean", {
    fg = c.orange,
    bold = true,
})

hl(0, "Float", {
    fg = c.orange,
})

hl(0, "Identifier", {
    fg = c.fg,
})

hl(0, "Function", {
    fg = c.blue,
})


-- =============================================================================
-- Language constructs
-- =============================================================================

hl(0, "Statement", {
    fg = c.magenta,
})

hl(0, "Conditional", {
    fg = c.magenta,
})

hl(0, "Repeat", {
    fg = c.magenta,
})

hl(0, "Label", {
    fg = c.magenta,
})

hl(0, "Operator", {
    fg = c.cyan,
})

hl(0, "Keyword", {
    fg = c.magenta,
    bold = true,
})

hl(0, "Exception", {
    fg = c.red,
})


-- =============================================================================
-- Preprocessor
-- =============================================================================

hl(0, "PreProc", {
    fg = c.cyan,
})

hl(0, "Include", {
    fg = c.cyan,
})

hl(0, "Define", {
    fg = c.cyan,
})

hl(0, "Macro", {
    fg = c.cyan,
})

hl(0, "PreCondit", {
    fg = c.cyan,
})


-- =============================================================================
-- Types
-- =============================================================================

hl(0, "Type", {
    fg = c.yellow,
})

hl(0, "StorageClass", {
    fg = c.yellow,
})

hl(0, "Structure", {
    fg = c.yellow,
})

hl(0, "Typedef", {
    fg = c.yellow,
})


-- =============================================================================
-- Special syntax
-- =============================================================================

hl(0, "Special", {
    fg = c.cyan,
})

hl(0, "SpecialChar", {
    fg = c.cyan,
})

hl(0, "Delimiter", {
    fg = c.muted,
})

hl(0, "Underlined", {
    fg = c.accent,
    underline = true,
})

hl(0, "Todo", {
    fg = c.bg,
    bg = c.yellow,
    bold = true,
})


-- =============================================================================
-- Filesystem
-- =============================================================================

hl(0, "Directory", {
    fg = c.accent,
    bold = true,
})


-- =============================================================================
-- Messages
-- =============================================================================

hl(0, "ErrorMsg", {
    fg = c.red,
    bold = true,
})

hl(0, "WarningMsg", {
    fg = c.yellow,
})

hl(0, "MoreMsg", {
    fg = c.green,
})

hl(0, "Question", {
    fg = c.accent,
})

hl(0, "Title", {
    fg = c.accent,
    bold = true,
})


-- =============================================================================
-- Diff
-- =============================================================================

hl(0, "DiffAdd", {
    fg = c.green,
    bg = "#18231D",
})

hl(0, "DiffChange", {
    fg = c.yellow,
    bg = "#29251B",
})

hl(0, "DiffDelete", {
    fg = c.red,
    bg = "#29191D",
})

hl(0, "DiffText", {
    fg = c.bg,
    bg = c.yellow,
    bold = true,
})


-- =============================================================================
-- Diagnostics
-- =============================================================================
--
-- These are already useful for built-in diagnostics and mean the theme is
-- ready if native LSP is enabled later.

hl(0, "DiagnosticError", {
    fg = c.red,
})

hl(0, "DiagnosticWarn", {
    fg = c.yellow,
})

hl(0, "DiagnosticInfo", {
    fg = c.blue,
})

hl(0, "DiagnosticHint", {
    fg = c.cyan,
})


-- =============================================================================
-- Whitespace / non-text
-- =============================================================================

hl(0, "NonText", {
    fg = c.border,
})

hl(0, "Whitespace", {
    fg = c.border,
})

hl(0, "SpecialKey", {
    fg = c.subtle,
})


-- =============================================================================
-- Spelling
-- =============================================================================

hl(0, "SpellBad", {
    undercurl = true,
    sp = c.red,
})

hl(0, "SpellCap", {
    undercurl = true,
    sp = c.yellow,
})

hl(0, "SpellRare", {
    undercurl = true,
    sp = c.magenta,
})

hl(0, "SpellLocal", {
    undercurl = true,
    sp = c.cyan,
})


-- =============================================================================
-- Terminal ANSI colors
-- =============================================================================

vim.g.terminal_color_0  = "#1A1D24"
vim.g.terminal_color_1  = "#E06C75"
vim.g.terminal_color_2  = "#98C379"
vim.g.terminal_color_3  = "#E5C07B"
vim.g.terminal_color_4  = "#7AA2F7"
vim.g.terminal_color_5  = "#C678DD"
vim.g.terminal_color_6  = "#56B6C2"
vim.g.terminal_color_7  = "#C8CCD4"

vim.g.terminal_color_8  = "#5C6370"
vim.g.terminal_color_9  = "#F07178"
vim.g.terminal_color_10 = "#B5E890"
vim.g.terminal_color_11 = "#FFD580"
vim.g.terminal_color_12 = "#89B4FA"
vim.g.terminal_color_13 = "#D2A6FF"
vim.g.terminal_color_14 = "#7DCFFF"
vim.g.terminal_color_15 = "#E6E9EF"