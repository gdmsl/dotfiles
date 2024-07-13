return {
  -- `vim.tbl_deep_extend` can only merge table and not list
  -- so we have to do this to add our languages to the list
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "clang-format",
        "julia-lsp",
        "rust-analyzer",
        "shellcheck",
        "stylua",
        "lua-language-server",
        "bash-language-server",
        "cmake-language-server",
        "shfmt",
        "texlab",
        "latexindent",
      },
    },
  },
}
