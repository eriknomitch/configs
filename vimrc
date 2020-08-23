" ================================================
" VIMRC ==========================================
" ================================================

" ------------------------------------------------
" CONFIGURE->GENERAL -----------------------------
" ------------------------------------------------
"  NOTE: Also see CONFIG->COC configuration since some are general
syntax enable
colors bluegreen

" Automatically write buffers when required
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

" Swap
set noswapfile

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
set laststatus=2

" Indentation
set autoindent
set smartindent

" Tabbing
set smarttab

" For regular expressions turn magic on
set magic

" Maximum amount of memory in Kbyte used for pattern matching
set maxmempattern=1000

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

" Navigate 4x faster when holding down Ctrl
" nmap <C-j> 4j
" nmap <C-k> 4k
" nmap <C-h> 4h
" nmap <C-l> 4l

" ------------------------------------------------
" HOTKEYS ----------------------------------------
" ------------------------------------------------

" Next/Previous Buffers
noremap <C-S-Right> :next<CR>
noremap <C-S-Left> :prev<CR>

" Page up and page down
noremap <Space> <PageDown>
noremap - <PageUp>

" Virtual lines
nmap j gj
nmap k gk
noremap <Up> gk
noremap <Down> gj

" Remap folding hotkeys
nnoremap zO zR
nnoremap zC zM

" Allow quit via single keypress (Q)
" FROM: https://unix.stackexchange.com/a/93239
map Q :qa<CR>

" Yank and drop across multiple vim instances

" FIX: For macOS...
" https://stackoverflow.com/a/38969251/1764073
set clipboard+=unnamed

" FIX: For Linux...
" https://stackoverflow.com/a/10979533/1764073
" set clipboard+=unnamedplus

" Make backspace key work
set backspace=2

" Disable mouse for selecting text without a hotkey
set mouse=
set ruler
set hlsearch

" Wildmenu for better :b tabbing
set wildmenu
set wildchar=<Tab>

" omnicomplete
autocmd FileType lisp set omnifunc=lispcomplete#Complete

" Various ERB syntax highlighting fixes
au BufReadPost *.js.coffee.erb set filetype=coffee syntax=coffee
au BufReadPost *.jst.ejs set filetype=html syntax=html

" Arduino syntax highlighting
au BufNewFile,BufRead *.pde setf arduino

" Less syntax highlighting
au BufNewFile,BufRead *.less set filetype=less

" JSON highlighting
au! BufRead,BufNewFile *.json set filetype=json

" Typescript
autocmd BufNewFile,BufRead *.tsx set filetype=typescript.tsx

" JavaScript
au! BufNewFile,BufRead *.js set filetype=javascript

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

" http://grantlucas.com/posts/2012/09/using-vim-arduino-development
au BufRead,BufNewFile *.pde set filetype=arduino
au BufRead,BufNewFile *.ino set filetype=arduino

" flake8
au BufRead,BufNewFile .flake8 set filetype=yaml

" Command for writing with sudo
" http://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
cmap w!! w !sudo tee > /dev/null %

" Fix crontab issue
" http://vi.stackexchange.com/questions/137/how-do-i-edit-crontab-files-with-vim-i-get-the-error-temp-file-must-be-edited
augroup cron
  au FileType crontab setlocal bkc=yes
augroup END

" Rename title of tmux tab with current filename
if exists('$TMUX')
  augroup tmux
    autocmd BufEnter * call system("tmux rename-window '" . expand("%:t") . "'")
    autocmd VimLeave * call system("tmux setw automatic-rename")
  augroup END
endif

" ------------------------------------------------
" PLUG -------------------------------------------
" ------------------------------------------------
call plug#begin()

" deoplete
" ================================================

" Initialize
" ------------------------------------------------
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif


let g:deoplete#enable_at_startup = 0

" Packages
" ================================================
" For jedi (python) https://github.com/davidhalter/jedi
" Plug 'zchee/deoplete-jedi'

" Autocompletion/Snippets
" ------------------------------------------------
Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'prettier/vim-prettier', {
  \ 'for': [
    \ 'javascript',
    \ 'typescript',
    \ 'css',
    \ 'less',
    \ 'scss',
    \ 'json',
    \ 'graphql',
    \ 'markdown',
    \ 'vue',
    \ 'lua',
    \ 'php',
    \ 'python',
    \ 'ruby',
    \ 'html',
    \ 'swift' ] }

" ------------------------------------------------
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'mbbill/undotree'
Plug 'ekalinin/Dockerfile.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ntpeters/vim-better-whitespace'
Plug 'tpope/vim-commentary'
Plug 'scrooloose/nerdcommenter'
Plug 'mhinz/vim-signify' " (git gutter)
Plug 'tpope/vim-unimpaired'
Plug 'Shougo/unite.vim' " vimfiler depends on this
Plug 'Shougo/vimfiler.vim'
Plug 'kana/vim-arpeggio'
Plug 'rizzatti/dash.vim'
Plug 'w0rp/ale'
Plug 'skywind3000/asyncrun.vim'

" Vim Interaction
" ------------------------------------------------
Plug 'terryma/vim-multiple-cursors'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-repeat' " Dependency of vim-easyclip
Plug 'svermeulen/vim-easyclip'

" Formatting
" ------------------------------------------------
Plug 'junegunn/vim-easy-align'
Plug 'nathanaelkane/vim-indent-guides'

" Plug 'sheerun/vim-polyglot'
Plug 'jreybert/vimagit'
Plug 'suan/vim-instant-markdown'
Plug 'epeli/slimux'
Plug 'goerz/ipynb_notedown.vim'
Plug 'rizzatti/dash.vim'

" Searching
" ------------------------------------------------
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'brooth/far.vim'

" tmux
" ------------------------------------------------
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'christoomey/vim-tmux-navigator'

" JavaScript/JSX/JSON
" ------------------------------------------------
Plug 'elzr/vim-json'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
" Plug 'mxw/vim-jsx'
Plug 'maxmellon/vim-jsx-pretty'

" Other
" ------------------------------------------------
Plug 'samoshkin/vim-mergetool'
Plug 'ryanoasis/vim-devicons'
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': ':UpdateRemotePlugins'}

" https://github.com/bignimbus/you-are-here.vim
Plug 'bignimbus/you-are-here.vim'

call plug#end()

" Add a map of your choice.  I prefer to  use
" <leader>here.  My leader key is set to the
" backslash (\), so by typing \here in normal
" mode, I activate you-are-here.vim. Pressing
" <ESC> will close the popups.

nnoremap <silent> <leader>here :call you_are_here#YouAreHere()<CR>

" top, right, bottom, left border in popups
let g:youarehere_border = [1, 1, 1, 1]

" top, right, bottom, left padding in popups
let g:youarehere_padding = [1, 1, 1, 1]

" g:content is passed to expand to render the filename.
" see :help expand for more options
let g:content = "%"

" Customize the look of you-are-here.vim by using
" the following highlight groups.

" inactive splits:
"
" YouAreHereText
" YouAreHereBorder
" YouAreHereScrollbar
" YouAreHereThumb

" active split:
"
" YouAreHereActiveText
" YouAreHereActiveBorder
" YouAreHereActiveScrollbar
" YouAreHereActiveThumb

"
" ------------------------------------------------
set nocompatible
filetype plugin indent on

let g:mergetool_layout = 'mr'
let g:mergetool_prefer_revision = 'local'

" ------------------------------------------------
" PATHOGEN->INIT ---------------------------------
" ------------------------------------------------
call pathogen#infect()
call pathogen#helptags()

" ------------------------------------------------
" CONFIG->NEOSNIP --------------------------------
" ------------------------------------------------
" " Plugin key-mappings.
" " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
" imap <C-k>     <Plug>(neosnippet_expand_or_jump)
" smap <C-k>     <Plug>(neosnippet_expand_or_jump)
" xmap <C-k>     <Plug>(neosnippet_expand_target)
"
" " SuperTab like snippets behavior.
" " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
" imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
"
" smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
"       \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
"
" " For conceal markers.
" if has('conceal')
"   set conceallevel=2 concealcursor=niv
" endif
"
" " https://github.com/Shougo/neosnippet.vim#configuration
" let g:neosnippet#enable_snipmate_compatibility = 1
" let g:neosnippet#snippets_directory = expand("~/.vim/plugged/vim-snippets/snippets")

" ------------------------------------------------
" CONFIG->CTRLP ----------------------------------
" ------------------------------------------------
let g:ctrlp_map = '<C-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:30,results:30'
let g:ctrlp_extensions = ['buffertag', 'tag', 'line', 'dir']

" ------------------------------------------------
" CONFIG->AIRLINE --------------------------------
" ------------------------------------------------
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
" SEE: https://github.com/vim-airline/vim-airline/wiki/Screenshots
let g:airline_theme='dark'

let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#tmuxline#enabled = 1
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#ctrlp#enabled = 1
let g:airline#extensions#fzf#enabled = 1
let g:airline#extensions#fugitivep#enabled = 1

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

" " Completion with tab
" " FROM: https://github.com/Shougo/deoplete.nvim/issues/816#issuecomment-409119635
" function! s:check_back_space() abort
"   let col = col('.') - 1
"   return !col || getline('.')[col - 1]  =~ '\s'
" endfunction
"
" inoremap <silent><expr> <TAB>
"       \ pumvisible() ? "\<C-n>" :
"       \ <SID>check_back_space() ? "\<TAB>" :
"       \ deoplete#manual_complete()

" ------------------------------------------------
" CONFIG->VIMFILER -------------------------------
" ------------------------------------------------
let g:vimfiler_as_default_explorer = 1

nnoremap <leader>f :VimFilerExplorer<cr>

" ------------------------------------------------
" CONFIG->FZF ------------------------------------
" ------------------------------------------------
set runtimepath+=/usr/local/opt/fzf

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

" ------------------------------------------------
" FZF->BUFFERS ------------------------------------
" ------------------------------------------------

" https://github.com/junegunn/fzf/wiki/Examples-(vim)#search-lines-in-all-open-vim-buffers
function! s:line_handler(l)
  let keys = split(a:l, ':\t')
  exec 'buf' keys[0]
  exec keys[1]
  normal! ^zz
endfunction

function! s:buffer_lines()
  let res = []
  for b in filter(range(1, bufnr('$')), 'buflisted(v:val)')
    call extend(res, map(getbufline(b,0,"$"), 'b . ":\t" . (v:key + 1) . ":\t" . v:val '))
  endfor
  return res
endfunction

command! FZFLines call fzf#run({
\  'source':  <sid>buffer_lines(),
\   'sink':    function('<sid>line_handler'),
\   'options': '--extended --nth=3..',
\   'down':    '60%'
\})

" ------------------------------------------------
" CONFIG->VIM-MULTIPLE-CURSORS -------------------
" ------------------------------------------------

" See: https://github.com/terryma/vim-multiple-cursors#mapping
let g:multi_cursor_use_default_mapping=0

" Default mapping
" let g:multi_cursor_next_key='<C-m>'
" let g:multi_cursor_prev_key='<C-k>'
" let g:multi_cursor_skip_key='<C-x>'
" let g:multi_cursor_quit_key='<Esc>'


" Default highlighting (see help :highlight and help :highlight-link)
" See: https://github.com/terryma/vim-multiple-cursors#highlight
highlight multiple_cursors_cursor term=reverse cterm=reverse gui=reverse
highlight link multiple_cursors_visual Visual

" ------------------------------------------------
" CONFIG->ALE ------------------------------------
" ------------------------------------------------
let g:ale_javascript_prettier_use_local_config = 1
let g:ale_javascript_eslint_use_local_config = 1

let g:ale_typescript_tslint_use_global = 0
let g:ale_typescript_tslint_use_local = 1
let g:ale_typescript_tslint_config_path="tslint.json"
let g:ale_typescript_tslint_executable = expand(".asdf/shims/tslint")

let g:ale_enabled = 0

" Only lint on file open and write - not text change
" let g:ale_lint_on_text_changed = 'normal'
" let g:ale_lint_on_enter = 1
" let g:ale_lint_on_save = 1

" Fix on save
let g:ale_fix_on_save = 0

" https://github.com/w0rp/ale#5iii-how-can-i-change-the-signs-ale-uses
" let g:airline#extensions#ale#enabled = 1

" This is for stylelint (CSS in .jsx files)
" let g:ale_linter_aliases = {'jsx': 'css'}
" let g:ale_linter_aliases = {'jsx': 'js'}

" Linters
let g:ale_linters = {
      \  'javascript.jsx': ['prettier', 'eslint'],
      \  'json':  ['jq'],
      \  'jsx': ['prettier', 'eslint'],
      \  'js': ['prettier', 'eslint'],
      \  'yaml': ['yamllint'],
      \  'ruby': ['rubocop'],
      \  'vim': ['vint'],
      \  'python': ['flake8'],
      \  'py': ['flake8']
      \}

" Fixers
" ------------------------------------------------
let g:ale_fixers = {
      \   '*': ['remove_trailing_lines', 'trim_whitespace'],
      \  'javascript.jsx': ['prettier', 'eslint'],
      \  'javascript': ['prettier', 'eslint'],
      \  'json':  ['jq'],
      \  'jsx': ['prettier', 'eslint'],
      \  'js': ['prettier', 'eslint'],
      \  'yaml': ['prettier'],
      \  'typescript': ['prettier', 'tslint'],
      \  'ts': ['prettier', 'tslint'],
      \  'ruby': ['rubocop'],
      \  'c': ['clang-format'],
      \  'python': ['black'],
      \  'py': ['black']
      \}

function! OnALELintPre()
  echo 'Linting...'
endfunction

function! OnALELintPost()
  echo 'Linting: Complete'
endfunction

augroup ALEWrap
  autocmd!
  autocmd User ALELintPre  call OnALELintPre()
  autocmd User ALELintPost call OnALELintPost()
augroup END


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
" CONFIG->NETRW ----------------------------------
" ------------------------------------------------
let g:netrw_liststyle=3

" http://blog.g14n.info/2013/07/my-vim-configuration.html
" When navigating a directory, pressing <v> opens a window at right side (default
" is left side)
let g:netrw_altv = 1

" ------------------------------------------------
" CONFIG->FAR ------------------------------------
" ------------------------------------------------
let g:far#source = 'agnvim'

" ------------------------------------------------
" CONFIG->VIMAGIT---------------------------------
" ------------------------------------------------
augroup vimagit
  autocmd User VimagitBufferInit call system(g:magit_git_cmd . " add -A " . magit#git#top_dir())
augroup END

" ------------------------------------------------
" CONFIG->VIM-JSX-PRETTY -------------------------
" ------------------------------------------------
let g:vim_jsx_pretty_colorful_config = 1

" ------------------------------------------------
" CONFIG->KEY-MAPPINGS ---------------------------
" ------------------------------------------------

" General
" ------------------------------------------------
nnoremap <leader>q :qall<CR>
nnoremap <leader>h :noh<CR>
nnoremap <leader>w :wqall<CR>

" Shift+tab inserts a literal tab
" https://stackoverflow.com/questions/4781070/how-to-insert-tab-character-when-expandtab-option-is-on-in-vim
inoremap <S-Tab> <C-V><Tab>

" vimrc
" ------------------------------------------------
nnoremap <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" ALE
" ------------------------------------------------
nnoremap <leader>at :ALEToggle<CR>
nnoremap <leader>ae :ALEEnable<CR>
nnoremap <leader>ad :ALEDisable<CR>
nnoremap <leader>F :ALEFix<CR>
nnoremap <leader>f :ALEFix<CR>

" Whitespace
" ------------------------------------------------
nnoremap <leader>sw :StripWhitespace<CR>

" FZF
" ------------------------------------------------
let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --smartcase'


" https://github.com/junegunn/fzf.vim#commands
nnoremap <leader>s :Rg<CR>
nnoremap <leader>S :Lines<CR>
nnoremap <leader>sc :Commits<CR>

" vimagit
" ------------------------------------------------
nnoremap <leader>g :Magit<CR>
