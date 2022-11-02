local M = {
  event = "BufReadPost",
}

function M.config()
  local scrollbar = require("scrollbar")

  scrollbar.setup({})
end

return M
