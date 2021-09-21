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

" ================================================
" PACKAGES =======================================
" ================================================

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
Plug 'ntpeters/vim-better-whitespace'
Plug 'tpope/vim-commentary'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-unimpaired'
Plug 'kana/vim-arpeggio'
Plug 'rizzatti/dash.vim'
Plug 'w0rp/ale'
Plug 'skywind3000/asyncrun.vim'

" Status Bars
" -----------------------------------------------

" https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" https://github.com/hoob3rt/lualine.nvim
" Plug 'hoob3rt/lualine.nvim'

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
Plug 'rizzatti/dash.vim'
Plug 'cappyzawa/starlark.vim'

" ------------------------------------------------
Plug 'keith/swift.vim'

" Searching/Replacing
" ------------------------------------------------
Plug 'tpope/vim-abolish'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'ctrlpvim/ctrlp.vim'

" tmux
" ------------------------------------------------
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'christoomey/vim-tmux-navigator'

" JavaScript/JSX/JSON
" ------------------------------------------------
Plug 'elzr/vim-json'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'

" Other
" ------------------------------------------------
Plug 'samoshkin/vim-mergetool'
Plug 'ryanoasis/vim-devicons'
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': ':UpdateRemotePlugins'}
Plug 'zenbro/mirror.vim'

" FROM: https://github.com/unisonweb/unisonweb-org/blob/master/src/data/docs/editor-setup.md#vim
Plug 'unisonweb/unison', { 'branch': 'trunk', 'rtp': 'editor-support/vim' }

" https://github.com/bignimbus/you-are-here.vim
Plug 'bignimbus/you-are-here.vim'

call plug#end()

