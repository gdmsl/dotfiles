return {
  opt = false,
  config = function()
    -- vim.o.background = "dark"
    local onemonokai= require("one_monokai")
    onemonokai.setup({
      use_cmd = true,
    })
  end,
}
