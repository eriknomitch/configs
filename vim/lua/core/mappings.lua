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
