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
        "rustfmt",
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
    --opts = function(_, opts)
    --  vim.list_extend(opts.ensure_installed, {
    --    ensure_installed = {
    --      "clang-format",
    --      "clangd",
    --      "julia-lsp",
    --      "rustfmt",
    --      "shellcheck",
    --      "shfmt",
    --    },
    --  })
    --end,
  },
}
