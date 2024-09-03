-- Set up lazy.nvim
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

-- Set leader key
vim.g.mapleader = "\\" -- Make sure to set `mapleader` before lazy so your mappings are correct

-- Plugin setup
require("lazy").setup({
	-- Syntax and language support
	{ "nvim-treesitter/nvim-treesitter" },
	{ "leafgarland/typescript-vim" },
	{ "peitalin/vim-jsx-typescript" },
	{ "pangloss/vim-javascript" },
	{ "MaxMEllon/vim-jsx-pretty" },
	{ "prisma/vim-prisma" },

	-- LSP and completion
	{ "neovim/nvim-lspconfig" },
	{ "williamboman/mason.nvim", build = ":MasonUpdate" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "williamboman/nvim-lsp-installer" },
	{ "jose-elias-alvarez/null-ls.nvim" },
	{ "lukas-reineke/lsp-format.nvim" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-vsnip" },
	{ "hrsh7th/vim-vsnip" },
	{ "L3MON4D3/LuaSnip" },
	{ "saadparwaiz1/cmp_luasnip" },

	-- Fuzzy finding and file navigation
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- UI enhancements
	{ "folke/which-key.nvim" },
	{ "folke/trouble.nvim" },
	{ "NvChad/nvim-colorizer.lua" },
	{ "vim-airline/vim-airline" },
	{ "vim-airline/vim-airline-themes" },
	{ "rcarriga/nvim-notify" },
	{ "folke/noice.nvim", dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" } },
	{ "lewis6991/gitsigns.nvim" },
	{ "akinsho/bufferline.nvim" },
	{ "lukas-reineke/indent-blankline.nvim" },
	{ "karb94/neoscroll.nvim" },
	{ "echasnovski/mini.animate" },
	{ "b0o/incline.nvim" },

	-- Editing support
	{ "numToStr/Comment.nvim", opts = {} },
	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
	{ "github/copilot.vim" },
	{ "junegunn/vim-easy-align" },
	{ "tpope/vim-repeat" },
	{ "svermeulen/vim-easyclip" },

	-- Git integration
	{
		"NeogitOrg/neogit",
		dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim", "nvim-telescope/telescope.nvim" },
	},
	{ "samoshkin/vim-mergetool" },

	-- Miscellaneous
	{ "b0o/mapx.nvim" },
	{ "folke/neoconf.nvim", cmd = "Neoconf" },
	{ "folke/neodev.nvim" },
	{ "mfussenegger/nvim-dap" },
	{ "aserowy/tmux.nvim" },
	{ "mbbill/undotree" },
	{ "skywind3000/asyncrun.vim" },
	{ "chipsenkbeil/distant.nvim", branch = "v0.3" },
	{ "folke/lsp-colors.nvim" },
	{ "tjdevries/colorbuddy.nvim" },
	{ "Iron-E/nvim-highlite" },
	{ "puremourning/vimspector" },
})

-- Plugin configurations
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"tsserver",
		"cssls",
		"eslint",
		"html",
		"vimls",
		"bashls",
		"dockerls",
		"yamlls",
		"rust_analyzer",
		"clangd",
		"jdtls",
		"svelte",
		"tailwindcss",
		"terraformls",
		"graphql",
		"clojure_lsp",
		"elixirls",
		"zls",
	},
	automatic_installation = true,
})

local null_ls = require("null-ls")
null_ls.setup({
	debug = true,
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.prettierd,
		null_ls.builtins.formatting.eslint_d,
		null_ls.builtins.diagnostics.eslint_d,
		null_ls.builtins.completion.spell,
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ async = false })
				end,
			})
		end
	end,
})

require("lsp-format").setup({})
require("lspconfig").gopls.setup({ on_attach = require("lsp-format").on_attach })

require("nvim-autopairs").setup()
require("gitsigns").setup()
require("neogit").setup({})

require("noice").setup({
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
	},
	presets = {
		bottom_search = true,
		command_palette = true,
		long_message_to_split = true,
		inc_rename = false,
		lsp_doc_border = false,
	},
})

require("tmux").setup({
	copy_sync = {
		redirect_to_clipboard = true,
	},
})

require("nvim-tree").setup({
	sort_by = "case_sensitive",
	view = { width = 30 },
	renderer = { group_empty = true },
	filters = { dotfiles = true },
})

require("incline").setup()

-- Keymappings
vim.api.nvim_set_keymap("n", "<C-t>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>t", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Open Neogit with <leader>g
vim.api.nvim_set_keymap("n", "<leader>g", ":Neogit<CR>", { noremap = true, silent = true })

-- Vim options and commands
vim.g.indent_guides_enable_on_vim_startup = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.g.skip_ts_context_commentstring_module = true

-- Custom highlights
vim.cmd([[highlight NvimTreeNormal guibg=#111111 gui=nocombine guifg=#777777]])
vim.cmd([[highlight EndOfBuffer guibg=#090909 gui=nocombine guifg=#090909]])

-- Load additional configuration files
require("plugins")
require("core")

-- Configuration Load Message
-- -----------------------------------------------------------------------------
vim.api.nvim_command("echohl WarningMsg")
vim.api.nvim_command("echomsg 'Neovim configuration loaded successfully!'")
vim.api.nvim_command("echohl None")
