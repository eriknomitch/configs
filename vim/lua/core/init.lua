local core_modules = {
   "core.utilities",
}

require("core.utilities")

-- Initialize core modules
require("core.keymaps")
require("core.autocmds")

vim.notify("Loaded: core/", vim.log.levels.INFO, { title = "Neovim" })
