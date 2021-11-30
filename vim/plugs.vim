call plug#begin()

" ================================================
" PLUG->PACKAGES =================================
" ================================================

" LSP
" ------------------------------------------------
" SEE: LSP

" NOTE: Requires LSP server(s)
" https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
"
" TypeScript:
" $ npm install -g typescript typescript-language-server
"
" Python:
" $ npm install -g pyright
Plug 'neovim/nvim-lspconfig'

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

" Vim Interaction
" ------------------------------------------------
Plug 'tpope/vim-repeat' " Dependency of vim-easyclip
Plug 'svermeulen/vim-easyclip'

 Syntax/Formatting
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
Plug 'samoshkin/vim-mergetool'
Plug 'rizzatti/dash.vim'
Plug 'skywind3000/asyncrun.vim'

call plug#end()
