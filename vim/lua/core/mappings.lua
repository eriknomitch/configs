-- ===============================================
-- MAPPINGS ======================================
-- ===============================================
nnoremap("<Leader>F", ":CocCommand prettier.formatFile<CR>")
nnoremap("<Leader>Sv", ":source $MYVIMRC | echon '\"'$MYVIMRC'\" sourced'<CR>")
nnoremap("<Leader>Sf", ":source % | echon '\"'expand('%')'\" sourced'<CR>")
nnoremap("<Leader>M", ":messages<CR>")
