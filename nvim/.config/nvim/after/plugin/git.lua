local neogit = require "neogit"

neogit.setup {}
vim.keymap.set("n", "<leader>gs", neogit.open)
vim.keymap.set("n", "<leader>gc", function()
    neogit.open { "commit"} 
end)

vim.keymap.set("n", "<space>vv", ":DiffviewOpen<CR>")
