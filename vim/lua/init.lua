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

-- -----------------------------------------------
-- Plugin installation ---------------------------
-- -----------------------------------------------
require("lazy").setup({
	-- Syntax and language support
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				-- A list of parser names, or "all" (the five listed parsers should always be installed)
				-- ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },
				ensure_installed = "all",
				-- ensure_installed = "all",

				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,

				-- Automatically install missing parsers when entering buffer
				-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
				auto_install = true,

				-- List of parsers to ignore installing (for "all")
				-- ignore_install = { "javascript" },

				---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
				-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

				highlight = {
					enable = true,

					-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
					-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
					-- the name of the parser)
					-- list of language that will be disabled
					disable = { "c", "rust" },
					-- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
					disable = function(lang, buf)
						local max_filesize = 100 * 1024 -- 100 KB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,

					-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
					-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
					-- Using this option may slow down your editor, and you may see some duplicate highlights.
					-- Instead of true it can also be a list of languages
					additional_vim_regex_highlighting = true,
				},

				indent = {
					enable = true,
				},

				-- NOTE: For https://github.com/JoosepAlviste/nvim-ts-context-commentstring
				-- https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#plugins-with-a-pre-comment-hook
				context_commentstring = {
					enable = true,
					enable_autocmd = false,
				},
			})
		end,
	},
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
	-- { "folke/noice.nvim", dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" } },
	{ "lewis6991/gitsigns.nvim" },
	{ "akinsho/bufferline.nvim" },
	{ "lukas-reineke/indent-blankline.nvim" },
	-- { "karb94/neoscroll.nvim" },
	-- { "echasnovski/mini.animate" },
	{ "b0o/incline.nvim" },

	-- Editing support
	{ "numToStr/Comment.nvim", opts = {} },
	{ "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
	{ "junegunn/vim-easy-align" },
	{ "tpope/vim-repeat" },
	{ "svermeulen/vim-easyclip" },
	{
		"echasnovski/mini.nvim",
		version = false,
		config = function()
			-- Configure mini.pairs for auto-pairing
			require("mini.pairs").setup({})

			-- Configure mini.surround for surrounding text
			require("mini.surround").setup({})

			-- Configure mini.comment for commenting
			require("mini.comment").setup({})

			-- Configure mini.ai for improved text objects
			require("mini.ai").setup({})

			-- Configure mini.indentscope for indent guides
			require("mini.indentscope").setup({
				symbol = "│",
				options = { try_as_border = true },
			})

			-- Configure mini.move for moving lines/blocks
			require("mini.move").setup({
				mappings = {
					-- Move visual selection in Visual mode
					left = "<M-h>",
					right = "<M-l>",
					down = "<M-j>",
					up = "<M-k>",

					-- Move current line in Normal mode
					line_left = "<M-h>",
					line_right = "<M-l>",
					line_down = "<M-j>",
					line_up = "<M-k>",
				},
			})
		end,
	},

	-- Git integration
	{
		"NeogitOrg/neogit",
		dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim", "nvim-telescope/telescope.nvim" },
	},
	{ "samoshkin/vim-mergetool" },

	-- AI
	{ "github/copilot.vim" },

	-- Miscellaneous
	{ "b0o/mapx.nvim" },
	{ "folke/neoconf.nvim", cmd = "Neoconf" },
	{ "folke/neodev.nvim" },
	{ "mfussenegger/nvim-dap" },
	{ "aserowy/tmux.nvim" },
	{ "mbbill/undotree" },
	{ "skywind3000/asyncrun.vim" },
	{
		"chipsenkbeil/distant.nvim",
		branch = "v0.3",
		config = function()
			require("distant"):setup()
		end,
	},
	{ "folke/lsp-colors.nvim" },
	{ "tjdevries/colorbuddy.nvim" },
	{ "Iron-E/nvim-highlite" },
	{ "puremourning/vimspector" },
})

-- -----------------------------------------------
-- Plugin configurations -------------------------
-- -----------------------------------------------
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"ts_ls",
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

-- require("noice").setup({
-- 	lsp = {
-- 		override = {
-- 			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
-- 			["vim.lsp.util.stylize_markdown"] = true,
-- 			["cmp.entry.get_documentation"] = true,
-- 		},
-- 	},
-- 	presets = {
-- 		bottom_search = true,
-- 		command_palette = true,
-- 		long_message_to_split = true,
-- 		inc_rename = false,
-- 		lsp_doc_border = false,
-- 	},
-- })
--
-- require("tmux").setup({
-- 	copy_sync = {
-- 		redirect_to_clipboard = true,
-- 	},
-- })

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

-- Initialize core configuration
require("core")

-- Initialize plugins
require("plugins")

-- Configuration Load Message
-- -----------------------------------------------------------------------------
vim.api.nvim_command("echohl WarningMsg")
vim.api.nvim_command("echomsg 'Neovim configuration loaded successfully!'")
vim.api.nvim_command("echohl None")
