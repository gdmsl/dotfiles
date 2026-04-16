return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- Parsers are provided by Nix (nvim-treesitter.withAllGrammars)
      auto_install = false,
      ensure_installed = {},
    },
  },
}
