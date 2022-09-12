local ok, neogit = pcall(require, "neogit")
if not ok then
  return
end

-- default options for neogit
neogit.setup {}

-- open neogit, on the status panel
vim.keymap.set("n", "<leader>gs", neogit.open)

-- open neogit and commit
vim.keymap.set("n", "<leader>gc", function()
    neogit.open { "commit" } 
end)

-- open tabbed diffs for all the files in the git repository
vim.keymap.set("n", "<space>vv", ":DiffviewOpen<CR>")
