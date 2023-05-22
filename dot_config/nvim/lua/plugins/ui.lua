return {
  -- add gruvbox
  {
    "navarasu/onedark.nvim",
    opts = {
      style = "darker",
    },
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
