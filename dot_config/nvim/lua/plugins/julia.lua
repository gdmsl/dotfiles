return {
  {
    -- https://github.com/JuliaEditorSupport/julia-vim
    -- Julia support for Vim.
    -- {
    --   "JuliaEditorSupport/julia-vim",
    --   opt = false,
    --   config = function()
    --     vim.g.latex_to_unicode_tab = "off"
    --   end,
    -- },

    -- https://github.com/kdheepak/JuliaFormatter.vim
    -- Plugin for formatting Julia code in (n)vim using `JuliaFormatter.jl`.
    -- `:JuliaFormatterFormat` to use
    -- `:JuliaFormatterUpdate` to update the julia module
    {
      "kdheepak/JuliaFormatter.vim",
      ft = "julia",
    },
  },
}
