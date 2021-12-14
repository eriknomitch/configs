" ================================================
" CONFIG->AIRLINE ================================
" ================================================
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
" SEE: https://github.com/vim-airline/vim-airline/wiki/Screenshots
let g:airline_theme='dark'

  " an empty list disables all extensions
  let g:airline_extensions = []

let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#tmuxline#enabled = 1
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#fzf#enabled = 0
let g:airline#extensions#fugitivep#enabled = 0

