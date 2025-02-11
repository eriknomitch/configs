local opt = vim.opt
local g = vim.g

-- Leader key
g.mapleader = "\\"

-- Line numbers
opt.number = false
opt.relativenumber = true

-- Tabs & Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor line
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Consider - as part of word
opt.iskeyword:append("-")

-- Disable swapfile and backup
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- Persistent undo
opt.undofile = true

-- Update time
opt.updatetime = 50

-- Scroll offset
opt.scrolloff = 8

-- Enable mouse
opt.mouse = "a"

-- Enable filetype plugins
vim.cmd("filetype plugin indent on") 