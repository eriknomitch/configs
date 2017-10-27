" ================================================
" VIM->VIMRC =====================================
" ================================================
set nocompatible
syntax enable
colors bluegreen

set autoread

" Automatically write buffers when required
set autowriteall

" Spellcheck
autocmd BufRead,BufNewFile *.md,*.txt setlocal spell

" Instant search
set incsearch

" Smart case search
set ignorecase
set smartcase

" Filetype
filetype on
filetype plugin indent on

" ------------------------------------------------
" PLUG -------------------------------------------
" ------------------------------------------------
call plug#begin()
Plug 'junegunn/vim-easy-align'
Plug 'pangloss/vim-javascript'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-rails'
Plug 'mbbill/undotree'
Plug 'ekalinin/Dockerfile.vim'
Plug 'elzr/vim-json'
Plug 'vim-airline/vim-airline', { 'commit': '470e9870f13830580d1938a2dae1be5b6e43d92a' }
Plug 'vim-airline/vim-airline-themes'
Plug 'ntpeters/vim-better-whitespace'
Plug 'tpope/vim-commentary'
Plug 'scrooloose/nerdcommenter'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'mhinz/vim-signify' " (git gutter)
Plug 'tpope/vim-unimpaired'
Plug 'ervandew/supertab'
Plug 'Shougo/unite.vim' " vimfiler depends on this
Plug 'Shougo/vimfiler.vim'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'pangloss/vim-javascript'
Plug 'kana/vim-arpeggio'
Plug 'hylang/vim-hy'
Plug 'rizzatti/dash.vim'
Plug 'Shougo/denite.nvim'
Plug 'rhysd/vim-crystal'
Plug 'SirVer/ultisnips'
Plug 'epilande/vim-es2015-snippets'
Plug 'epilande/vim-react-snippets'
Plug 'w0rp/ale'
Plug 'VundleVim/Vundle.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'christoomey/vim-tmux-navigator'
Plug 'terryma/vim-multiple-cursors'
Plug 'jremmen/vim-ripgrep'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'sheerun/vim-polyglot'
call plug#end()

" ------------------------------------------------
" PATHOGEN->INIT ---------------------------------
" ------------------------------------------------
call pathogen#infect()
call pathogen#helptags()

" ------------------------------------------------
" VUNDLE->INIT -----------------------------------
" ------------------------------------------------
" " set the runtime path to include Vundle and initialize
" set rtp+=~/.vim/bundle/Vundle.vim
" call vundle#begin()

" " let Vundle manage Vundle, required
" Plugin 'VundleVim/Vundle.vim'

" " ------------------------------------------------
" " VUNDLE->PLUGINS --------------------------------
" " ------------------------------------------------
" Plugin 'skywind3000/asyncrun.vim'

" " JSX
" Plugin 'pangloss/vim-javascript'
" Plugin 'mxw/vim-jsx'

" " Vim Tmux Navigator
" Plugin 'christoomey/vim-tmux-navigator'

" ------------------------------------------------
" CONFIGURE->GENERAL -----------------------------
" ------------------------------------------------

" Markdown gets different textwidth
au BufRead,BufNewFile *.md setlocal textwidth=300

" commenting
command! -range -bar -nargs=0 LC <line1>,<line2>s/^/;; /
command! -range -bar -nargs=0 LUC <line1>,<line2>s/^;; //

" lower case
command! -range -bar -nargs=0 LOWER <line1>,<line2>s/[A-Z]/\L&/g

" upper case
command! -range -bar -nargs=0 UPPER <line1>,<line2>s/[a-z]/\U&/g

" Write/edit all windows
command! W windo w
command! E windo e

" autosource ~/.vimrc after writing
" http://vim.wikia.com/wiki/Change_vimrc_with_auto_reload
autocmd! bufwritepost .vimrc source %

" folding
set foldmethod=marker

" Tab over settings (2 spaces)
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

" http://vim.wikia.com/wiki/Toggle_auto-indenting_for_code_paste
nnoremap <F3> :set invpaste paste?<CR>
set pastetoggle=<F3>
set showmode

" ------------------------------------------------
" HOTKEYS ----------------------------------------
" ------------------------------------------------

" No Highlight
nnoremap <leader>h :noh<cr>
nnoremap <leader>w :wqall<cr>

" Next/Previous Buffers
noremap <C-S-Right> :next<CR>
noremap <C-S-Left> :prev<CR>

" page up and page down
noremap <Space> <PageDown>
noremap - <PageUp>

" virtual lines
nmap j gj
nmap k gk
noremap <Up> gk
noremap <Down> gj

" yank and drop across multiple vim instances
" set clipboard+=unnamedplus

" make backspace key work
set bs=2

" Disable mouse for selecting text without a hotkey
set mouse=
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

" Prelang syntax highlighting
"au BufNewFile,BufRead *.rb set filetype=prelang

" Arduino syntax highlighting
au BufNewFile,BufRead *.pde setf arduino

" Less syntax highlighting
au BufNewFile,BufRead *.less set filetype=less

" JSON highlighting
au! BufRead,BufNewFile *.json set filetype=json

let g:vim_markdown_folding_disabled=1

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

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-s>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" http://grantlucas.com/posts/2012/09/using-vim-arduino-development
au BufRead,BufNewFile *.pde set filetype=arduino
au BufRead,BufNewFile *.ino set filetype=arduino

" Command for writing with sudo
" http://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
cmap w!! w !sudo tee > /dev/null %

" fzf
set rtp+=/usr/local/opt/fzf

" Fix crontab issue
" http://vi.stackexchange.com/questions/137/how-do-i-edit-crontab-files-with-vim-i-get-the-error-temp-file-must-be-edited
au FileType crontab setlocal bkc=yes

" ------------------------------------------------
" CONFIG->SYNTASTIC ------------------------------
" ------------------------------------------------

"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_loc_list_height = 3
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 1

"let g:syntastic_ruby_exec = '~/.rbenv/shims/ruby'

"let g:syntastic_quiet_messages = {
      "\ "regex": ['assigned but unused variable', 'file not found', 'interpreted as argument prefix'] }

" ------------------------------------------------
" CONFIG->CTRLP ----------------------------------
" ------------------------------------------------
let g:ctrlp_map = '<c-p>'
" let g:ctrlp_cmd = 'CtrlPBuffer'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:30,results:30'
let g:ctrlp_extensions = ['buffertag', 'tag', 'line', 'dir']


" ------------------------------------------------
" CONFIG->AIRLINE --------------------------------
" ------------------------------------------------
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
let g:airline_theme='dark'
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#tmuxline#enabled = 1

" ------------------------------------------------
" CONFIG->COMMENTARY -----------------------------
" ------------------------------------------------
noremap <leader>c :Commentary<cr>

" ------------------------------------------------
" CONFIG->SIGNIFY --------------------------------
" ------------------------------------------------
let g:signify_realtime = 1
let g:signify_vcs_list = [ 'git' ]

" ------------------------------------------------
" CONFIG->GOYO -----------------------------------
" ------------------------------------------------
function! s:goyo_enter()
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter call <SID>goyo_enter()
autocmd! User GoyoLeave call <SID>goyo_leave()

" ------------------------------------------------
" CONFIG->EASY-ALIGN -----------------------------
" ------------------------------------------------

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" ------------------------------------------------
" CONFIG->BETTER-WHITESPACE ----------------------
" ------------------------------------------------
" let g:better_whitespace_enabled = 0

" autocmd BufEnter * EnableStripWhitespaceOnSave

" ------------------------------------------------
" CONFIG->DEOPLETE -------------------------------
" ------------------------------------------------
"let g:deoplete#enable_at_startup = 1

" ------------------------------------------------
" CONFIG->VIMFILER -------------------------------
" ------------------------------------------------
let g:vimfiler_as_default_explorer = 1

nnoremap <leader>f :VimFilerExplorer<cr>

" ------------------------------------------------
" CONFIG->FZF ------------------------------------
" ------------------------------------------------
let g:fzf_colors =
      \ { 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'hl':      ['fg', 'Comment'],
      \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
      \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'PreProc'],
      \ 'prompt':  ['fg', 'Conditional'],
      \ 'pointer': ['fg', 'Exception'],
      \ 'marker':  ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'],
      \ 'header':  ['fg', 'Comment'] }

nnoremap <leader>b :Buffers<cr>

" ------------------------------------------------
" CONFIG->VIM-MULTIPLE-CURSORS -------------------
" ------------------------------------------------
" See: https://github.com/terryma/vim-multiple-cursors#mapping
let g:multi_cursor_use_default_mapping=0

" Default mapping
let g:multi_cursor_next_key='<C-m>'
let g:multi_cursor_prev_key='<C-k>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'


" Default highlighting (see help :highlight and help :highlight-link)
" See: https://github.com/terryma/vim-multiple-cursors#highlight
highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse
highlight link multiple_cursors_visual Visual

" ------------------------------------------------
" CONFIG->ALE ------------------------------------
" ------------------------------------------------
let g:ale_linters = {'jsx': ['stylelint', 'eslint']}
let g:ale_linters = {'js': ['stylelint', 'eslint']}
let g:ale_linter_aliases = {'jsx': 'css'}

"let g:ale_fixers = {
"\   'javascript': ['eslint'],
"\}

" https://github.com/w0rp/ale#5iii-how-can-i-change-the-signs-ale-uses
let g:airline#extensions#ale#enabled = 1

" https://github.com/prettier/prettier/tree/master/editors/vim#ale
let g:ale_fixers = {}
let g:ale_fixers['javascript'] = ['prettier', 'eslint']
let g:ale_fixers['ruby'] = ['rubocop']

" ------------------------------------------------
" CONFIG->RG -------------------------------------
" ------------------------------------------------
let g:rg_highlight = 1

" ------------------------------------------------
" CONFIG->VIM-INDENT-GUIDES ----------------------
" ------------------------------------------------
let g:indent_guides_enable_on_vim_startup = 1

let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=234
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=236

" ------------------------------------------------
" CONFIG->YANKSTACK ------------------------------
" ------------------------------------------------
nmap <leader>p <Plug>yankstack_substitute_older_paste
nmap <leader>P <Plug>yankstack_substitute_newer_paste
