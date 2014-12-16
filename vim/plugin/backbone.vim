" backbone.vim - backbone
" Maintainer:   Erik Nomitch <http://eriknomitch.com/>
" Version:      0.0

" ------------------------------------------------
" BANNER -----------------------------------------
" ------------------------------------------------
function BackboneTemplate()
  let view_path=expand("%")

  let template_path=substitute(view_path, "/views/", "/templates/", "")
  let template_path=substitute(template_path, "_view.js.coffee", ".jst.eco", "")

  :exec "b ".template_path

endfunction

" ------------------------------------------------
" MAPPING ----------------------------------------
" ------------------------------------------------
noremap <Leader>bt :call BackboneTemplate()<CR>
