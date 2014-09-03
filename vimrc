set nocompatible
syntax enable
colors bluegreen

" let mapleader = ','

set autoread

" pathogen
call pathogen#infect()

" spellcheck
autocmd BufRead,BufNewFile *.md,*.txt setlocal spell

" instant search
set is

syntax on
filetype plugin indent on

" comment wrapping
set wrap
set textwidth=80

" Markdown gets different textwidth
au BufRead,BufNewFile *.md setlocal textwidth=300

" commenting
command! -range -bar -nargs=0 LC <line1>,<line2>s/^/;; /
command! -range -bar -nargs=0 LUC <line1>,<line2>s/^;; //

" lower case
command! -range -bar -nargs=0 LOWER <line1>,<line2>s/[A-Z]/\L&/g

" upper case
command! -range -bar -nargs=0 UPPER <line1>,<line2>s/[a-z]/\U&/g

" autosource ~/.vimrc after writing
" http://vim.wikia.com/wiki/Change_vimrc_with_auto_reload
" autocmd! bufwritepost .vimrc source %

" folding
set foldmethod=marker

" hang fix
set swapsync=
set nofsync

" tab over settings
set softtabstop=2
set expandtab
set shiftwidth=2
set ai
set laststatus=2

" .lisp gets 2 spaces
au BufRead,BufNewFile *.lisp setlocal softtabstop=2 shiftwidth=2 

" paste toggle
map <F1> :set paste<CR>
map <F2> :set nopaste<CR>
imap <F1> <C-O>:set paste<CR>
imap <F2> <nop>
set pastetoggle=<F2>

" ctrl-h : sets highlighted words to normal
noremap <C-H> :nohls<CR>

" ctrl-n/p : next and previous buffers
noremap <C-N> :next<CR>
noremap <C-P> :prev<CR>

" resize the vertical split easlier
noremap <C-Right> :vertical resize -2<CR>
noremap <C-Left> :vertical resize +2<CR>

" page up and page down
noremap <Space> <PageDown>
noremap - <PageUp>

" virtual lines
nmap j gj
nmap k gk
noremap <Up> gk
noremap <Down> gj

" yank and drop across multiple vim instances
set clipboard+=unnamed

" make backspace key work
set bs=2

" use mouse, ruler, hightlight search
set mouse=a
set ruler
set hlsearch

autocmd BufEnter *.php setlocal indentexpr= 

" wildmenu for better :b tabbing
set wildmenu
set wildchar=<Tab>

" omnicomplete
autocmd FileType lisp set omnifunc=lispcomplete#Complete

" Various ERB syntax highlighting fixes
au BufReadPost *.js.coffee.erb set filetype=coffee syntax=coffee
au BufReadPost *.jst.ejs set filetype=html syntax=html

" Meta syntax highlighting
au BufNewFile,BufRead *.lisp set filetype=meta
au BufNewFile,BufRead *.prog set filetype=meta
au BufNewFile,BufRead *.asd  set filetype=meta
au BufNewFile,BufRead *.mls  set filetype=meta

" Prelang syntax highlighting
"au BufNewFile,BufRead *.rb set filetype=prelang

" Arduino syntax highlighting
au BufNewFile,BufRead *.pde setf arduino

" Less syntax highlighting
au BufNewFile,BufRead *.less set filetype=less

" JSON highlighting
au! BufRead,BufNewFile *.json set filetype=json

" Abbreviations
"ab df. (define-function
"ab def. (define-exported-function
"ab dv. (define-variable
"ab dm. (define-macro
"ab de. (define-method
"ab dc. (define-class

" Lisp Mappings
"map dc <INSERT>(define-class foo ()<ENTER> ()<ENTER>  ())<ESC><CR>
"map dm input()

function LispDefineClass()
  let class = "foo"
  let superclasses = "bar baz"
  let slots = split("id title qux", " ")

  let class        = input("class name: ")
  let superclasses = input("superclasses: ")
  let slots        = split(input("slots: "), " ")

  let line         = getline(".")+1

  " dashes
  let dashes = ""

  let n = 0
  while n < (39-strlen(class))
    let dashes = dashes."-"
    let n=n+1
  endwhile

  " banner
  call setline(line, ";; -----------------------------------------------")
  let line=line+1
  call setline(line, ";; CLASS->".toupper(class)." ".dashes)
  let line=line+1
  call setline(line, ";; -----------------------------------------------")
  let line=line+1

  call setline(line, "(define-class ".class." (".superclasses.")")
  let line=line+1

  let n = 0
  while n < len(slots)
  
    " if it's the first, we need an extra (
    if n == 0
      let prefix = "  (("
    else
      let prefix = "   ("
    endif

    " if it's the last, we need an extra )
    if n == (len(slots)-1)
      let suffix = ")"
    else
      let suffix = ""
    endif

    " slot
    call setline(line, prefix.slots[n])
    let line=line+1
    
    " :accessor
    call setline(line, "    :accessor ".class."-".slots[n])
    let line=line+1

    " :initarg
    call setline(line, "    :initarg :".slots[n])
    let line=line+1

    " :initform
    call setline(line, "    :initform nil)".suffix)
    let line=line+1

    let n = n+1
  endwhile
endfunction

let g:vim_markdown_folding_disabled=1

"noremap ldc :call LispDefineClass()<CR>

" Vundle
"set rtp+=~/.vim/bundle/vundle/
"call vundle#rc()

" let Vundle manage Vundle
" required! 
"Bundle 'gmarik/vundle'

" ------------------------------------------------
" UTILITY ----------------------------------------
" ------------------------------------------------
" http://vim.wikia.com/wiki/Insert_multiple_lines
" Open multiple lines (insert empty lines) before or after current line,
" and position cursor in the new space, with at least one blank line
" before and after the cursor.
function! OpenLines(nrlines, dir)
  let nrlines = a:nrlines < 3 ? 3 : a:nrlines
  let start = line('.') + a:dir
  call append(start, repeat([''], nrlines))
  if a:dir < 0
    normal! 2k
  else
    normal! 2j
  endif
endfunction

" Mappings to open multiple lines and enter insert mode.
nnoremap <Leader>o :<C-u>call OpenLines(v:count, 0)<CR>S
nnoremap <Leader>O :<C-u>call OpenLines(v:count, -1)<CR>S

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

" Map banner functions
noremap <Leader>t :call Banner()<CR>

