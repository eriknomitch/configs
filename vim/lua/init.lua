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
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
	{ "folke/neoconf.nvim", cmd = "Neoconf" },
	{ "folke/neodev.nvim" },
	{ "folke/trouble.nvim" },
	{ "rcarriga/nvim-notify" },
	{ "NvChad/nvim-colorizer.lua" },
	{ "mfussenegger/nvim-dap" },
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
	},
	{ "williamboman/mason-lspconfig.nvim" },
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"jose-elias-alvarez/null-ls.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-null-ls").setup({
				automatic_setup = true,
			})
		end,
	},
	{ "neovim/nvim-lspconfig" },
	{ "aserowy/tmux.nvim" },
	{ "numToStr/Comment.nvim" },
	{ "williamboman/nvim-lsp-installer" },
	{ "jose-elias-alvarez/null-ls.nvim" },
	{ "lukas-reineke/lsp-format.nvim" },
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
	{ "lukas-reineke/indent-blankline.nvim" },
	{ "leafgarland/typescript-vim" },
	{ "peitalin/vim-jsx-typescript" },
	{ "pangloss/vim-javascript" },
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
	{ "prisma/vim-prisma" },
	{ "rafcamlet/nvim-luapad" },
})

-- --------------------------------------
-- --------------------------------------
-- --------------------------------------

require("tmux").setup()

require("Comment").setup({
	pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
})

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
		"pyright",
		"rust_analyzer",
		"gopls",
		"clangd",
		"jdtls",
		"solargraph",
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
	-- you can reuse a shared lspconfig on_attach callback here
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
					-- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
					vim.lsp.buf.format({ async = false })
				end,
			})
		end
	end,
})

require("lsp-format").setup({})
require("lspconfig").gopls.setup({ on_attach = require("lsp-format").on_attach })

require("luapad").setup()

-- --------------------------------------
-- --------------------------------------
-- --------------------------------------
vim.g.indent_guides_enable_on_vim_startup = 1

-- FIX:
require("plugins")
require("core")
