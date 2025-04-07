-- ===============================================
-- CONFIGS->TELESCOPE-NVIM =======================
-- ===============================================
local mapx = require("mapx")
local map = vim.keymap.set

mapx.nnoremap({ "<Leader>T" }, ":Telescope<Cr>", "silent")

-- Use standard map for instant trigger, add description
map("n", "<Leader>b", "<cmd>lua require('telescope.builtin').buffers()<CR>", { noremap = true, silent = true, desc = "Find Buffers" })
map("n", "<C-p>", "<cmd>lua require('telescope.builtin').buffers()<CR>", { noremap = true, silent = true, desc = "Find Buffers (Ctrl+P)" }) -- Keep Ctrl+P mapping separate if desired

mapx.nnoremap({ "<Leader>f" }, ":lua require('telescope.builtin').find_files()<Cr>", "silent")
mapx.nnoremap({ "<Leader>s" }, ":lua require('telescope.builtin').live_grep({grep_open_files=true})<Cr>", "silent")
-- mapx.nnoremap({"<Leader>fg", "<Leader>g"}, ":lua require('telescope.builtin').live_grep()<Cr>", "silent")
-- mapx.nnoremap({"<Leader>gd", "<Leader>gs"}, ":lua require('telescope.builtin').git_status()<Cr>", "silent")
-- mapx.nnoremap({"<Leader>fh", "<Leader>th"}, ":lua require('telescope.builtin').help_tags()<Cr>", "silent")
-- vim.api.nvim_set_keymap(
-- 	"n",
-- 	"<Leader>s",
-- 	":lua require('telescope.builtin').live_grep({grep_open_files=true,debounce=100})<Cr>",
-- 	{ noremap = true, silent = true }
-- )

mapx.nnoremap({ "<Leader>/" }, ":lua require('telescope.builtin').current_buffer_fuzzy_find()<Cr>", "silent")

local actions = require("telescope.actions")
local trouble = require("trouble.providers.telescope")
local telescope = require("telescope")

require("telescope").setup({
	defaults = {
		layout_config = {
			horizontal = { width = 0.9, height = 0.9 },
			-- SEE: :help resolver.resolve_anchor_pos()
			-- anchor = 'W',
		},
		-- mappings = {
		--   i = {
		--     ["<C-t>"] = trouble.open_with_trouble,
		--     -- FROM: https://github.com/nvim-telescope/telescope.nvim/issues/919#issue-923575521
		--     ["<C-j>"]   = actions.move_selection_next,
		--     ["<C-k>"]   = actions.move_selection_previous,
		--     ["<ESC>"]   = actions.close
		--   },
		--   -- FROM: https://github.com/folke/trouble.nvim#telescope
		--   n = { ["<C-t>"] = trouble.open_with_trouble },
		-- },
		-- other defaults configuration here
	},
	-- pickers = {
	--   find_files = {
	--     theme = "dropdown",
	--   }
	-- },
	-- other configuration values here
})

require("telescope").load_extension("file_browser")
-- require('telescope').load_extension('gh')
