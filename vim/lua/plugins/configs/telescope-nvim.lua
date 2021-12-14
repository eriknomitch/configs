-- ===============================================
-- CONFIGS->TELESCOPE-NVIM =======================
-- ===============================================
nnoremap({"<Leader>fb", "<Leader>b", "<C-p>" }, ":lua require('telescope.builtin').buffers()<Cr>", "silent")
nnoremap({"<Leader>ff", "<Leader>f" }, ":lua require('telescope.builtin').find_files()<Cr>", "silent")
nnoremap({"<Leader>fg", "<Leader>g"}, ":lua require('telescope.builtin').live_grep()<Cr>", "silent")
nnoremap({"<Leader>t"}, ":Telescope<Cr>", "silent")

require('telescope').setup({
  defaults = {
    layout_config = {
      vertical = { width = 0.25 },
      horizontal = { width = 0.5, height = 0.7 },
      -- SEE: :help resolver.resolve_anchor_pos()
      anchor = 'W',
      -- other layout configuration here
    },
    -- other defaults configuration here
  },
  -- other configuration values here
})

