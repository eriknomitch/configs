" ================================================
" VIMRC ==========================================
" ================================================

" ------------------------------------------------
" CONFIGURE->GENERAL -----------------------------
" ------------------------------------------------
"  NOTE: Also see CONFIG->COC configuration since some are general
syntax enable

" Automatically write buffers when required
" Spellcheck
autocmd BufRead,BufNewFile *.md,*.txt setlocal spell
autocmd BufRead .del.txt setlocal nospell

" Instant search
set incsearch

" Smart case search
set ignorecase
set smartcase

set nocompatible

" Filetype
filetype on
filetype plugin on
filetype plugin indent on

" Swap
set noswapfile

" Markdown gets different textwidth
au BufRead,BufNewFile *.md setlocal textwidth=300

" Write/edit all windows
command! W windo w
command! E windo e

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

" paste toggle
map <F1> :set paste<CR>
map <F2> :set nopaste<CR>
imap <F1> <C-O>:set paste<CR>
imap <F2> <nop>

" http://vim.wikia.com/wiki/Toggle_auto-indenting_for_code_paste
nnoremap <F3> :set invpaste paste?<CR>
set pastetoggle=<F3>
set showmode

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

" ------------------------------------------------
" MAPPINGS ---------------------------------------
" ------------------------------------------------

" Navigate 4x faster when holding down Shift
nmap <S-j> 4j
nmap <S-k> 4k
nmap <S-h> 4h
nmap <S-l> 4l


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

" ------------------------------------------------
" FIXES ------------------------------------------
" ------------------------------------------------
" Fix crontab issue
" http://vi.stackexchange.com/questions/137/how-do-i-edit-crontab-files-with-vim-i-get-the-error-temp-file-must-be-edited
augroup cron
  au FileType crontab setlocal bkc=yes
augroup END


" ------------------------------------------------
" COMMANDS ---------------------------------------
" ------------------------------------------------
" Command for writing with sudo
" http://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
cmap w!! w !sudo tee > /dev/null %

" ------------------------------------------------
" TMUX -------------------------------------------
" ------------------------------------------------
" Rename title of tmux tab with current filename
if exists('$TMUX')
  augroup tmux
    autocmd BufEnter * call system("tmux rename-window '" . expand("%:t") . "'")
    autocmd VimLeave * call system("tmux setw automatic-rename")
  augroup END
endif

" ================================================
" PLUG ===========================================
" ================================================
source $HOME/.config/nvim/plugs.vim

" ------------------------------------------------
" CONFIG->COMMENTARY -----------------------------
" ------------------------------------------------
" noremap <leader>c :Commentary<cr>

" ------------------------------------------------
" CONFIG->EASY-ALIGN -----------------------------
" ------------------------------------------------

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

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

" ================================================
" CONFIG->KEY-MAPPINGS ===========================
" ================================================

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

" Whitespace
" ------------------------------------------------
nnoremap <leader>sw :StripWhitespace<CR>

" FZF
" ------------------------------------------------
" let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --smartcase'

" https://github.com/junegunn/fzf.vim#commands
" nnoremap <leader>s :Rg<CR>
" nnoremap <leader>S :Lines<CR>
" nnoremap <leader>sc :Commits<CR>

" ------------------------------------------------
" PLUGIN-CONFIG ----------------------------------
" ------------------------------------------------
let s:config_home = stdpath('config')

" FROM: https://github.com/xu-cheng/dotfiles/blob/master/home/.config/nvim/init.vim#L42

" Load plugins settings
" ------------------------------------------------
for s:f in split(glob(s:config_home . '/pluginrc.d/*.vim'), '\n')
  execute 'source' fnameescape(s:f)
endfor

" ------------------------------------------------
" COLORSCHEME ------------------------------------
" ------------------------------------------------
colors bluegreen

" ------------------------------------------------
" LUA->INIT --------------------------------------
" ------------------------------------------------
lua require("init")
