" ================================================
" COPILOT ========================================
" ================================================
" SEE: :help copilot

" Use <C-J> instead of <Tab>
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
