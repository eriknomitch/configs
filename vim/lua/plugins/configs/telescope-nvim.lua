-- ===============================================
-- CONFIGS->TELESCOPE-NVIM =======================
-- ===============================================
nnoremap({"<Leader>t"}, ":Telescope<Cr>", "silent")

nnoremap({"<Leader>b", "<C-p>" }, ":lua require('telescope.builtin').buffers()<Cr>", "silent")
nnoremap({"<Leader>f" }, ":lua require('telescope.builtin').find_files()<Cr>", "silent")
-- nnoremap({"<Leader>fg", "<Leader>g"}, ":lua require('telescope.builtin').live_grep()<Cr>", "silent")
nnoremap({"<Leader>gd", "<Leader>gs"}, ":lua require('telescope.builtin').git_status()<Cr>", "silent")
nnoremap({"<Leader>s"}, ":lua require('telescope.builtin').live_grep({grep_open_files=true})<Cr>", "silent")
-- nnoremap({"<Leader>fh", "<Leader>th"}, ":lua require('telescope.builtin').help_tags()<Cr>", "silent")

nnoremap({"<Leader>/"}, ":lua require('telescope.builtin').current_buffer_fuzzy_find()<Cr>", "silent")

local actions = require("telescope.actions")
local trouble = require("trouble.providers.telescope")
local telescope = require("telescope")

require('telescope').setup({
  defaults = {
    layout_config = {
      horizontal = { width = 0.9, height = 0.9 },
      -- SEE: :help resolver.resolve_anchor_pos()
      -- anchor = 'W',
    },
    mappings = {
      -- FROM: https://github.com/folke/trouble.nvim#telescope
      i = {
        ["<C-t>"] = trouble.open_with_trouble,
        -- FROM: https://github.com/nvim-telescope/telescope.nvim/issues/919#issue-923575521
        ["<C-j>"]   = actions.move_selection_next,
        ["<C-k>"]   = actions.move_selection_previous,
        ["<ESC>"]   = actions.close
      },
      n = { ["<C-t>"] = trouble.open_with_trouble },
    },
    -- other defaults configuration here
  },
  -- pickers = {
  --   find_files = {
  --     theme = "dropdown",
  --   }
  -- },
  -- other configuration values here
})

