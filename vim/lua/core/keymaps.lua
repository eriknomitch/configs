-- ===============================================
-- MAPPINGS ======================================
-- ===============================================
local mapx = require("mapx")

-- vim
-- nnoremap("<Leader>sv", ":source $MYVIMRC | echon '\"'$MYVIMRC'\" sourced'<CR>")
-- nnoremap("<Leader>so", ":source % | echon '\"'expand('%')'\" sourced'<CR>")
-- nnoremap("<Leader>M", ":messages<CR>")
mapx.nnoremap("<Leader>M", ":Mason<CR>")
mapx.nnoremap("<Leader>L", ":Lazy<CR>")

-- nnoremap("<Leader>vs", ":vsplit<Cr>", "silent")
-- nnoremap("<Leader>sp", ":split<Cr>", "silent")

-- Plugins
-- FIX: Move?
-- nmap("gc", ":Commentary<Cr>", "silent")
-- mapx.nmap("gc", ":Commentary<CR>", "silent")

-- " Allow quit via single keypress (Q)
-- " FROM: https://unix.stackexchange.com/a/93239
mapx.map("Q", ":qall<CR>", "silent")
mapx.map("W", ":wqall<CR>", "silent")
mapx.map("!", ":wqall!<CR>", "silent")

-- No Highlight
mapx.nnoremap("<Leader>h", ":nohlsearch<CR>", "silent")

-- Format
mapx.nnoremap("<Leader>F", ":lua vim.lsp.buf.format {async = true}<CR>", "silent")


local map = vim.keymap.set

-- General
map("n", "<leader>w", "<cmd>write<CR>", { noremap = true, silent = true, desc = "Write buffer" })
map("n", "<leader>q", "<cmd>quit<CR>", { noremap = true, silent = true, desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { noremap = true, silent = true, desc = "Quit all (force)" })
map("n", "<leader>wq", "<cmd>wq<CR>", { noremap = true, silent = true, desc = "Write and quit" })
map("n", "<leader>Wq", "<cmd>wqall<CR>", { noremap = true, silent = true, desc = "Write and quit all" })

-- Faster navigation with Shift (Consider if this is comfortable)
-- map("n", "<S-j>", "4j", opts)
-- map("n", "<S-k>", "4k", opts)
-- map("n", "<S-h>", "4h", opts)
-- map("n", "<S-l>", "4l", opts)

-- Buffer navigation
map({ "n", "i", "v" }, "<C-S-Right>", "<cmd>bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
map({ "n", "i", "v" }, "<C-S-Left>", "<cmd>bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { noremap = true, silent = true, desc = "Delete buffer" })

-- Window navigation and resizing
map("n", "<C-h>", "<C-w>h", { noremap = true, silent = true, desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { noremap = true, silent = true, desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { noremap = true, silent = true, desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { noremap = true, silent = true, desc = "Window right" })
-- Resize mappings (Consider if <C-S-Arrow> conflicts are resolved)
-- map({"n", "i", "v"}, "<C-S-Left>", "<cmd>vertical resize +5<CR>", { noremap = true, silent = true, desc = "Resize vertical +5" })
-- map({"n", "i", "v"}, "<C-S-Right>", "<cmd>vertical resize -5<CR>", { noremap = true, silent = true, desc = "Resize vertical -5" })
map(
	{ "n", "i", "v" },
	"<C-S-Up>",
	"<cmd>resize +2<CR>",
	{ noremap = true, silent = true, desc = "Resize horizontal +2" }
)
map(
	{ "n", "i", "v" },
	"<C-S-Down>",
	"<cmd>resize -2<CR>",
	{ noremap = true, silent = true, desc = "Resize horizontal -2" }
)

-- Page navigation (using default PageUp/PageDown might be better)
-- map({"n", "v", "o"}, "<Space>", "<PageDown>", { noremap = true })
-- map({"n", "v", "o"}, "-", "<PageUp>", { noremap = true })

-- Virtual lines navigation (gj/gk handle wrapped lines)
map("n", "j", "gj", { noremap = true })
map("n", "k", "gk", { noremap = true })
-- map({"n", "v", "o"}, "<Up>", "gk", { noremap = true }) -- Avoid mapping arrow keys if possible
-- map({"n", "v", "o"}, "<Down>", "gj", { noremap = true })

-- Folding remaps
map("n", "zO", "zR", { noremap = true, desc = "Open folds recursively" })
map("n", "zC", "zM", { noremap = true, desc = "Close folds recursively" })

-- Insert literal tab with Shift+Tab
map("i", "<S-Tab>", "<C-V><Tab>", { noremap = true, desc = "Insert literal tab" })

-- Paste toggle (Consider removing if not frequently used, rely on bracketed paste)
-- map({"n", "i"}, "<F1>", "<cmd>set paste<CR>", { noremap = true, silent = true, desc = "Set paste mode" })
-- map("n", "<F2>", "<cmd>set nopaste<CR>", { noremap = true, silent = true, desc = "Unset paste mode" })
-- map("i", "<F2>", "<nop>", { noremap = true, silent = true }) -- Disable F2 in insert mode

-- UndoTree Toggle
map("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle UndoTree" })

-- NvimTree Toggle
map("n", "<C-t>", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle NvimTree" })
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle NvimTree (Explorer)" }) -- Use leader+e as explorer toggle

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { noremap = true, silent = true, desc = "Find Files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true, desc = "Live Grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true, silent = true, desc = "Find Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { noremap = true, silent = true, desc = "Help Tags" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { noremap = true, silent = true, desc = "Find Old Files" })
map("n", "<leader>fc", "<cmd>Telescope commands<cr>", { noremap = true, silent = true, desc = "Commands" })

-- General keymaps
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Make 'x', 'X', and 'dd' delete without copying to clipboard
map("n", "x", '"_x', { desc = "Delete character without copying" })
map("n", "X", '"_X', { desc = "Delete character backwards without copying" })
map("n", "dd", '"_dd', { desc = "Delete line without copying" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Navigate to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Navigate to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Navigate to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window" })

-- Window management
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>sx", ":close<CR>", { desc = "Close current split" })

-- Buffer navigation
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Stay in indent mode
map("v", "<", "<gv", { desc = "Indent left and stay in visual mode" })
map("v", ">", ">gv", { desc = "Indent right and stay in visual mode" })

-- Move text up and down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Next search result and center" })
map("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Quit
map("n", "q", ":qall!<CR>", { noremap = true })

-- Space page down
map("n", "<Space>", "<C-f>", { desc = "Page down" })

-- Hyphen page up
map("n", "-", "<C-b>", { desc = "Page up" })

