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

  " Check if work tree is already clean
  " ----------------------------------------------
  call system("$HOME/.repositories/g/bin/git-is-clean-work-tree")

  if v:shell_error == 0
    echom "Git work tree is clean"
    return 0
  endif

  " Get commit message from user
  " ----------------------------------------------
  call inputsave()
  let a:commit_message = input('Commit Message: ')
  call inputrestore()

  redraw

  " Handle blank commit message
  " ----------------------------------------------
  if a:commit_message == ""
    echom ""
    return 0
  endif

  " Perform commit
  " ----------------------------------------------
  "echo system("git commit --all --message '" . substitute(a:commit_message, "'", "'\\\\''", 'g') . "' && git push")
  call dispatch#spawn("git commit --all --message '" . substitute(a:commit_message, "'", "'\\\\''", 'g') . "' && git push")

  " Output result
  " ----------------------------------------------
  if v:shell_error == 0
    echo ""
    echo "Committed."
  else
    echo ""
    echo "Error."
  endif

endfunction

" ------------------------------------------------
" MAPPINGS ---------------------------------------
" ------------------------------------------------
noremap <silent> .g :call G_Commit_And_Push()<CR>

