" ================================================
" VIM->PLUGIN->G =================================
" ================================================

" ------------------------------------------------
" UTILITY ----------------------------------------
" ------------------------------------------------
" ------------------------------------------------
" COMMANDS ---------------------------------------
" ------------------------------------------------
function! G_Commit_And_Push()

  "redraw
  "let a:commit_message = input('Commit Message: ')
  "echo ""

  echohl "foo"

  call inputsave()
  let a:commit_message = input('Commit Message: ')
  call inputrestore()

  redraw

  echo system("git commit --all --message '" . substitute(a:commit_message, "'", "'\\\\''", 'g') . "' && git push")

endfunction

" ------------------------------------------------
" MAPPINGS ---------------------------------------
" ------------------------------------------------
noremap <silent> .g :call G_Commit_And_Push()<CR>

