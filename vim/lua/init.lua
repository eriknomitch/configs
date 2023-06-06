local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Example using a list of specs with the default options
vim.g.mapleader = "\\" -- Make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({

  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  { "b0o/mapx.nvim" },
  { "folke/which-key.nvim" },
  {
    "nvim-telescope/telescope.nvim", tag = "0.1.1",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  { "folke/neodev.nvim" },
  { "folke/trouble.nvim" },
  { "rcarriga/nvim-notify" },
  { "NvChad/nvim-colorizer.lua" },
  { "mfussenegger/nvim-dap" },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate" -- :MasonUpdate updates registry contents
  },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  { "aserowy/tmux.nvim" },
  { "JoosepAlviste/nvim-ts-context-commentstring" },
  { "numToStr/Comment.nvim" },
  { "williamboman/nvim-lsp-installer" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "saadparwaiz1/cmp_luasnip" },
  { "L3MON4D3/LuaSnip" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-vsnip" },
  { "hrsh7th/vim-vsnip" },
  { "github/copilot.vim" },
  { "junegunn/vim-easy-align" },
  { "nathanaelkane/vim-indent-guides" },
  { "leafgarland/typescript-vim" },
  { "peitalin/vim-jsx-typescript" },
  { "pangloss/vim-javascript" },
  -- { "tpope/vim-commentary" },
  -- { "preservim/nerdcommenter" },
  { "suy/vim-context-commentstring" },
  { "MaxMEllon/vim-jsx-pretty" },
  { "b0o/mapx.nvim" },
  { "mbbill/undotree" },
  { "ntpeters/vim-better-whitespace" },
  { "kyazdani42/nvim-web-devicons" },
  { "vim-airline/vim-airline" },
  { "vim-airline/vim-airline-themes" },
  { "tpope/vim-repeat" },
  { "svermeulen/vim-easyclip" },
  { "keith/swift.vim" },
  { "tpope/vim-abolish" },
  { "rcarriga/nvim-notify" },
  { "samoshkin/vim-mergetool" },
  { "skywind3000/asyncrun.vim" },
  { "chipsenkbeil/distant.nvim" },
  { "folke/lsp-colors.nvim" },
  { "tjdevries/colorbuddy.nvim" },
  { "Iron-E/nvim-highlite" },
  { "puremourning/vimspector" },
  { "prisma/vim-prisma" }
})

require('Comment').setup {
  pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
}

require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "lua_ls", "tsserver", "cssls", "eslint", "html", "vimls", "bashls", "dockerls", "yamlls", "pyright", "rust_analyzer", "gopls", "clangd", "jdtls", "solargraph", "svelte", "tailwindcss", "terraformls", "graphql", "clojure_lsp", "elixirls", "zls" },
  automatic_installation = true
}

-- After setting up mason-lspconfig you may set up servers via lspconfig
-- require("lspconfig").lua_ls.setup {}
-- require("lspconfig").rust_analyzer.setup {}
-- ...

require('plugins')
require('core')
