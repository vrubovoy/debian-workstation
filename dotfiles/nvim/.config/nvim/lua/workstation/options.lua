-- Editor options. Only values that differ from Neovim's defaults are set.

local opt = vim.opt

-- Text
opt.number = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "100"
opt.wrap = false
opt.scrolloff = 5
opt.sidescrolloff = 8
opt.fillchars:append({ eob = " " })

-- Indentation: four spaces unless .editorconfig says otherwise.
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

if vim.fn.executable("rg") == 1 then
    opt.grepprg = "rg --vimgrep --smart-case"
    opt.grepformat = "%f:%l:%c:%m"
end

-- System integration: the X11 clipboard (through xclip) and the mouse.
opt.clipboard = "unnamedplus"
opt.mouse = "a"

-- Files: persistent undo; swap files still guard unsaved work.
opt.undofile = true
opt.writebackup = false

-- Windows and command line
opt.splitright = true
opt.splitbelow = true
opt.wildmode = "longest:full,full"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.confirm = true
opt.shortmess:append("I")

-- Responsiveness
opt.updatetime = 250
opt.timeoutlen = 400

opt.termguicolors = true
