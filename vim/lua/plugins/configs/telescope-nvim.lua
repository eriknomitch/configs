-- " ------------------------------------------------
-- " ------------------------------------------------
-- " ------------------------------------------------
-- " Find files using Telescope command-line sugar.
-- " Using Lua functions
-- " nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
-- " nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
-- " nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
-- " nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

nnoremap({"<Leader>fb", "<Leader>b" }, ":lua require('telescope.builtin').buffers()<Cr>", "silent")
nnoremap({"<Leader>ff", "<Leader>f" }, ":lua require('telescope.builtin').find_files()<Cr>", "silent")
nnoremap({"<Leader>fg", "<Leader>g"}, ":lua require('telescope.builtin').live_grep()<Cr>", "silent")
nnoremap({"<Leader>t"}, ":Telescope<Cr>", "silent")

require('telescope').setup({
  defaults = {
    layout_config = {
      vertical = { width = 0.25 },
      horizontal = { width = 0.5, height = 0.7 },
      -- other layout configuration here
    },
    -- other defaults configuration here
  },
  -- other configuration values here
})

