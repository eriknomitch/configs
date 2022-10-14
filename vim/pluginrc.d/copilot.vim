" ================================================
" COPILOT ========================================
" ================================================
" SEE: :help copilot

" Use <C-J> instead of <Tab>
imap <silent><script><expr> <C-O> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

" FROM: https://github.com/hrsh7th/nvim-cmp/issues/459#issuecomment-984365484
" let g:copilot_assume_mapped = v:true
" let g:copilot_tab_fallback = ""
