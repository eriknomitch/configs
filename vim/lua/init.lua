-- vim:foldmethod=marker

-- ================================================
-- OPTIONS (Converted from init.vim) {{{
-- ================================================
vim.opt.encoding = "utf-8" -- Set encoding to UTF-8
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.termguicolors = true -- Enable true color support

-- Search
vim.opt.incsearch = true -- Instant search
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.smartcase = true -- Smart case search (override ignorecase if uppercase letters are used)

-- Behavior
-- vim.opt.nocompatible = true -- Already default in Neovim Lua
vim.opt.filetype = "on" -- Enable filetype detection (already default)
vim.cmd("filetype plugin indent on") -- Enable filetype plugin and indent (using vim.cmd for simplicity)
vim.opt.noswapfile = true -- Disable swap files
vim.opt.laststatus = 2 -- Always show status line
vim.opt.autoindent = true -- Auto-indent new lines
vim.opt.smartindent = true -- Smart auto-indenting for C-like languages
vim.opt.smarttab = true -- Use tabs for indentation based on shiftwidth
vim.opt.magic = true -- Enable magic characters in regex
vim.opt.maxmempattern = 1000 -- Max memory for pattern matching
vim.opt.showmode = true -- Show current mode
vim.opt.ruler = true -- Show cursor position
vim.opt.hlsearch = true -- Highlight search results
vim.opt.mouse = "" -- Disable mouse support
vim.opt.backspace = "indent,eol,start" -- Allow backspace over everything in insert mode
vim.opt.clipboard = "unnamedplus" -- Use system clipboard (prefer unnamedplus for Linux/Wayland/X11)
-- If on macOS and 'unnamedplus' causes issues, try: vim.opt.clipboard = 'unnamed'

-- Tabs and Indentation
vim.opt.softtabstop = 2 -- Number of spaces that a <Tab> counts for
vim.opt.tabstop = 2 -- Number of spaces that a <Tab> represents
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent

-- Folding
vim.opt.foldmethod = "marker" -- Use markers for folding

-- UI / Wildmenu
vim.opt.wildmenu = true -- Enable enhanced command-line completion
vim.opt.wildchar = vim.api.nvim_replace_termcodes("<Tab>", true, false, true) -- Character to trigger wildmenu completion

-- Completion
vim.opt.completeopt = "menu,menuone,noselect" -- Completion options

-- Netrw (Attempt to disable in favor of nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- }}}
-- ================================================
-- KEYMAPS (Converted from init.vim) {{{
-- ================================================
vim.g.mapleader = "\\" -- Set leader key (already set, but confirming)

-- Faster navigation with Shift
vim.keymap.set("n", "<S-j>", "4j", { noremap = true, silent = true })
vim.keymap.set("n", "<S-k>", "4k", { noremap = true, silent = true })
vim.keymap.set("n", "<S-h>", "4h", { noremap = true, silent = true })
vim.keymap.set("n", "<S-l>", "4l", { noremap = true, silent = true })

-- Buffer navigation
vim.keymap.set({"n", "i", "v"}, "<C-S-Right>", "<cmd>next<CR>", { noremap = true, silent = true })
vim.keymap.set({"n", "i", "v"}, "<C-S-Left>", "<cmd>prev<CR>", { noremap = true, silent = true })

-- Page navigation
vim.keymap.set({"n", "v", "o"}, "<Space>", "<PageDown>", { noremap = true })
vim.keymap.set({"n", "v", "o"}, "-", "<PageUp>", { noremap = true })

-- Virtual lines navigation (use gj/gk instead of j/k)
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })
vim.keymap.set({"n", "v", "o"}, "<Up>", "gk", { noremap = true })
vim.keymap.set({"n", "v", "o"}, "<Down>", "gj", { noremap = true })

-- Folding remaps
vim.keymap.set("n", "zO", "zR", { noremap = true }) -- Open folds recursively
vim.keymap.set("n", "zC", "zM", { noremap = true }) -- Close folds recursively

-- Insert literal tab with Shift+Tab
vim.keymap.set("i", "<S-Tab>", "<C-V><Tab>", { noremap = true })

-- Window resizing
vim.keymap.set({"n", "i", "v"}, "<C-S-Left>", "<cmd>vertical resize +5<CR>", { noremap = true, silent = true })
vim.keymap.set({"n", "i", "v"}, "<C-S-Right>", "<cmd>vertical resize -5<CR>", { noremap = true, silent = true })
vim.keymap.set({"n", "i", "v"}, "<C-S-Up>", "<cmd>resize +5<CR>", { noremap = true, silent = true })
vim.keymap.set({"n", "i", "v"}, "<C-S-Down>", "<cmd>resize -5<CR>", { noremap = true, silent = true })

-- Paste toggle (using F3 as defined in options)
-- nnoremap <F3> :set invpaste paste?<CR> -- Handled by pastetoggle option
-- map <F1> :set paste<CR>
-- map <F2> :set nopaste<CR>
-- imap <F1> <C-O>:set paste<CR>
-- imap <F2> <nop>
-- Note: F1/F2 mappings are less common now, consider removing if not used.
vim.keymap.set({"n", "i"}, "<F1>", "<cmd>set paste<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<F2>", "<cmd>set nopaste<CR>", { noremap = true, silent = true })
-- For insert mode F2, <nop> means do nothing, effectively disabling it if it had a default.
vim.keymap.set("i", "<F2>", "<nop>", { noremap = true, silent = true })


-- Quick quit mapping
vim.keymap.set("n", "q", "<cmd>wqall<CR>", { noremap = true, silent = true })

-- Whisper Mappings (Translated)
-- NOTE: These rely on external scripts and temporary files. Ensure `whisper.nvim` script exists and works.
local whisper_cmd = "!whisper.nvim"
local process_whisper_output_cmd =
	"let @a = system(\"cat /tmp/whisper.nvim | tail -n 1 | xargs -0 | tr -d '\\n' | sed -e 's/^[[:space:]]*//'\")"

vim.keymap.set("i", "<C-G>", "<C-O>:" .. whisper_cmd .. "<CR><C-O>:" .. process_whisper_output_cmd .. "<CR><C-R>a", { noremap = true, silent = true, desc = "Whisper: Insert transcription" })
vim.keymap.set("n", "<C-G>", ":" .. whisper_cmd .. "<CR>:" .. process_whisper_output_cmd .. "<CR>\"ap", { noremap = true, silent = true, desc = "Whisper: Put transcription" })
vim.keymap.set("v", "<C-G>", "c<C-O>:" .. whisper_cmd .. "<CR><C-O>:" .. process_whisper_output_cmd .. "<CR><C-R>a", { noremap = true, silent = true, desc = "Whisper: Replace selection with transcription" })


-- }}}
-- ================================================
-- AUTOCMDS (Converted from init.vim) {{{
-- ================================================
local augroup = vim.api.nvim_create_augroup("UserSettings", { clear = true })

-- Spellcheck for markdown and text files
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.md", "*.txt"},
  command = "setlocal spell",
  group = augroup,
})

-- Disable spellcheck for specific file pattern
vim.api.nvim_create_autocmd("BufRead", {
  pattern = ".del.txt",
  command = "setlocal nospell",
  group = augroup,
})

-- Set textwidth for markdown
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.md",
  command = "setlocal textwidth=300",
  group = augroup,
})

-- Fix crontab editing issue
vim.api.nvim_create_autocmd("FileType", {
  pattern = "crontab",
  command = "setlocal backupcopy=yes",
  group = augroup,
})

-- Set filetype for TSX/JSX
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.tsx", "*.jsx"},
  command = "set filetype=typescriptreact",
  group = augroup,
})

-- Tmux integration (Consider using tmux.nvim plugin features instead)
if vim.env.TMUX then
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
      local filename = vim.fn.expand("%:t")
      if filename ~= "" then
        vim.fn.system("tmux rename-window '" .. filename .. "'")
      end
    end,
    group = augroup,
  })
  vim.api.nvim_create_autocmd("VimLeave", {
    pattern = "*",
    command = "!tmux setw automatic-rename",
    group = augroup,
  })
end

-- }}}
-- ================================================
-- COMMANDS (Converted from init.vim) {{{
-- ================================================
-- Write buffer with sudo
-- Note: cmap is tricky to translate directly to Lua. Using vim.cmd for simplicity.
vim.cmd([[cmap w!! w !sudo tee > /dev/null %]])

-- Write/edit all windows
vim.api.nvim_create_user_command('W', 'windo w', {})
vim.api.nvim_create_user_command('E', 'windo e', {})

-- Custom Edit command
local function custom_edit(args)
  local path = args.fargs[1]
  if path then
    vim.cmd('edit ' .. path)
    vim.cmd('badd ' .. path)
  else
    print("Error: No path provided for E command")
  end
end
vim.api.nvim_create_user_command('E', custom_edit, { nargs = 1 })


-- }}}
-- ================================================
-- COLORSCHEME {{{
-- ================================================
-- Set colorscheme (ensure it's installed or a default one)
-- Consider managing colorschemes with lazy.nvim for better results
vim.cmd("colorscheme bluegreen")

-- }}}

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
	{ "prisma/vim-prisma" },

	-- LSP and completion
	{ "neovim/nvim-lspconfig" },
	{ "williamboman/mason.nvim", build = ":MasonUpdate" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "jose-elias-alvarez/null-ls.nvim" },
	{ "lukas-reineke/lsp-format.nvim" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },
	{ "hrsh7th/nvim-cmp" },
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
	{ "rcarriga/nvim-notify" },
	-- { "folke/noice.nvim", dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" } },
	{ "akinsho/bufferline.nvim" },
	{ "lukas-reineke/indent-blankline.nvim" },
	-- { "karb94/neoscroll.nvim" },
	-- { "echasnovski/mini.animate" },
	{ "b0o/incline.nvim" },

	-- Editing support
	{ "junegunn/vim-easy-align" },
	{ "tpope/vim-repeat" },
	{
		"echasnovski/mini.nvim",
		version = false,
		config = function()
			-- Configure mini.pairs for auto-pairing
			require("mini.pairs").setup({})

			-- Configure mini.surround for surrounding text
			require("mini.surround").setup({})

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

	-- AI
	{ "github/copilot.vim" },

	-- Miscellaneous
	{ "b0o/mapx.nvim" },
	{ "folke/neoconf.nvim", cmd = "Neoconf" },
	{ "folke/neodev.nvim" },
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
-- vim.g.loaded_netrw = 0
-- vim.g.loaded_netrwPlugin = 0
vim.opt.termguicolors = true
-- vim.g.skip_ts_context_commentstring_module = true -- This might be needed depending on Treesitter/commentstring setup

-- Custom highlights (Example - adjust as needed)
-- vim.cmd([[highlight NvimTreeNormal guibg=#111111 gui=nocombine guifg=#777777]]) -- NvimTree might have its own config for this
-- vim.cmd([[highlight EndOfBuffer guibg=#090909 gui=nocombine guifg=#090909]]) -- Adjust colors as desired

-- Initialize core configuration (If you have a core.lua)
-- require("core")

-- Initialize plugins
require("plugins")

-- Configuration Load Message
-- -----------------------------------------------------------------------------
-- Commenting out the load message to troubleshoot
-- vim.api.nvim_command("echohl WarningMsg")
-- vim.api.nvim_command("echomsg 'Neovim configuration loaded successfully!'")
-- vim.api.nvim_command("echohl None")
-- Disable line number column
vim.opt.number = false
vim.opt.relativenumber = false
