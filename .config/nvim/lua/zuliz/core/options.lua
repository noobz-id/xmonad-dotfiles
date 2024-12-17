-- file explorer tree style
vim.cmd("let g:netrw_liststyle = 3")

-- consist
local opt = vim.opt

opt.relativenumber = true
opt.number = true

-- tab & indentation
opt.tabstop = 2 -- space for tab
opt.shiftwidth = 2 -- 2 space for indent width
opt.expandtab = true -- expand tab space
opt.autoindent = true -- copy indent from current line

opt.wrap = false -- disable line wrapping

-- search settings
opt.ignorecase = true -- ignore case
opt.smartcase = true -- mix case equal of case-sensitive

opt.cursorline = true

-- term gui color tokyonight
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace for indent, end-of-line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as register

-- split window
opt.splitright = true -- split vertical window to right
opt.splitbelow = true -- split horizontal window to bottom


