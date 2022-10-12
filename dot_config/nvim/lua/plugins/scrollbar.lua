local M = {
  event = "BufReadPost",
}

function M.config()
  local scrollbar = require("scrollbar")

  --- PERF: throttle scrollbar refresh
  local render = scrollbar.render
  scrollbar.render = require("util").throttle(300, render)
  scrollbar.setup({})
end

return M
