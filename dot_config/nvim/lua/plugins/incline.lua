local M = {
  event = "BufReadPre",
  require = { "kyazdani42/nvim-web-devicons" },
}

function M.config()
  require("incline").setup({
    highlight = {
      groups = {
        InclineNormal = {
          guibg = "#FC56B1",
          guifg = "#1E2024",
          -- gui = "bold",
        },
        InclineNormalNC = {
          guifg = "#FC56B1",
          guibg = "#1E2024",
        },
      },
    },
    window = {
      margin = {
        vertical = 0,
        horizontal = 1,
      },
    },
    render = function(props)
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
      local icon, color = require("nvim-web-devicons").get_icon_color(filename)
      return {
        { icon, guifg = color },
        { " " },
        { filename },
      }
    end,
  })
end

return M
