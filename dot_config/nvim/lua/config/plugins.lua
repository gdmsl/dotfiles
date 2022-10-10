local packer = require("util.packer")

local config = {
  profile = {
    enable = true,
    threshold = 0, -- the amount in ms that a plugins load time must be over for it to be included in the profile
  },
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "single" })
    end,
  },
  opt_default = true,
  auto_reload_compiled = false,
  -- list of plugins that should be taken from ~/projects
  -- this is NOT packer functionality!
  local_plugins = {
    folke = false,
    -- ["null-ls.nvim"] = true,
    -- ["nvim-lspconfig"] = true,
    -- ["nvim-notify"] = true,
    -- ["windows.nvim"] = true,
    -- ["nvim-treesitter"] = true,
  },
}

local function plugins(use, plugin)

  ------------
  -- Packer --
  ------------

  -- https://github.com/wbthomason/packer.nvim
  use('wbthomason/packer.nvim')

  -------------
  -- PLENARY --
  -------------
  use({ "nvim-lua/plenary.nvim", module = "plenary" })

  -----------
  -- NOICE --
  -----------

  use({
    "folke/noice.nvim",
    module = "noice",
    event = "VimEnter",
    config = function()
      require("noice").setup()
    end,
  })

  use({ "stevearc/dressing.nvim", event = "User PackerDefered" })

  use({
    "rcarriga/nvim-notify",
    event = "User PackerDefered",
    config = function()
      require("notify").setup({ level = vim.log.levels.INFO, fps = 20 })
      vim.notify = require("notify")
    end,
  })

  use({ "b0o/SchemaStore.nvim", module = "schemastore" })

  plugin("jose-elias-alvarez/null-ls.nvim")

  use({ "folke/lua-dev.nvim", module = "lua-dev" })

  plugin("anuvyklack/windows.nvim")

  plugin("monaqa/dial.nvim")

  ---------------------
  -- MASON, LSP, DAP --
  ---------------------

  -- Portable package manager for Neovim that runs everywhere Neovim runs.
  -- Easily install and manage LSP servers, DAP servers, linters, and
  -- formatters.
  -- :help mason.nvim
  -- https://github.com/williamboman/mason.nvim
  plugin("williamboman/mason.nvim")

  -- mason-lspconfig bridges mason.nvim with the lspconfig plugin - making it
  -- easier to use both plugins together.
  -- :help mason-lspconfig.nvim 
  -- https://github.com/williamboman/mason-lspconfig.nvim
  use({
    "williamboman/mason-lspconfig.nvim",
    module = "mason-lspconfig",
  })
  --
  -- nvim-dap is a Debug Adapter Protocol client implementation for Neovim.
  -- https://github.com/mfussenegger/nvim-dap
  plugin("mfussenegger/nvim-dap")

  -- Configs for the Nvim LSP client (:help lsp).
  -- https://github.com/neovim/nvim-lspconfig
  use({ "neovim/nvim-lspconfig", plugin = "lsp" })

  -- Standalone UI for nvim-lsp progress
  -- https://github.com/j-hui/fidget.nvim
  use({
    "j-hui/fidget.nvim",
    module = "fidget",
    config = function()
      require("fidget").setup({
        window = {
          relative = "editor",
        },
      })
      -- HACK: prevent error when exiting Neovim
      vim.api.nvim_create_autocmd("VimLeavePre", { command = [[silent! FidgetClose]] })
    end,
  })

  -- This tiny plugin adds vscode-like pictograms to neovim built-in lsp.
  -- https://github.com/onsails/lspkind-nvim
  use("onsails/lspkind-nvim")

  -- A pretty list for showing diagnostics, references, telescope results,
  -- quickfix and location lists to help you solve all the trouble your code is
  -- causing.
  -- https://github.com/folke/trouble.nvim
  use({
    "folke/trouble.nvim",
    event = "BufReadPre",
    module = "trouble",
    cmd = { "TroubleToggle", "Trouble" },
    config = function()
      require("trouble").setup({
        auto_open = false,
        use_diagnostic_signs = true, -- en
      })
    end,
  })

  -- A simple statusline/winbar component that uses LSP to show your current
  -- code context. Named after the Indian satellite navigation system.
  -- https://github.com/SmiteshP/nvim-navic
  use({
    "SmiteshP/nvim-navic",
    module = "nvim-navic",
    config = function()
      vim.g.navic_silence = true
      require("nvim-navic").setup({ separator = " ", highlight = true, depth_limit = 5 })
    end,
  })

  ---------------
  -- Languages --
  ---------------

  -- Julia support for Vim.
  -- https://github.com/JuliaEditorSupport/julia-vim
  use("JuliaEditorSupport/julia-vim")

  -- Plugin for formatting Julia code in (n)vim using `JuliaFormatter.jl`.
  -- https://github.com/kdheepak/JuliaFormatter.vim
  -- `:JuliaFormatterFormat` to use
  -- `:JuliaFormatterUpdate` to update the julia module
  use("kdheepak/JuliaFormatter.vim")

  --A plugin to improve your rust experience in neovim.
  -- https://github.com/simrat39/rust-tools.nvim
  plugin("simrat39/rust-tools.nvim")


  -- Markdown Preview for (Neo)vim
  -- :MarkdownPreview to open in the browser
  -- https://github.com/iamcco/markdown-preview.nvim
  use({
    "iamcco/markdown-preview.nvim",
    run = function()
      vim.fn["mkdp#util#install"]()
    end,
    ft = "markdown",
    cmd = { "MarkdownPreview" },
  })

  -----------------------
  -- Text Manipulation --
  -----------------------

  -- Quickly align text vertically
  -- https://github.com/godlygeek/tabular
  use("godlygeek/tabular")

  -- Repeat.vim remaps `.` in a way that plugins can tap into it.
  -- https://github.com/tpope/vim-repeat
  use("tpope/vim-repeat")

  -- Modernize `ga` to show many more information about the hovered
  -- character.
  -- https://github.com/tpope/vim-characterize
  use("tpope/vim-characterize")

  -- Make synchronous VIM compiler plugins asynchronous
  -- https://github.com/tpope/vim-dispatch
  use({ "tpope/vim-dispatch", cmd = { "Dispatch", "Make" } })

  -- Smart and Powerful commenting plugin for neovim
  -- `gcc` for line comments `gbc` for block ones
  -- https://github.com/numToStr/Comment.nvim
  plugin("numToStr/Comment.nvim")

  -- Simplifies switching between a single-line statement and a multi-line
  -- one with `gS` and `gJ`.
  -- https://github.com/AndrewRadev/splitjoin.vim
  use({
    "AndrewRadev/splitjoin.vim",
    keys = { "gJ", "gS" },
  })

  -- Surround selections, stylishly sunglasses
  -- :h nvim-surround.usage
  -- https://github.com/kylechui/nvim-surround
  use({
    "kylechui/nvim-surround",
    event = "BufReadPre",
    config = function()
      require("nvim-surround").setup({})
    end,
  })

  -- match-up is a plugin that lets you highlight, navigate, and operate on
  -- sets of matching text. It extends vim's % key to language-specific words
  -- instead of just single characters.
  use({
    "andymass/vim-matchup",
    event = "BufReadPost",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
    end,
  })

  ---------
  -- Git --
  ---------

  -- Magit clone for Neovim that is geared toward the Vim philosophy
  -- https://github.com/TimUntersberger/neogit
  -- `:Neogit` to open
  plugin("TimUntersberger/neogit")

  -- https://github.com/lewis6991/gitsigns.nvim
  plugin("lewis6991/gitsigns.nvim")

  -- More pleasant editing on commit message
  -- https://github.com/rhysd/committia.vim
  use("rhysd/committia.vim")

  -- Reveals the hidden message from Git under the cursor quickly. It shows
  -- the history of commits under the cursor in popup window.
  -- Usage:
  -- Only one mapping (or one command) provides all features of this plugin.
  -- Briefly, move cursor to the position and run `:GitMessenger` or
  -- `<Leader>gm`
  -- https://github.com/rhysd/git-messenger.vim
  use("rhysd/git-messenger.vim")

  -- https://github.com/sindrets/diffview.nvim
  plugin("sindrets/diffview.nvim")

  --------------
  -- Spelling -- 
  --------------

  -- Cycles spelling suggestions under the cursor.
  -- https://github.com/tweekmonster/spellrotate.vim
  use("tweekmonster/spellrotate.vim")

  -- Colorscheme
  -- use "glepnir/zephyr-nvim"
  use('Mofiqul/adwaita.nvim')
  
  -- A high-performance color highlighter for Neovim
  -- https://github.com/norcalli/nvim-colorizer.lua
  plugin("NvChad/nvim-colorizer.lua")

  -- A high performance filetype mode for Neovim which leverages conceal and
  -- highlights your buffer with the correct color codes.
  -- https://github.com/norcalli/nvim-terminal.lua
  use({
    "norcalli/nvim-terminal.lua",
    ft = "terminal",
    config = function()
      require("terminal").setup()
    end,
  })

  plugin("akinsho/nvim-toggleterm.lua")

  -----------
  -- Icons --
  -----------

  -- https://github.com/kyazdani42/nvim-web-devicons
  -- https://github.com/yamatsum/nvim-nonicons
  use({
    'yamatsum/nvim-nonicons',
    requires = {'kyazdani42/nvim-web-devicons'}
  })

  ---------------
  -- Telescope --
  ---------------

  -- `telescope.nvim` is a highly extendable fuzzy finder over lists.
	-- https://github.com/nvim-telescope/telescope.nvim
  plugin("nvim-telescope/telescope.nvim")

  ----------------
  -- Treesitter --
  ----------------

  -- https://github.com/nvim-treesitter/nvim-treesitter
  plugin("nvim-treesitter/nvim-treesitter")

  use({ "nvim-treesitter/playground", cmd = { "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle" } })

  -----------
  -- Other --
  -----------

  -- Cool tags based viewer
  -- :Vista  <-- Opens up a really cool sidebar with info about file.
  use { "liuchengxu/vista.vim", cmd = "Vista" }

  use({
    "AckslD/nvim-neoclip.lua",
    event = "TextYankPost",
    module = "telescope._extensions.neoclip",
    requires = { { "kkharji/sqlite.lua", module = "sqlite" } },
    config = function()
      require("neoclip").setup({
        enable_persistent_history = true,
        continuous_sync = true,
      })
    end,
  })

  -- Neorg (Neo - new, org - organization) is a tool designed to reimagine
  -- organization as you know it. Grab some coffee, start writing some notes,
  -- let your editor handle the rest.
  -- https://github.com/nvim-neorg/neorg
  plugin("nvim-neorg/neorg")


  use({ "famiu/bufdelete.nvim", cmd = "Bdelete" })

  plugin("petertriho/nvim-scrollbar")

  plugin("hrsh7th/nvim-cmp")

  plugin("windwp/nvim-autopairs")

  plugin("L3MON4D3/LuaSnip")


  use({
    "simrat39/symbols-outline.nvim",
    cmd = { "SymbolsOutline" },
    config = function()
      require("symbols-outline").setup()
    end,
    setup = function()
      vim.keymap.set("n", "<leader>cs", "<cmd>SymbolsOutline<cr>", { desc = "Symbols Outline" })
    end,
  })


  plugin("nvim-neo-tree/neo-tree.nvim")

  use({
    "MunifTanjim/nui.nvim",
    module = "nui",
  })

  use({
    "danymat/neogen",
    module = "neogen",
    config = function()
      require("neogen").setup({ snippet_engine = "luasnip" })
    end,
  })


  -- Highlight arguments' definitions and usages, asynchronously, using
  -- Treesitter
  -- https://github.com/m-demare/hlargs.nvim
  use({
    "m-demare/hlargs.nvim",
    event = "User PackerDefered",
    config = function()
      require("hlargs").setup({
        -- color = require("tokyonight.colors").setup().yellow,
      })
    end,
  })


  -- Dashboard
  plugin("glepnir/dashboard-nvim")


  use({
    "windwp/nvim-spectre",
    module = "spectre",
  })


  plugin("lukas-reineke/indent-blankline.nvim")
  plugin("akinsho/nvim-bufferline.lua")

  -- Smooth Scrolling
  plugin("karb94/neoscroll.nvim")

  plugin("edluffy/specs.nvim")

  plugin("michaelb/sniprun")


  -- A blazing fast and easy to configure Neovim statusline written in Lua.
  -- https://github.com/nvim-lualine/lualine.nvim
  plugin("nvim-lualine/lualine.nvim")


  -- plugin("kevinhwang91/nvim-ufo")


  plugin("phaazon/hop.nvim")

  use({
    "folke/persistence.nvim",
    event = "BufReadPre",
    module = "persistence",
    config = function()
      require("persistence").setup()
    end,
  })

  use({
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  })

  -- Twilight is a Lua plugin for Neovim 0.5 that dims inactive portions of the
  -- code you're editing.
  -- :Twilight to toggle
  -- https://github.com/folke/twilight.nvim
  use({ "folke/twilight.nvim", module = "twilight" })

  -- Distraction-free coding for Neovim >= 0.5
  -- https://github.com/folke/zen-mode.nvim
  use({
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    config = function()
      require("zen-mode").setup({
        plugins = { gitsigns = true, tmux = true, kitty = { enabled = false, font = "+2" } },
      })
    end,
  })

  -- todo-comments is a lua plugin for Neovim 0.5 to highlight and search for
  -- todo comments like TODO, HACK, BUG in your code base.
  -- https://github.com/folke/todo-comments.nvim
  plugin("folke/todo-comments.nvim")


  -- WhichKey is a lua plugin for Neovim 0.5 that displays a popup with
  -- possible key bindings of the command you started typing.
  -- https://github.com/folke/which-key.nvim
  use({
    "folke/which-key.nvim",
    module = "which-key",
  })

  -- Vim plugin for automatically highlighting other uses of the word under the
  -- cursor using either LSP, Tree-sitter, or regex matching.
  -- https://github.com/RRethy/vim-illuminate
  plugin("RRethy/vim-illuminate")

end

return packer.setup(config, plugins)
