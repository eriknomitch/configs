-- ===============================================
-- ===============================================
-- ===============================================

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
require("mapx").setup{ global = false }

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
require("plugins.configs.nvim-treesitter")
require("plugins.configs.nvim-cmp")
require("plugins.configs.trouble")
require("plugins.configs.nvim-luadev")
require("plugins.configs.nvim-notify")
require("plugins.configs.nvim-colorizer")


-- -----------------------------------------------
-- TELESCOPE -------------------------------------
-- -----------------------------------------------
require("plugins.configs.telescope-nvim")
--
-- -- Bootstrap lazy.nvim
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system({
--     "git",
--     "clone",
--     "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git",
--     "--branch=stable",
--     lazypath,
--   })
-- end
-- vim.opt.rtp:prepend(lazypath)
--
-- -- Plugin specifications
-- return require("lazy").setup({
--   -- Load plugin configurations from separate modules
--   -- { import = "plugins.ui" },     -- UI-related plugins
--   -- { import = "plugins.lsp" },    -- LSP configurations
--   -- { import = "plugins.coding" }, -- Coding-related plugins
--
--   -- Core plugins that don't need separate configuration files
--   -- { "nvim-lua/plenary.nvim" },  -- Lua functions library
--   -- { "tpope/vim-repeat" },       -- Enable repeating supported plugin maps
--   -- { "tpope/vim-surround" },     -- Surround text objects
--
--   -- Git integration
--   -- {
--   --   "lewis6991/gitsigns.nvim",
--   --   event = { "BufReadPre", "BufNewFile" },
--   --   config = true,
--   -- },
--
--   -- Fuzzy finding
--   {
--     "nvim-telescope/telescope.nvim",
--     dependencies = { "nvim-lua/plenary.nvim" },
--     cmd = "Telescope",
--   },
--
--   -- File explorer
--   {
--     "nvim-tree/nvim-tree.lua",
--     dependencies = { "nvim-tree/nvim-web-devicons" },
--     cmd = { "NvimTreeToggle", "NvimTreeFocus" },
--   },
-- }, {
--   install = {
--     colorscheme = { "tokyonight" },
--   },
--   checker = {
--     enabled = true,
--     notify = false,
--   },
--   change_detection = {
--     notify = false,
--   },
-- })
