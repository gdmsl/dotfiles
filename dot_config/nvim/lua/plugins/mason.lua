return {
  -- `vim.tbl_deep_extend` can only merge table and not list
  -- so we have to do this to add our languages to the list
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        ensure_installed = {
          "clang-format",
          "clangd",
          "julia-lsp",
          "rustfmt",
          "shellcheck",
          "shfmt",
        },
      })
    end,
  },
}
