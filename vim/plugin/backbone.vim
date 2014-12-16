" backbone.vim - backbone
" Maintainer:   Erik Nomitch <http://eriknomitch.com/>
" Version:      0.0

" ------------------------------------------------
" BACKBONE ---------------------------------------
" ------------------------------------------------
function BackboneTemplate()
  let view_path=expand("%")

  let template_path=substitute(view_path, "/views/", "/templates/", "")
  let template_path=substitute(template_path, "_view.js.coffee", ".jst.eco", "")

  :exec "b ".template_path

endfunction

function BackboneView()
  let template_path=expand("%")

  let view_path=substitute(template_path, "/templates/", "/views/", "")
  let view_path=substitute(view_path, ".jst.eco", "_view.js.coffee", "")

  :exec "b ".view_path

endfunction

" ------------------------------------------------
" MAPPING ----------------------------------------
" ------------------------------------------------
noremap <Leader>bt :call BackboneTemplate()<CR>
noremap <Leader>bv :call BackboneView()<CR>
