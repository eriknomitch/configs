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

-- vim.opt.relativenumber = true
-- vim.opt.number = true

require("lazy").setup({
	{ "nvim-treesitter/nvim-treesitter" },
	-- { "JoosepAlviste/nvim-ts-context-commentstring" },
	{ "b0o/mapx.nvim" },
	{ "folke/which-key.nvim" },
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
	{ "folke/neoconf.nvim", cmd = "Neoconf" },
	{ "folke/neodev.nvim" },
	{ "folke/trouble.nvim" },
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
	{
		"numToStr/Comment.nvim",
		opts = {
			-- add any options here
		},
		lazy = false,
		-- dependencies = {
		-- 	"JoosepAlviste/nvim-ts-context-commentstring",
		-- },
		-- opts = function()
		-- 	return {
		-- 		pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
		-- 	}
		-- end,
	},
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
	-- { "ntpeters/vim-better-whitespace" },
	{ "vim-airline/vim-airline" },
	{ "vim-airline/vim-airline-themes" },
	{ "tpope/vim-repeat" },
	{ "svermeulen/vim-easyclip" },
	-- SEE: :h notify.Config
	--   {
	--   background_colour = "NotifyBackground",
	--   fps = 30,
	--   icons = {
	--     DEBUG = "",
	--     ERROR = "",
	--     INFO = "",
	--     TRACE = "✎",
	--     WARN = ""
	--   },
	--   level = 2,
	--   minimum_width = 50,
	--   render = "default",
	--   stages = "fade_in_slide_out",
	--   time_formats = {
	--     notification = "%T",
	--     notification_history = "%FT%T"
	--   },
	--   timeout = 5000,
	--   top_down = true
	-- }
	--
	{
		"rcarriga/nvim-notify",
		config = function()
			vim.notify = require("notify")
		end,
	},
	{ "samoshkin/vim-mergetool" },
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
	{ "prisma/vim-prisma" },
	{ "lewis6991/gitsigns.nvim" },
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {}, -- this is equalent to setup({}) function
	},
	-- lazy.nvim
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	{
		"echasnovski/mini.animate",
		event = "VeryLazy",
		opts = function(_, opts)
			opts.scroll = {
				enable = false,
			}
		end,
	},
	{
		"b0o/incline.nvim",
		opts = {},
		-- Optional: Lazy load Incline
		event = "VeryLazy",
	},
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
		},
		opts = {
			options = {
				mode = "tabs",
				-- separator_style = "slant",
				show_buffer_close_icons = false,
				show_close_icon = false,
			},
		},
	},
	{
		"karb94/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({
				-- All these keys will be mapped to their corresponding default scrolling animation
				mappings = { "<Space>", "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
				hide_cursor = true, -- Hide cursor while scrolling
				stop_eof = true, -- Stop at <EOF> when scrolling downwards
				respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
				cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
				easing_function = nil, -- Default easing function
				pre_hook = nil, -- Function to run before the scrolling animation starts
				post_hook = nil, -- Function to run after the scrolling animation ends
				performance_mode = false, -- Disable "Performance Mode" on all buffers.
			})
		end,
	},
})

require("noice").setup({
	lsp = {
		-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
		},
	},
	-- you can enable a preset for easier configuration
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
		command_palette = true, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		inc_rename = false, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false, -- add a border to hover docs and signature help
	},
})

-- --------------------------------------
-- --------------------------------------
-- --------------------------------------
require("tmux").setup()

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
		-- "pyright",
		-- "python-lsp-server",
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

require("nvim-autopairs").setup()

require("gitsigns").setup()

-- vim.opt.list = true
-- vim.opt.listchars:append("space: ")
-- vim.opt.listchars:append("eol:↴")
--
-- vim.opt.termguicolors = true
-- vim.cmd([[highlight IndentBlanklineIndent1 guibg=#1f1f1f gui=nocombine]])
-- vim.cmd([[highlight IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine]])

-- require("indent_blankline").setup({
-- 	char = "",
-- 	char_highlight_list = {
-- 		"IndentBlanklineIndent1",
-- 		"IndentBlanklineIndent2",
-- 	},
-- 	space_char_highlight_list = {
-- 		"IndentBlanklineIndent1",
-- 		"IndentBlanklineIndent2",
-- 	},
-- 	show_trailing_blankline_indent = false,
-- 	space_char_blankline = " ",
-- 	show_current_context = true,
-- 	show_current_context_start = true,
-- })

-- --------------------------------------
-- --------------------------------------
-- --------------------------------------
vim.g.indent_guides_enable_on_vim_startup = 1

-- --------------------------------------
-- --------------------------------------
-- --------------------------------------
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- OR setup with some options
require("nvim-tree").setup({
	sort_by = "case_sensitive",
	view = {
		width = 30,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},
})

local function get_diagnostic_label(props)
	local icons = { error = "", warn = "", info = "", hint = "" }
	local label = {}

	for severity, icon in pairs(icons) do
		local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
		if n > 0 then
			table.insert(label, { icon .. " " .. n .. " ", group = "DiagnosticSign" .. severity })
		end
	end
	if #label > 0 then
		table.insert(label, { "| " })
	end
	return label
end

require("incline").setup()

-- Set bindings for nvim-tree:
-- - NvimTreeToggle: <C-t> and <leader>t
vim.api.nvim_set_keymap("n", "<C-t>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>t", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- require("nvim-tree.api").tree.toggle({
-- 	path = nil,
-- 	current_window = false,
-- 	find_file = false,
-- 	update_root = false,
-- 	focus = false,
-- })

-- highlight NvimTreeNormal guibg=#333333
vim.cmd([[highlight NvimTreeNormal guibg=#111111 gui=nocombine guifg=#777777]])

-- Hide the end of buffer tilde
vim.cmd([[highlight EndOfBuffer guibg=#090909 gui=nocombine guifg=#090909]])

-- This speeds somethings up
vim.g.skip_ts_context_commentstring_module = true

-- FIX:
require("plugins")
require("core")
