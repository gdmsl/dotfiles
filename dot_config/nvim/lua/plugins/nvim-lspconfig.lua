return {
  "neovim/nvim-lspconfig",

  ---@class PluginLspOpts
  opts = {
    servers = {
      clangd = {
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        cmd = {
          "clangd",
          "--offset-encoding=utf-16",
        },
      },
    },
  },
}
