-- ===============================================
-- MAPPINGS ======================================
-- ===============================================

-- vim
nnoremap("<Leader>sv", ":source $MYVIMRC | echon '\"'$MYVIMRC'\" sourced'<CR>")
nnoremap("<Leader>so", ":source % | echon '\"'expand('%')'\" sourced'<CR>")
nnoremap("<Leader>M", ":messages<CR>")

nnoremap("<Leader>vs", ":vsplit<Cr>", "silent")
nnoremap("<Leader>sp", ":split<Cr>", "silent")

-- Plugins
-- FIX: Move?
nnoremap("<Leader>c", ":Commentary<Cr>", "silent")
