-- ================================================
-- LEADER KEY
-- ================================================
-- Set leader key *before* plugins and keymaps
-- NOTE: Both vim.g.mapleader and g.mapleader were set to "\\". Keeping one.
vim.g.mapleader = "\\"
-- vim.g.localleader = "\\" -- Optional: Set localleader as well (Commented out as it wasn't in the second block)

-- ================================================
-- OPTIONS
-- ================================================
-- Using local variables for brevity and potential performance benefits
local opt = vim.opt
local g = vim.g
local map = vim.keymap.set -- Assuming this is used later, keeping it here

-- File Handling & Encoding
opt.encoding = "utf-8"         -- Use UTF-8 encoding (Duplicate removed: vim.opt.encoding)
opt.fileencoding = "utf-8"     -- Set file encoding to UTF-8 (Duplicate removed: vim.opt.fileencoding)
opt.swapfile = false           -- Disable swap files (Duplicate removed: vim.opt.swapfile)
opt.backup = false             -- Disable backup files (Duplicate removed: vim.opt.backup)
opt.writebackup = false        -- Ensure write backup is also off (Added from second block)
opt.undofile = true            -- Enable persistent undo (Duplicate removed: vim.opt.undofile)
opt.undodir = vim.fn.stdpath("data") .. "/undodir" -- Set undo directory (Kept from first block)
opt.filetype = "on"            -- Enable filetype detection (default in Neovim) (Kept from first block)
vim.cmd("filetype plugin indent on") -- Enable filetype plugins and indentation (Duplicate removed)

-- UI / Appearance
opt.number = false             -- Show line numbers (Duplicate removed: vim.opt.number)
opt.relativenumber = false     -- Show relative line numbers (Duplicate removed: vim.opt.relativenumber)
opt.termguicolors = true       -- Enable true color support (Duplicate removed: vim.opt.termguicolors)
opt.background = "dark"        -- Set background (Added from second block)
opt.laststatus = 2             -- Always show the status line (Kept from first block)
opt.showmode = false           -- Don't show mode (Kept from first block)
opt.ruler = false              -- Don't show ruler (Kept from first block)
opt.signcolumn = "yes"         -- Always show sign column (Duplicate removed: vim.opt.signcolumn)
opt.scrolloff = 8              -- Keep 8 lines visible (Duplicate removed: vim.opt.scrolloff)
opt.sidescrolloff = 8          -- Keep 8 columns visible (Kept from first block)
opt.wrap = false               -- Disable line wrapping (Duplicate removed: vim.opt.wrap)
opt.linebreak = true           -- Wrap lines nicely if wrap is enabled (Kept from first block)
opt.list = true                -- Show invisible characters (Kept from first block)
opt.listchars = { tab = "▸ ", trail = "·", nbsp = "␣" } -- Define invisible chars (Kept from first block)
opt.cursorline = true          -- Highlight the current line (Added from second block)

-- Search
opt.incsearch = true           -- Incremental search (Duplicate removed: vim.opt.incsearch)
opt.hlsearch = true            -- Highlight search results (Duplicate removed: vim.opt.hlsearch)
opt.ignorecase = true          -- Ignore case (Duplicate removed: vim.opt.ignorecase)
opt.smartcase = true           -- Smart case (Duplicate removed: vim.opt.smartcase)

-- Behavior
-- CONFLICT: vim.opt.mouse = "" (disabled) vs opt.mouse = "a" (enabled). Choosing "a" (enabled) from the second block.
opt.mouse = "a"
opt.clipboard = "unnamedplus"  -- Use system clipboard (Duplicate handled: vim.opt.clipboard vs opt.clipboard:append)
opt.backspace = "indent,eol,start" -- Backspace behavior (Duplicate removed: vim.opt.backspace)
opt.autoindent = true          -- Auto-indent (Duplicate removed: vim.opt.autoindent)
opt.smartindent = true         -- Smart indent (Duplicate removed: vim.opt.smartindent)
opt.completeopt = "menu,menuone,noselect" -- Completion options (Kept from first block)
opt.hidden = true              -- Allow hidden buffers (Kept from first block)
-- opt.updatetime = 300        -- Faster update time (Commented out in first block)
-- opt.updatetime = 50         -- Faster update time (Commented out in second block) - Keeping commented
-- opt.timeoutlen = 100        -- Shorter timeout (Commented out in first block) - Keeping commented
-- opt.ttimeoutlen = 10        -- Shorter ttimeout (Commented out in first block) - Keeping commented
opt.splitright = true          -- Split new windows right (Added from second block)
opt.splitbelow = true          -- Split new windows below (Added from second block)
opt.iskeyword:append("-")      -- Consider - as part of word (Added from second block)

-- Tabs and Indentation
opt.expandtab = true           -- Use spaces instead of tabs (Duplicate removed: vim.opt.expandtab)
opt.tabstop = 2                -- Tab width (Duplicate removed: vim.opt.tabstop)
opt.softtabstop = 2            -- Soft tab width (Kept from first block)
opt.shiftwidth = 2             -- Indentation width (Duplicate removed: vim.opt.shiftwidth)

-- Folding
opt.foldmethod = "marker"      -- Use markers for folding (Kept from first block)
opt.foldlevel = 99             -- Start with folds open (Kept from first block)
opt.foldlevelstart = 99        -- Start editing with folds open (Kept from first block)
opt.foldenable = true          -- Enable folding (Kept from first block)

-- Wildmenu / Command Line
opt.wildmenu = true            -- Enable enhanced command-line completion (Kept from first block)
opt.wildmode = "longest:full,full" -- Completion mode (Kept from first block)
opt.wildchar = 9               -- Trigger char (<Tab>) (Kept from first block)

-- Performance
opt.lazyredraw = true          -- Don't redraw during macros (Kept from first block)
opt.maxmempattern = 1000       -- Max memory for pattern matching (Kept from first block)

-- Disable built-in Netrw (if using nvim-tree)
-- g.loaded_netrw = 1          -- (Commented out in first block) - Keeping commented
-- g.loaded_netrwPlugin = 1    -- (Commented out in first block) - Keeping commented

-- ================================================
-- AUTOCMDS
-- ================================================
-- NOTE: This section appears only once, keeping as is.
local augroup = vim.api.nvim_create_augroup("UserSettings", { clear = true })

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
  desc = "Highlight yanked region",
})

-- Auto resize panes on Vim resize
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  pattern = "*",
  command = "wincmd =",
  desc = "Resize windows on VimResized",
})

-- Filetype specific settings
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "markdown", "text" },
  command = "setlocal spell",
  desc = "Enable spellcheck for markdown and text",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "markdown",
  command = "setlocal textwidth=300", -- Or consider 0 for no auto-wrapping
  desc = "Set textwidth for markdown",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "crontab",
  command = "setlocal backupcopy=yes",
  desc = "Fix crontab editing issue",
})

-- Set filetype for specific extensions (Treesitter often handles this, but explicit can be useful)
-- vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
--   group = augroup,
--   pattern = {"*.tsx", "*.jsx"},
--   command = "set filetype=typescriptreact", -- Or javascriptreact
--   desc = "Set filetype for TSX/JSX",
-- })

-- Remember cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lnum = mark[1]
    local line_count = vim.api.nvim_buf_line_count(0)
    if lnum > 0 and lnum <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Restore cursor position on buffer load",
})

-- ================================================
-- COMMANDS
-- ================================================
-- NOTE: This section appears only once, keeping as is.
-- Write buffer with sudo (uses Vimscript in vim.cmd)
vim.cmd([[cmap w!! %!sudo tee > /dev/null %]])
vim.cmd([[ca w!! w!!]]) -- Alias for command mode

-- Write/edit all windows (windo)
vim.api.nvim_create_user_command("W", "windo write", { desc = "Write all windows" })
vim.api.nvim_create_user_command("E", "windo edit", { desc = "Edit all windows (reload)" }) -- Note: :E is often used for explore

-- ================================================
-- LAZY.NVIM PLUGIN MANAGER
-- ================================================
-- NOTE: This section appears only once, keeping as is.
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

require("lazy").setup({
  -- ================= Core Plugins =================
  { "nvim-lua/plenary.nvim", lazy = true }, -- Utility functions used by many plugins
  -- { "folke/neoconf.nvim", cmd = "Neoconf", config = true }, -- Manage global/local settings
  { "folke/neodev.nvim",     config = true }, -- Neovim Lua development helper

  -- ================= UI / UX =================
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = { width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = false, custom = { "^\\.git$" } }, -- Hide .git by default
        update_focused_file = { enable = true, update_cwd = true },
        diagnostics = { enable = true },
        git = { enable = true, ignore = false },
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers", -- Display open buffers
          diagnostics = "nvim_lsp",
          show_buffer_close_icons = true,
          show_close_icon = true,
          separator_style = "thin", -- "arrow", "slant", etc.
        },
      })
    end,
  },
  -- {
  -- 	"b0o/incline.nvim", -- Statusline integrated into window header
  -- 	config = function()
  -- 		require("incline").setup()
  -- 	end,
  -- 	event = "BufReadPre", -- Load early for UI consistency
  -- },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { enabled = true },
    },
    config = function(_, opts)
      require("ibl").setup(opts)
    end,
  },
  -- {
  -- 	"folke/which-key.nvim",
  -- 	event = "VeryLazy",
  -- 	config = function()
  -- 		require("which-key").setup({
  -- 			-- your configuration comes here
  -- 			-- or leave it empty to use the default settings
  -- 		})
  -- 	end,
  -- },
  -- {
  -- 	"rcarriga/nvim-notify", -- Notification manager
  -- 	config = function()
  -- 		vim.notify = require("notify")
  -- 		require("notify").setup({
  -- 			background_colour = "#000000", -- Dark background for notifications
  -- 			timeout = 3000, -- Notifications disappear after 3 seconds
  -- 		})
  -- 	end,
  -- },
  -- {
  -- 	"folke/trouble.nvim", -- Pretty diagnostics list
  -- 	dependencies = { "nvim-tree/nvim-web-devicons" },
  -- 	opts = {}, -- Use default configuration
  -- },
  { "NvChad/nvim-colorizer.lua", opts = {} }, -- Display colors for hex codes, etc.

  -- ================= Editing Enhancements =================
  -- {
  -- 	"echasnovski/mini.nvim", -- Collection of minimal plugins
  -- 	version = false, -- Use latest version
  -- 	config = function()
  -- 		require("mini.pairs").setup({}) -- Auto-pairs
  -- 		require("mini.surround").setup({}) -- Surround actions (ysiw", etc.)
  -- 		require("mini.ai").setup({}) -- Better text objects (a), i))
  -- 		require("mini.indentscope").setup({ -- Indent guides
  -- 			symbol = "│",
  -- 			options = { try_as_border = true },
  -- 		})
  -- 		require("mini.move").setup({ -- Move lines/blocks
  -- 			mappings = {
  -- 				left = "<M-h>",
  -- 				right = "<M-l>",
  -- 				down = "<M-j>",
  -- 				up = "<M-k>",
  -- 				line_left = "<M-h>",
  -- 				line_right = "<M-l>",
  -- 				line_down = "<M-j>",
  -- 				line_up = "<M-k>",
  -- 			},
  -- 		})
  -- 		-- require('mini.comment').setup({}) -- Uncomment if you want mini.comment instead of others
  -- 	end,
  -- },
  { "tpope/vim-repeat" },       -- Repeat plugin actions with '.'
  { "junegunn/vim-easy-align" }, -- Easy alignment command (e.g., gaip=)
  { "mbbill/undotree" },       -- Visualize undo history

  -- ================= Syntax & Treesitter =================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { -- Start with common languages, add more as needed
          "bash",
          "c",
          "cpp",
          "css",
          "dockerfile",
          "go",
          "graphql",
          "html",
          "javascript",
          "json",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "rust",
          "scss",
          "svelte",
          "terraform",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
          "zig",
        },
        sync_install = false, -- Install parsers asynchronously
        auto_install = true, -- Automatically install missing parsers
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false, -- Use Treesitter primarily
          -- disable = function(lang, buf) -- Example: Disable for large files
          --     local max_filesize = 100 * 1024 -- 100 KB
          --     local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          --     if ok and stats and stats.size > max_filesize then
          --         return true
          --     end
          -- end,
        },
        indent = { enable = true },
        -- context_commentstring = { -- Integration for commenting plugins
        --     enable = true,
        --     enable_autocmd = false,
        -- },
      })
    end,
  },
  { "prisma/vim-prisma" }, -- Prisma schema syntax highlighting

  -- ================= LSP & Completion =================
  {
    "williamboman/mason.nvim", -- Manage LSP servers, linters, formatters
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim", -- Bridge Mason and nvim-lspconfig
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { -- List LSP servers you want managed by Mason
          "lua_ls",
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
          "gopls",
        },
        automatic_installation = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig", -- Core LSP configuration
    dependencies = { "mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" }, -- Added cmp-nvim-lsp dependency
    config = function()
      local lspconfig = require("lspconfig")
      -- Ensure cmp_nvim_lsp capabilities are loaded correctly
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

      -- Define the on_attach function for LSP keymaps and settings
      -- Moved definition before usage in setup_handlers
      local on_attach = function(client, bufnr)
        -- map is defined at the top
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        map("n", "gD", vim.lsp.buf.declaration, { noremap = true, silent = true, buffer = bufnr, desc = "Go to Declaration" })
        map("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true, buffer = bufnr, desc = "Go to Definition" })
        map("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true, buffer = bufnr, desc = "Hover Documentation" })
        map("n", "gi", vim.lsp.buf.implementation, { noremap = true, silent = true, buffer = bufnr, desc = "Go to Implementation" })
        map("n", "<C-k>", vim.lsp.buf.signature_help, { noremap = true, silent = true, buffer = bufnr, desc = "Signature Help" })
        map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { noremap = true, silent = true, buffer = bufnr, desc = "Add Workspace Folder" })
        map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { noremap = true, silent = true, buffer = bufnr, desc = "Remove Workspace Folder" })
        map("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, { noremap = true, silent = true, buffer = bufnr, desc = "List Workspace Folders" })
        map("n", "<leader>D", vim.lsp.buf.type_definition, { noremap = true, silent = true, buffer = bufnr, desc = "Type Definition" })
        map("n", "<leader>rn", vim.lsp.buf.rename, { noremap = true, silent = true, buffer = bufnr, desc = "Rename" })
        map("n", "<leader>ca", vim.lsp.buf.code_action, { noremap = true, silent = true, buffer = bufnr, desc = "Code Action" })
        map("n", "gr", vim.lsp.buf.references, { noremap = true, silent = true, buffer = bufnr, desc = "Go to References" })
        map("n", "<leader>e", vim.diagnostic.open_float, { noremap = true, silent = true, buffer = bufnr, desc = "Show Line Diagnostics" })
        map("n", "[d", vim.diagnostic.goto_prev, { noremap = true, silent = true, buffer = bufnr, desc = "Previous Diagnostic" })
        map("n", "]d", vim.diagnostic.goto_next, { noremap = true, silent = true, buffer = bufnr, desc = "Next Diagnostic" })
        map("n", "<leader>q", vim.diagnostic.setloclist, { noremap = true, silent = true, buffer = bufnr, desc = "Diagnostic SetLocList" })

        -- Enable formatting if the server supports it
        if client.supports_method("textDocument/formatting") then
          map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { noremap = true, silent = true, buffer = bufnr, desc = "Format Code" })
          -- Optional: Format on save
          -- vim.api.nvim_create_autocmd("BufWritePre", {
          --     group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true }),
          --     buffer = bufnr,
          --     callback = function() vim.lsp.buf.format({ async = false }) end,
          -- })
        end
      end

      -- Setup servers managed by mason-lspconfig
      require("mason-lspconfig").setup_handlers({
        function(server_name) -- Default handler
          lspconfig[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach, -- Use the defined on_attach function
          })
        end,
        -- Custom setup for specific servers if needed
        ["lua_ls"] = function()
          lspconfig.lua_ls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = { globals = { "vim" } },
                workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                telemetry = { enable = false },
              },
            },
          })
        end
        -- ["tsserver"] = function()
        -- 	lspconfig.tsserver.setup({
        -- 		capabilities = capabilities,
        -- 		on_attach = on_attach,
        -- 		init_options = {
        -- 			plugins = {
        -- 				{
        -- 					name = "@vue/typescript-plugin",
        -- 					location = "/path/to/node_modules/@vue/typescript-plugin", -- ADJUST PATH
        -- 					languages = { "javascript", "typescript", "vue" },
        -- 				},
        -- 			},
        -- 		},
        -- 		filetypes = {
        -- 			"javascript",
        -- 			"javascriptreact",
        -- 			"javascript.jsx",
        -- 			"typescript",
        -- 			"typescriptreact",
        -- 			"typescript.tsx",
        -- 			"vue",
        -- 		},
        -- 	})
        -- end,
        -- Add other custom setups here...
      })

      -- Configure diagnostic signs (requires nvim-web-devicons)
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
      vim.diagnostic.config({
        virtual_text = false, -- Disable virtual text diagnostics
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",       -- Autocompletion engine
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- LSP source
      "hrsh7th/cmp-buffer",    -- Buffer source
      "hrsh7th/cmp-path",      -- Path source
      "hrsh7th/cmp-cmdline",   -- Command line source
      "L3MON4D3/LuaSnip",      -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- Snippet source for nvim-cmp
      -- Optional: Add other sources like cmp-nvim-lua, cmp-calc, etc.
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Confirm with Enter
          ["<Tab>"] = cmp.mapping(function(fallback)   -- Tab completion / snippet navigation
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        -- Optional: Configure appearance
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })

      -- Setup nvim-cmp for command line
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },
  { "L3MON4D3/LuaSnip", dependencies = { "saadparwaiz1/cmp_luasnip" } }, -- Snippet engine

  -- Note: null-ls is archived. Consider migrating to nvim-lint + conform.nvim
  -- {
  --     "jose-elias-alvarez/null-ls.nvim", -- Use Neovim as a language server to inject diagnostics & formatting
  --     dependencies = { "nvim-lua/plenary.nvim" },
  --     config = function()
  --         local null_ls = require("null-ls")
  --         null_ls.setup({
  --             debug = false,
  --             sources = {
  --                 null_ls.builtins.formatting.stylua,
  --                 null_ls.builtins.formatting.prettier, -- Use prettier instead of prettierd if installed globally/locally
  --                 null_ls.builtins.diagnostics.eslint, -- Use eslint instead of eslint_d
  --                 -- null_ls.builtins.completion.spell, -- Optional: spell completion
  --             },
  --             -- Optional: Format on save using null-ls
  --             -- on_attach = function(client, bufnr)
  --             --     if client.supports_method("textDocument/formatting") then
  --             --         vim.api.nvim_clear_autocmds({ group = vim.api.nvim_create_augroup("NullLsFormatOnSave", { clear = true }), buffer = bufnr })
  --             --         vim.api.nvim_create_autocmd("BufWritePre", {
  --             --             group = "NullLsFormatOnSave",
  --             --             buffer = bufnr,
  --             --             callback = function()
  --             --                 vim.lsp.buf.format({ bufnr = bufnr, filter = function(c) return c.name == "null-ls" end, async = false })
  --             --             end,
  --             --         })
  --             --     end
  --             -- end,
  --         })
  --     end,
  -- },
  -- { "lukas-reineke/lsp-format.nvim" }, -- If you prefer a dedicated formatting plugin

  -- ================= Fuzzy Finding (Telescope) =================
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6", -- Check for latest stable tag
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { preview_width = 0.5 },
          },
          sorting_strategy = "ascending",
          winblend = 0, -- Opacity
        },
        pickers = {
          -- Configure specific pickers
        },
        extensions = {
          -- Load extensions if any
          -- file_browser = { ... }
        },
      })
      -- Optional: Load extensions like file_browser
      -- pcall(require("telescope").load_extension, "file_browser")
    end,
  },
  { -- Optional: Telescope file browser extension
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      pcall(require("telescope").load_extension, "file_browser") -- Use pcall for safety
      -- Add keymap for file browser (ensure map is defined)
      map("n", "<leader>fb", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>",
        { noremap = true, silent = true, desc = "File Browser" })
    end,
  },

  -- ================= AI / Copilot =================
  { "github/copilot.vim" }, -- Requires Node.js

  -- ================= Miscellaneous =================
  { "b0o/mapx.nvim",     lazy = true }, -- Advanced keymapping utility (if needed)
  {
    "aserowy/tmux.nvim",         -- Tmux integration
    config = function()
      require("tmux").setup({
        -- copy_sync = { enable = true }, -- Sync vim clipboard with tmux
        navigation = { enable_default_keybindings = true }, -- Use C-h/j/k/l to navigate tmux panes
        resize = { enable_default_keybindings = true }, -- Use M-h/j/k/l to resize tmux panes
      })
    end,
  },
  { "skywind3000/asyncrun.vim" }, -- Run async commands
}, {
  -- Lazy.nvim options
  ui = {
    border = "rounded", -- Use rounded borders for Lazy UI
  },
})

-- ================================================
-- COLORSCHEME
-- ================================================
-- Set colorscheme *after* plugins are potentially loaded
-- Ensure the colorscheme is installed (e.g., via Lazy) or built-in
-- NOTE: This section appears only once, keeping as is.
pcall(vim.cmd, "colorscheme bluegreen") -- Use pcall for safety if colorscheme doesn't exist

-- Apply custom highlights if needed (might be better in colorscheme file or plugin config)
-- vim.cmd([[highlight NvimTreeNormal guibg=#111111 gui=nocombine guifg=#777777]])
-- vim.cmd([[highlight EndOfBuffer guibg=#090909 gui=nocombine guifg=#090909]])

-- ================================================
-- FINAL SETUP / CUSTOM MODULES
-- ================================================
-- NOTE: This section appears only once, keeping as is.
-- vim.api.nvim_command("echohl WarningMsg | echomsg 'Neovim configuration loaded successfully!' | echohl None")

-- Load custom Lua modules if they exist (use pcall for safety)
pcall(require, "core.init")
pcall(require, "core.keymaps")
pcall(require, "plugins.init")

-- Add a final message to confirm loading
-- print("Neovim configuration loaded!")


