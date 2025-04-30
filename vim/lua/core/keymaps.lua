-- ===============================================
-- KEY MAPPINGS
-- ===============================================
-- Standard Neovim keymap function
local map = vim.keymap.set

-- Helper function for options (optional, but can shorten map calls)
-- local opts = { noremap = true, silent = true }

-- ===============================================
-- General & Session Management
-- ===============================================

-- Write / Quit
map("n", "<leader>w", "<cmd>write<CR>", { noremap = true, silent = true, desc = "Write buffer" })
map("n", "<leader>wq", "<cmd>wq<CR>", { noremap = true, silent = true, desc = "Write and quit" })
map("n", "<leader>Wq", "<cmd>wqall<CR>", { noremap = true, silent = true, desc = "Write and quit all" })
-- NOTE: The following mappings overlap in function:
-- 'Q' (Shift+q) quits all without forcing
map("n", "Q", "<cmd>qall<CR>", { silent = true, desc = "Quit all" }) -- Converted from mapx
-- 'q' quits all, forcing
map("n", "q", "<cmd>qall!<CR>", { noremap = true, desc = "Quit all (force)" }) -- Kept from vim.keymap.set block
-- '<leader>Q' quits all, forcing
map("n", "<leader>Q", "<cmd>qa!<CR>", { noremap = true, silent = true, desc = "Quit all (force)" }) -- Kept from vim.keymap.set block

-- Write/Quit All (additional mappings from mapx)
map("n", "W", "<cmd>wqall<CR>", { silent = true, desc = "Write and quit all (Shift+w)" }) -- Converted from mapx
map("n", "!", "<cmd>wqall!<CR>", { silent = true, desc = "Write and quit all (force, ! key)" }) -- Converted from mapx, unusual key

-- Reload Neovim config (commented out from original)
-- map("n", "<Leader>sv", ":source $MYVIMRC | echon '\"'$MYVIMRC'\" sourced'<CR>", { desc = "Source vimrc" })
-- map("n", "<Leader>so", ":source % | echon '\"'expand('%')'\" sourced'<CR>", { desc = "Source current file" })

-- View messages (commented out from original)
-- map("n", "<Leader>M", ":messages<CR>", { desc = "Show messages" })

-- Clear search highlight
map("n", "<Leader>h", "<cmd>nohlsearch<CR>", { noremap = true, silent = true, desc = "Clear search highlight (h)" }) -- Converted from mapx
map("n", "<leader>nh", "<cmd>nohl<CR>", { noremap = true, silent = true, desc = "Clear search highlights (nh)" }) -- Kept from vim.keymap.set block

-- ===============================================
-- Window Management
-- ===============================================

-- Navigation (Using <C-h/j/k/l>)
map("n", "<C-h>", "<C-w>h", { noremap = true, silent = true, desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { noremap = true, silent = true, desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { noremap = true, silent = true, desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { noremap = true, silent = true, desc = "Window right" })

-- Splitting
-- map("n", "<leader>sv", "<C-w>v", { noremap = true, silent = true, desc = "Split window vertically" })
-- map("n", "<leader>sh", "<C-w>s", { noremap = true, silent = true, desc = "Split window horizontally" })
-- map("n", "<Leader>vs", ":vsplit<CR>", { silent = true, desc = "Split vertical (alt)" }) -- Commented out in original
-- map("n", "<Leader>sp", ":split<CR>", { silent = true, desc = "Split horizontal (alt)" }) -- Commented out in original

-- Closing / Resizing
-- map("n", "<leader>sx", "<cmd>close<CR>", { noremap = true, silent = true, desc = "Close current split" })
-- map("n", "<leader>se", "<C-w>=", { noremap = true, silent = true, desc = "Make splits equal size" })
-- Resize mappings
-- NOTE: <C-S-Left/Right> commented out in original, potentially conflicted with buffer navigation below
-- map({"n", "i", "v"}, "<C-S-Left>", "<cmd>vertical resize +5<CR>", { noremap = true, silent = true, desc = "Resize vertical +5" })
-- map({"n", "i", "v"}, "<C-S-Right>", "<cmd>vertical resize -5<CR>", { noremap = true, silent = true, desc = "Resize vertical -5" })
map( { "n", "i", "v" }, "<C-S-Up>", "<cmd>resize +2<CR>", { noremap = true, silent = true, desc = "Resize horizontal +2" })
map( { "n", "i", "v" }, "<C-S-Down>", "<cmd>resize -2<CR>", { noremap = true, silent = true, desc = "Resize horizontal -2" })

-- ===============================================
-- Buffer Management
-- ===============================================

-- Navigation
-- NOTE: <C-S-Left/Right> might conflict with window resizing if uncommented above
map({ "n", "i", "v" }, "<C-S-Right>", "<cmd>bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
map({ "n", "i", "v" }, "<C-S-Left>", "<cmd>bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
-- map("n", "<leader>bn", "<cmd>bnext<CR>", { noremap = true, silent = true, desc = "Next buffer (leader)" })
-- map("n", "<leader>bp", "<cmd>bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer (leader)" })

-- Deletion
-- map("n", "<leader>bd", "<cmd>bdelete<CR>", { noremap = true, silent = true, desc = "Delete buffer" })

-- ===============================================
-- Navigation & Scrolling
-- ===============================================

-- Faster navigation with Shift (Commented out from original)
-- map("n", "<S-j>", "4j", opts)
-- map("n", "<S-k>", "4k", opts)
-- map("n", "<S-h>", "4h", opts)
-- map("n", "<S-l>", "4l", opts)

-- Page navigation
map("n", "<Space>", "<C-f>", { noremap = true, desc = "Page down" })
map("n", "-", "<C-b>", { noremap = true, desc = "Page up" })
-- map({"n", "v", "o"}, "<Space>", "<PageDown>", { noremap = true }) -- Alternative commented out in original
-- map({"n", "v", "o"}, "-", "<PageUp>", { noremap = true }) -- Alternative commented out in original

-- Virtual lines navigation (for wrapped lines)
map("n", "j", "gj", { noremap = true })
map("n", "k", "gk", { noremap = true })
-- map({"n", "v", "o"}, "<Up>", "gk", { noremap = true }) -- Avoid mapping arrow keys if possible (commented out)
-- map({"n", "v", "o"}, "<Down>", "gj", { noremap = true }) -- Avoid mapping arrow keys if possible (commented out)

-- Keep cursor centered when scrolling/searching
map("n", "<C-d>", "<C-d>zz", { noremap = true, desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { noremap = true, desc = "Scroll up and center" })
map("n", "n", "nzzzv", { noremap = true, desc = "Next search result and center" })
map("n", "N", "Nzzzv", { noremap = true, desc = "Previous search result and center" })

-- ===============================================
-- Editing & Visual Mode
-- ===============================================

-- Exit insert mode
map("i", "jk", "<ESC>", { noremap = true, silent = true, desc = "Exit insert mode" })

-- Insert literal tab
map("i", "<S-Tab>", "<C-V><Tab>", { noremap = true, desc = "Insert literal tab" })

-- Delete without copying to clipboard register ("_ black hole register)
map("n", "x", '"_x', { noremap = true, desc = "Delete character without copying" })
map("n", "X", '"_X', { noremap = true, desc = "Delete character backwards without copying" })
map("v", "x", "d", { noremap = true, silent = true, desc = "Delete selection and save for pasting" })
map("n", "dd", '"_dd', { noremap = true, desc = "Delete line without copying" })
map("n", "D", '"_D', { noremap = true, desc = "Delete to end of line without copying" })
map("n", "<leader>m", "d", { desc = "Delete and Yank to Clipboard (Move)" })

-- Indent and stay in visual mode
map("v", "<", "<gv", { noremap = true, desc = "Indent left and stay in visual mode" })
map("v", ">", ">gv", { noremap = true, desc = "Indent right and stay in visual mode" })

-- Move selected text up/down
map("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move text down" })
map("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move text up" })

-- Folding remaps (use zR/zM which act recursively)
map("n", "zO", "zR", { noremap = true, desc = "Open folds recursively" })
map("n", "zC", "zM", { noremap = true, desc = "Close folds recursively" })

-- Paste toggle (Commented out from original)
-- map({"n", "i"}, "<F1>", "<cmd>set paste<CR>", { noremap = true, silent = true, desc = "Set paste mode" })
-- map("n", "<F2>", "<cmd>set nopaste<CR>", { noremap = true, silent = true, desc = "Unset paste mode" })
-- map("i", "<F2>", "<nop>", { noremap = true, silent = true }) -- Disable F2 in insert mode

-- ===============================================
-- Plugin Specific Mappings
-- ===============================================

-- Mason
map("n", "<Leader>M", "<cmd>Mason<CR>", { noremap = true, silent = true, desc = "Open Mason" }) -- Converted from mapx

-- Lazy
map("n", "<Leader>L", "<cmd>Lazy<CR>", { noremap = true, silent = true, desc = "Open Lazy" }) -- Converted from mapx

-- LSP Formatting
-- Define a Lua function that formats and then notifies
local function format_and_notify()
  vim.lsp.buf.format({
    async = true,
    callback = function()
      -- This function is executed after formatting is done
      vim.notify("Formatted File", vim.log.levels.INFO)
    end
  })
end

-- Map the key to call the new function
vim.keymap.set("n", "<Leader>-", format_and_notify, {
  silent = true,
  desc = "Format code and notify"
})

-- UndoTree
map("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle UndoTree" })

-- NvimTree
map("n", "<C-t>", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle NvimTree" })
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle NvimTree (Explorer)" })

-- Telescope
map("n", "<Leader>f", "<cmd>Telescope find_files<cr>", { noremap = true, silent = true, desc = "Find Files" })
-- map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true, desc = "Live Grep" })
-- map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true, silent = true, desc = "Find Buffers" })
-- map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { noremap = true, silent = true, desc = "Help Tags" })
-- map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { noremap = true, silent = true, desc = "Find Old Files" })
-- map("n", "<leader>fc", "<cmd>Telescope commands<cr>", { noremap = true, silent = true, desc = "Commands" })

-- Commentary (Commented out from original)
-- map("n", "gc", ":Commentary<CR>", { silent = true, desc = "Toggle comment" }) -- Converted from mapx

-- Remove mapx require if no longer needed
-- local mapx = require("mapx") -- Remove this line if mapx is fully replaced

-- print("Key mappings loaded!") -- Optional confirmation message
-- vim.notify("Key mappings loaded.", vim.log.levels.INFO, { title = "Neovim", render = "minimal" })
