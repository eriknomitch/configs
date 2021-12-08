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
nnoremap({"<Leader>fg"}, ":lua require('telescope.builtin').live_grep()<Cr>", "silent")

