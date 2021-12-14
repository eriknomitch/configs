-- ===============================================
-- ===============================================
-- ===============================================
require'mapx'.setup{ global = true }

-- -----------------------------------------------
-- -----------------------------------------------
-- -----------------------------------------------
require("plugins.configs.nvim-cmp")
require("plugins.configs.telescope-nvim")
require("plugins.configs.coc-nvim")
require("plugins.configs.trouble")

local plugin_configs_path = vim.fn.stdpath('data') ..'/site/pack/packer/opt/packer.nvim'

-- local files = vim.fn.glob('lua/plugins/configs/*.lua')

-- print(files[0])

-- for _, file in ipairs(files) do
--   print(file)
-- end
