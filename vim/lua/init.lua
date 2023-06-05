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
vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "b0o/mapx.nvim" },
  { "folke/which-key.nvim" },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
    dependencies = { 'nvim-lua/plenary.nvim' }
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
  { "aserowy/tmux.nvim" },
  { "JoosepAlviste/nvim-ts-context-commentstring" }

})

require('plugins')
require('core')
