return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Parsers are provided by Nix (nvim-treesitter.withAllGrammars)
    build = false,
    opts = {
      auto_install = false,
      ensure_installed = {},
    },
  },
}
