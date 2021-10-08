local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  return
end

local nnoremap = vim.keymap.nnoremap

local mapper = function(mode, key, result)
  vim.api.nvim_buf_set_keymap(0, mode, key, "<cmd>lua " .. result .. "<CR>", { noremap = true, silent = true })
end

mapper('n', '<leader>ff', "require('telescope.builtin').find_files()")
mapper('n', '<leader>fg', "require('telescope.builtin').live_grep()")
mapper('n', '<leader>fb', "require('telescope.builtin').buffers()")
mapper('n', '<leader>fh', "require('telescope.builtin').help_tags()")
