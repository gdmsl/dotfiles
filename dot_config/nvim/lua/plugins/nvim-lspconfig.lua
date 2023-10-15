return {
  "neovim/nvim-lspconfig",

  ---@class PluginLspOpts
  opts = {
    servers = {
      clangd = { filetypes = { "c", "cpp", "objc", "objcpp", "cuda" } },
    },
  },
}
