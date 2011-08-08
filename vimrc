set nocompatible
syntax enable
colors bluegreen

set autoread

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

