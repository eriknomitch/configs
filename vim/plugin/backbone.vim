" backbone.vim - backbone
" Maintainer:   Erik Nomitch <http://eriknomitch.com/>
" Version:      0.0

" ------------------------------------------------
" BANNER -----------------------------------------
" ------------------------------------------------
function Btemplate()
  let view_path=expand("%")

  let template_path=substitute(view_path, "/views/", "/templates/", "")
  let template_path=substitute(template_path, "_view.js.coffee", ".jst.eco", "")

  :exec "b ".template_path

endfunction

" ------------------------------------------------
" MAPPING ----------------------------------------
" ------------------------------------------------

" Map banner functions
"noremap <Leader>t :call Banner()<CR>
"imap <C-L> <ESC>:call BarUntilPoint()<CR>$a<CR>
"map <C-L> :call BarUntilPoint()<CR>$a<ESC>

