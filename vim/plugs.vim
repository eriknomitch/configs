call plug#begin()

" ================================================
" PLUG->PACKAGES =================================
" ================================================

" ------------------------------------------------
" LSP --------------------------------------------
" ------------------------------------------------
"{{{
" SEE: LSP

" LSP Servers
" ------------------------------------------------
" NOTE: Requires LSP server(s)
" https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
"
" TypeScript:
" $ npm install -g typescript typescript-language-server
"
" Python:
" $ npm install -g pyright
"
" Vim:
" $ npm install -g vim-language-server


" SEE: LSP_SERVER_INITIALIZATION
" ------------------------------------------------
" FIX: I don't think this is true...?
" Additionally, for each server, pluginrc.d/nvim-lspconfig.vim needs to be
" edited. Add the server's executable hname to 'servers'.

" Packages
" ------------------------------------------------

" Quickstart configurations for the Nvim LSP client
" https://github.com/neovim/nvim-lspconfig
Plug 'neovim/nvim-lspconfig'

" Companion plugin to install language servers automatically
" https://github.com/williamboman/nvim-lsp-installer
Plug 'williamboman/nvim-lsp-installer'

" A completion plugin for neovim coded in Lua
" https://github.com/hrsh7th/nvim-cmp
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
"}}}

" ------------------------------------------------
" SNIPPETS ---------------------------------------
" ------------------------------------------------

" https://github.com/hrsh7th/vim-vsnip
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

" ------------------------------------------------
" GITHUB-COPILOT ---------------------------------
" ------------------------------------------------
Plug 'github/copilot.vim'

" ------------------------------------------------
" COC.NVIM ---------------------------------------
" ------------------------------------------------
"{{{
" NOTE: Only use coc.nvim for these select plugins:
" - coc-marketplace
" - coc-prettier
" - coc-git
" - coc-highlight
" - coc-react-refactor

" https://github.com/neoclide/coc.nvim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"}}}

" ------------------------------------------------
" SYNTAX-HIGHLIGHTING ----------------------------
" ------------------------------------------------
"{{{

" General
" ------------------------------------------------

" REPO: https://github.com/nvim-treesitter/nvim-treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" REPO: https://github.com/sheerun/vim-polyglot
" A collection of language packs for Vim.
Plug 'sheerun/vim-polyglot'

" Utility
" ------------------------------------------------
Plug 'junegunn/vim-easy-align'
Plug 'nathanaelkane/vim-indent-guides'

" Language-Specific
" ------------------------------------------------
" REPO: https://github.com/peitalin/vim-jsx-typescript
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'

" REPO: https://github.com/pangloss/vim-javascript
Plug 'pangloss/vim-javascript'

"}}}

" ------------------------------------------------
" UTILITY ----------------------------------------
" ------------------------------------------------

" A better way to create key mappings in Neovim
" REPO: https://github.com/b0o/mapx.nvim
Plug 'b0o/mapx.nvim'

" REPO: https://github.com/folke/which-key.nvim
" > Create key bindings that stick. WhichKey is a lua plugin for Neovim 0.5 that displays a popup with possible keybindings of the command you started typing.
Plug 'folke/which-key.nvim'

" Visualize undo history
" https://github.com/mbbill/undotree
Plug 'mbbill/undotree'

" Whitespace tools
" https://github.com/ntpeters/vim-better-whitespace
Plug 'ntpeters/vim-better-whitespace'

" Comment Line(s)
" https://github.com/tpope/vim-commentary
Plug 'tpope/vim-commentary'

" Hotkeys for surrounding strings, etc with anything
" https://github.com/tpope/vim-surround
Plug 'tpope/vim-surround'

" Interface
" ------------------------------------------------

" Extended fuzzy finder UI
" https://github.com/nvim-telescope/telescope.nvim
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" REPO: https://github.com/kyazdani42/nvim-web-devicons
" > A lua fork of vim-devicons. This plugin provides the same icons as well as colors for each icon.
Plug 'kyazdani42/nvim-web-devicons'

" REPO: https://github.com/folke/trouble.nvim
" > A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing.
Plug 'folke/trouble.nvim'

" Status Bars
" -----------------------------------------------

" https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Vim Interaction
" ------------------------------------------------
Plug 'tpope/vim-repeat' " Dependency of vim-easyclip
Plug 'svermeulen/vim-easyclip'

" ------------------------------------------------
Plug 'keith/swift.vim'

" Searching/Replacing
" ------------------------------------------------
Plug 'tpope/vim-abolish'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" tmux
" ------------------------------------------------
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'christoomey/vim-tmux-navigator'

" Other
" ------------------------------------------------
Plug 'samoshkin/vim-mergetool'
Plug 'skywind3000/asyncrun.vim'

" ------------------------------------------------
" COLORSCHEMES -----------------------------------
" ------------------------------------------------

" REPO: https://github.com/folke/lsp-colors.nvim-lua
" > 🌈 Plugin that creates missing LSP diagnostics highlight groups for color schemes that don't yet support the Neovim 0.5 builtin LSP client.
Plug 'folke/lsp-colors.nvim'

" REPO: https://github.com/tjdevries/colorbuddy.nvim
Plug 'tjdevries/colorbuddy.nvim'

" REPO: https://github.com/Iron-E/nvim-highlite
Plug 'Iron-E/nvim-highlite'

" ================================================
" END ============================================
" ================================================

call plug#end()
