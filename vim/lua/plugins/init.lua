-- ===============================================
-- ===============================================
-- ===============================================
require("plugins.packer")

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
require("mapx").setup{ global = false }

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
require("plugins.configs.nvim-lspconfig")
require("plugins.configs.nvim-cmp")
require("plugins.configs.coc-nvim")
require("plugins.configs.trouble")
require("plugins.configs.nvim-luadev")
require("plugins.configs.nvim-notify")

-- -----------------------------------------------
-- TELESCOPE -------------------------------------
-- -----------------------------------------------
require("plugins.configs.telescope-nvim")
require("plugins.configs.telescope-command-palette")

-- Extensions
require('telescope').load_extension('gh')
require('telescope').load_extension('command_palette')
require('telescope').load_extension('notify')

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------

-- Require all .lua files in the plugins/configs directory
-- local files = vim.split(vim.fn.glob('plugins/configs/*.lua'), "\n")

-- for _, file in ipairs(files) do
--   -- print(file:gsub('^plugins/configs/', ''):gsub('%.lua$', ''))
--   -- vim.api.nvim_echo(file)
--   vim.cmd(string.format("source %s", file))
-- end

-- vim.g.
-- vim.fn.expand

-- print(vim.fn.expand('%:.'))



-- local glob = vim.fn.stdpath('data') .. '/lua/plugins/configs/*.lua'

-- local files = vim.split(vim.fn.glob(glob), "\n")

-- for _, file in ipairs(files) do
--   require(file)
-- end



-- local plugin_configs_path = vim.fn.stdpath('data') ..'/site/pack/packer/opt/packer.nvim'
-- local files = vim.fn.glob('lua/plugins/configs/*.lua')
-- print(files[0])

