-- vim.g.clipboard = {
--     name = 'myClipboard',
--     copy = {
--         ["+"] = {'tmux', 'load-buffer', '-'},
--         ["*"] = {'tmux', 'load-buffer', '-'},
--     },
--     paste = {
--         ["+"] = {'tmux', 'save-buffer', '-'},
--         ["*"] = {'tmux', 'save-buffer', '-'},
--     },
--     cache_enabled = true,
-- }

-- bootstrap lazy.nvim, LazyVim and your plugin
require("config.lazy")
