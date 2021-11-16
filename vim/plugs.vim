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

" Utility
" ------------------------------------------------

" Visualize undo history
" https://github.com/mbbill/undotree
Plug 'mbbill/undotree'

" Whitespace tools
" https://github.com/ntpeters/vim-better-whitespace
Plug 'ntpeters/vim-better-whitespace'

" Comment Line(s)
" https://github.com/tpope/vim-commentary
Plug 'tpope/vim-commentary'

" Comment Line(s)
Plug 'scrooloose/nerdcommenter'

" Hotkeys for surrounding strings, etc with anything
" https://github.com/tpope/vim-surround
Plug 'tpope/vim-surround'

" https://github.com/tpope/vim-unimpaired
Plug 'tpope/vim-unimpaired'

" Interface
" ------------------------------------------------

" Extended fuzzy finder UI
" https://github.com/nvim-telescope/telescope.nvim
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Adds font icons to many plugins
" https://github.com/ryanoasis/vim-devicons
Plug 'ryanoasis/vim-devicons'

" Status Bars
" -----------------------------------------------

" https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" https://github.com/hoob3rt/lualine.nvim
" Plug 'hoob3rt/lualine.nvim'

" Vim Interaction
" ------------------------------------------------
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
Plug 'ekalinin/Dockerfile.vim'
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

" https://github.com/kana/vim-arpeggio
" Mappings for simultaneously pressed keys
" Plug 'kana/vim-arpeggio'

Plug 'samoshkin/vim-mergetool'
Plug 'rizzatti/dash.vim'
Plug 'skywind3000/asyncrun.vim'


" Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': ':UpdateRemotePlugins'}

" Remote file editing
" https://github.com/zenbro/mirror.vim
" Plug 'zenbro/mirror.vim'

" FROM: https://github.com/unisonweb/unisonweb-org/blob/master/src/data/docs/editor-setup.md#vim
" Plug 'unisonweb/unison', { 'branch': 'trunk', 'rtp': 'editor-support/vim' }

" https://github.com/bignimbus/you-are-here.vim
" Plug 'bignimbus/you-are-here.vim'

" nnoremap <silent> <leader>here :call you_are_here#Toggle()<CR>

call plug#end()

