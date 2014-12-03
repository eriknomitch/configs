" banners.vim - banner creation
" Maintainer:   Erik Nomitch <http://eriknomitch.com/>
" Version:      0.0

" ------------------------------------------------
" BANNERS ----------------------------------------
" ------------------------------------------------
function Banner()

  " Create a space for the banner to go
  call OpenLines(3, 0)

  let title = toupper(input("title: "))
  let line  = line(".")

  if line == 1
    let line_character = "="
    let general_line = "# ================================================"
  else
    let line_character = "-"
    let general_line = "# ------------------------------------------------"
  endif

  let suffix = ""
  let n = 0

  while n < 47-strlen(title)
    let suffix = suffix.line_character
    let n = n+1
  endwhile

  call setline(line, general_line)
  call setline(line+1, "# ".title." ".suffix)
  call setline(line+2, general_line)
endfunction

function BarCharacter()

  " The top 3 rows should be the heavy columns.
  if line(".") < 4
    return "="
  endif

  return "-"

endfunction

function BarUntilPoint()
  
  let bar = ""
  let contents = getline(".")
 
  " If the line contents does not end in a space, add one.
  if contents !~ ' $'
    let contents = contents." "
  endif
 
  " If the line is not already commented, comment it
  let delimiter = b:NERDCommenterDelims["left"]

  if contents !~ ' *'.delimiter
    let contents = delimiter.contents
  endif

  " Create the bar to insert
  let bar_length = 50 - len(contents)
  
  " Decide on the character.
  let char = BarCharacter()

  let i = 0
  while i < bar_length
    let bar = bar.char
    let i = i+1
  endwhile

  " Set the current line with the bar appended
  call setline(line("."), contents.bar)

endfunction

" Map banner functions
noremap <Leader>t :call Banner()<CR>
imap <C-L> <ESC>:call BarUntilPoint()<CR>$a<CR>

