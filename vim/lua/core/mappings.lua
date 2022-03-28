-- ===============================================
-- MAPPINGS ======================================
-- ===============================================

-- vim
-- nnoremap("<Leader>sv", ":source $MYVIMRC | echon '\"'$MYVIMRC'\" sourced'<CR>")
-- nnoremap("<Leader>so", ":source % | echon '\"'expand('%')'\" sourced'<CR>")
-- nnoremap("<Leader>M", ":messages<CR>")

-- nnoremap("<Leader>vs", ":vsplit<Cr>", "silent")
-- nnoremap("<Leader>sp", ":split<Cr>", "silent")

-- Plugins
-- FIX: Move?
-- nmap("gc", ":Commentary<Cr>", "silent")

-- " Allow quit via single keypress (Q)
-- " FROM: https://unix.stackexchange.com/a/93239
map("Q", ":qall<CR>", "silent")
map("W", ":wqall<CR>", "silent")
map("!", ":wqall!<CR>", "silent")

-- StripWhitespace
nnoremap("<Leader>sw", ":StripWhitespace<CR>", "silent")

-- No Highlight
nnoremap("<Leader>h", ":NoHighlight<CR>", "silent")
