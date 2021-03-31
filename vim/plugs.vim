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


" LSP
" ------------------------------------------------
" FROM: https://www.chrisatmachine.com/Neovim/27-native-lsp/
" Plug 'neovim/nvim-lspconfig'
" Plug 'hrsh7th/nvim-compe'

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
" Plug 'mhinz/vim-signify' " (git gutter)
Plug 'tpope/vim-unimpaired'
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

" defx (File Browser)
" ------------------------------------------------
if has('nvim')
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/defx.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

" Syntax/Formatting
" ------------------------------------------------
Plug 'junegunn/vim-easy-align'
Plug 'nathanaelkane/vim-indent-guides'

Plug 'sheerun/vim-polyglot'
" Plug 'jreybert/vimagit'
Plug 'suan/vim-instant-markdown'
Plug 'epeli/slimux'
Plug 'goerz/ipynb_notedown.vim'
Plug 'rizzatti/dash.vim'
Plug 'cappyzawa/starlark.vim'

" ------------------------------------------------
Plug 'keith/swift.vim'

" Searching
" ------------------------------------------------
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'brooth/far.vim'
Plug 'wsdjeg/FlyGrep.vim'

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
Plug 'zenbro/mirror.vim'
" Plug 'ludovicchabant/vim-gutentags'

" https://github.com/bignimbus/you-are-here.vim
Plug 'bignimbus/you-are-here.vim'

" Plug 'blueyed/vim-diminactive'

" Plug 'kyazdani42/nvim-web-devicons'
" " Plug 'romgrk/lib.kom' -- removed! You can remove it from your vimrc
" Plug 'romgrk/barbar.nvim'

call plug#end()

