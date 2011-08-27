set nocompatible
syntax enable
colors bluegreen

set autoread

" instant search
set is

filetype plugin on

" commenting
command! -range -bar -nargs=0 LC <line1>,<line2>s/^/;; /
command! -range -bar -nargs=0 LUC <line1>,<line2>s/^;; //

" lower case
command! -range -bar -nargs=0 LOWER <line1>,<line2>s/[A-Z]/\L&/g

" upper case
command! -range -bar -nargs=0 UPPER <line1>,<line2>s/[a-z]/\U&/g

" some common strings
command -nargs=0 DASHES normal i;; -----------------------------------------------
command -nargs=0 DASHED normal i;; - - - - - - - - - - - - - - - - - - - - - - - -
command -nargs=0 BANNER normal i;; -----------------------------------------------<Enter>;; -----------------------------------------------<Enter>;; -----------------------------------------------
command -nargs=0 TEMPORARY normal i;; TEMPORARY >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><Enter>;; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

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
set clipboard=unnamed

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

" Meta syntax highlighting
au BufNewFile,BufRead *.lisp set filetype=meta
au BufNewFile,BufRead *.prog set filetype=meta
au BufNewFile,BufRead *.asd  set filetype=meta
au BufNewFile,BufRead *.mls  set filetype=meta

" Arduino syntax highlighting
au BufNewFile,BufRead *.pde setf arduino

" Abbreviations
ab df. (define-function
ab def. (define-exported-function
ab dv. (define-variable
ab dm. (define-macro
ab de. (define-method
ab dc. (define-class

" Lisp Mappings
"map dc <INSERT>(define-class foo ()<ENTER> ()<ENTER>  ())<ESC><CR>
"map dm input()

function Test()
  call put("okay")
endfunction

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
  while n < (47-strlen(class))
    let dashes = dashes."-"
    let n=n+1
  endwhile

  " banner
  call setline(line, ";; -----------------------------------------------")
  let line=line+1
  call setline(line, ";; CLASS->".class." ".dashes)
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

noremap ldc :call LispDefineClass()<CR>



