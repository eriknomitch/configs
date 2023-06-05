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
require("plugins.configs.nvim-treesitter")
require("plugins.configs.nvim-cmp")
require("plugins.configs.coc-nvim")
require("plugins.configs.trouble")
require("plugins.configs.nvim-luadev")
require("plugins.configs.nvim-notify")
require("plugins.configs.nvim-colorizer")
require("plugins.configs.mason")


-- -----------------------------------------------
-- TELESCOPE -------------------------------------
-- -----------------------------------------------
require("plugins.configs.telescope-nvim")

require('Comment').setup()require('Comment').setup()
