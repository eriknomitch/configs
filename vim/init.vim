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

" Yank and drop across multiple vim instances
" FIX:

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

" Shift+tab inserts a literal tab
" https://stackoverflow.com/questions/4781070/how-to-insert-tab-character-when-expandtab-option-is-on-in-vim
inoremap <S-Tab> <C-V><Tab>

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
" CONFIG->EASY-ALIGN -----------------------------
" ------------------------------------------------

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

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
" COLORSCHEME ------------------------------------
" ------------------------------------------------
colors bluegreen

" For nvim-cmp
set completeopt=menu,menuone,noselect

" ------------------------------------------------
" WHISPER ----------------------------------------
" ------------------------------------------------
inoremap <C-G>  <C-O>:!whisper.nvim<CR><C-O>:let @a = system("cat /tmp/whisper.nvim \| tail -n 1 \| xargs -0 \| tr -d '\\n' \| sed -e 's/^[[:space:]]*//'")<CR><C-R>a
nnoremap <C-G>       :!whisper.nvim<CR>:let @a = system("cat /tmp/whisper.nvim \| tail -n 1 \| xargs -0 \| tr -d '\\n' \| sed -e 's/^[[:space:]]*//'")<CR>"ap
vnoremap <C-G> c<C-O>:!whisper.nvim<CR><C-O>:let @a = system("cat /tmp/whisper.nvim \| tail -n 1 \| xargs -0 \| tr -d '\\n' \| sed -e 's/^[[:space:]]*//'")<CR><C-R>a

" ================================================
" LUA->INIT ======================================
" ================================================
lua require("init")
