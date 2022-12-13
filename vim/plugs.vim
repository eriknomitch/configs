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

" FROM: https://github.com/hrsh7th/nvim-cmp#recommended-configuration
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

"}}}

" ------------------------------------------------
" SNIPPETS ---------------------------------------
" ------------------------------------------------

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

" REPO: https://github.com/nvim-treesitter/playground
" Plug 'nvim-treesitter/playground'

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
" COMMENTING -------------------------------------
" ------------------------------------------------

" Comment Line(s)
" REPO: https://github.com/tpope/vim-commentary
Plug 'tpope/vim-commentary'

" REPO: https://github.com/preservim/nerdcommenter
Plug 'preservim/nerdcommenter'

" REPO: https://github.com/suy/vim-context-commentstring
Plug 'suy/vim-context-commentstring'

" REPO: https://github.com/MaxMEllon/vim-jsx-pretty
Plug 'MaxMEllon/vim-jsx-pretty'

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

" Neovim plugin with collection of minimal, independent, and fast Lua modules dedicated to improve Neovim (version 0.5 and higher) experience
" mini.base16
" mini.bufremove
" mini.comment
" mini.completion
" mini.cursorword
" mini.doc
" mini.fuzzy
" mini.indentscope
" mini.jump
" mini.jump2d
" mini.misc
" mini.pairs
" mini.sessions
" mini.starter
" mini.statusline
" mini.surround
" mini.tabline
" mini.test
" mini.trailspace
" REPO: https://github.com/echasnovski/mini.nvim
" Plug 'echasnovski/mini.nvim'
"Plug 'echasnovski/mini.nvim', { 'branch': 'stable' }

" Interface
" ------------------------------------------------

" Telescope
" ------------------------------------------------
" Extended fuzzy finder UI
" REPO: https://github.com/nvim-telescope/telescope.nvim
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" REPO: https://github.com/nvim-telescope/telescope-github.nvim
Plug 'nvim-telescope/telescope-github.nvim'

" REPO: https://github.com/LinArcX/telescope-command-palette.nvim
Plug 'LinArcX/telescope-command-palette.nvim'

" ------------------------------------------------

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

Plug 'bfredl/nvim-luadev'

" Searching/Replacing
" ------------------------------------------------
Plug 'tpope/vim-abolish'

" tmux
" ------------------------------------------------
" Plug 'tmux-plugins/vim-tmux-focus-events'
 Plug 'christoomey/vim-tmux-navigator'

" notify
" ------------------------------------------------
" Notifier
" REPO: https://github.com/rcarriga/nvim-notify
Plug 'rcarriga/nvim-notify'

" Other
" ------------------------------------------------
Plug 'samoshkin/vim-mergetool'
Plug 'skywind3000/asyncrun.vim'

Plug 'chipsenkbeil/distant.nvim'

" ------------------------------------------------
" COLORS/COLORSCHEMES ----------------------------
" ------------------------------------------------

" REPO: https://github.com/folke/lsp-colors.nvim-lua
" > 🌈 Plugin that creates missing LSP diagnostics highlight groups for color schemes that don't yet support the Neovim 0.5 builtin LSP client.
Plug 'folke/lsp-colors.nvim'

" REPO: https://github.com/tjdevries/colorbuddy.nvim
Plug 'tjdevries/colorbuddy.nvim'

" REPO: https://github.com/Iron-E/nvim-highlite
Plug 'Iron-E/nvim-highlite'

" REPO: https://github.com/ziontee113/color-picker.nvim
" Plug 'ziontee113/color-picker.nvim'

" ------------------------------------------------
" ------------------------------------------------
" ------------------------------------------------
" REPO: https://github.com/luk400/vim-jukit
Plug 'luk400/vim-jukit'

" ================================================
" END ============================================
" ================================================

call plug#end()
