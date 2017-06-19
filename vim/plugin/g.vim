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

  call system("$HOME/.repositories/g/bin/git-is-clean-work-tree")

  if v:shell_error == 0
    echom "Git work tree is clean"
    return 0
  endif

  call inputsave()
  let a:commit_message = input('Commit Message: ')
  call inputrestore()

  redraw

  echo system("git commit --all --message '" . substitute(a:commit_message, "'", "'\\\\''", 'g') . "' && git push")

  if v:shell_error == 0
    echom "Committed."
  else
    echom "Error."
  endif

endfunction

" ------------------------------------------------
" MAPPINGS ---------------------------------------
" ------------------------------------------------
noremap <silent> .g :call G_Commit_And_Push()<CR>

