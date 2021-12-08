-- " ------------------------------------------------
-- " ------------------------------------------------
-- " ------------------------------------------------
-- " Find files using Telescope command-line sugar.
-- " Using Lua functions
-- " nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
-- " nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
-- " nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
-- " nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

print("plugins/configs/telescope-nvim.lua...")

-- FROM: https://github.com/nvim-telescope/telescope.nvim#customization
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        ["<C-/>"] = require('telescope.builtin').buffers,
        ["<Leader>b"] = require('telescope.builtin').buffers,
        ["<Leader>e"] = 'telescope.builtin.buffers',

        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        -- ["<C-h>"] = "which_key"
      }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   etension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}
