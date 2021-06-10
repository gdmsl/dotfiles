local nnoremap = vim.keymap.nnoremap

local neogit = require "neogit"

neogit.setup {}

nnoremap { "<leader>gs", neogit.open }
nnoremap { "<leader>gc", function()
  neogit.open { "commit" }
end }
