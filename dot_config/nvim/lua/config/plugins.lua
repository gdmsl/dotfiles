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
  -- LIBS --
  -------------

  -- All the lua functions I don't want to write twice.
  -- https://github.com/nvim-lua/plenary.nvim
  use({ "nvim-lua/plenary.nvim", module = "plenary" })

  -- Neovim plugin to improve the default vim.ui interfaces 
  -- https://github.com/stevearc/dressing.nvim
  use({ "stevearc/dressing.nvim", event = "User PackerDefered" })

  -- UI Component Library for Neovim.
  -- https://github.com/MunifTanjim/nui.nvim
  use({
    "MunifTanjim/nui.nvim",
    module = "nui",
  })

  -----------
  -- NOICE --
  -----------

  -- Highly experimental plugin that completely replaces the UI for messages,
  -- cmdline and the popupmenu.
  -- https://github.com/folke/noice.nvim
  use({
    "folke/noice.nvim",
    requires={"rcarriga/nvim-notify"},
    module = "noice",
    event = "VimEnter",
    config = function()
      require("noice").setup()
    end,
  })

  -- A fancy, configurable, notification manager for NeoVim
  -- https://github.com/rcarriga/nvim-notify
  use({
    "rcarriga/nvim-notify",
    event = "User PackerDefered",
    module="notify",
    config = function()
      require("notify").setup({ level = vim.log.levels.INFO, fps = 20 })
      vim.notify = require("notify")
    end,
  })

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

  -- Sniprun is a code runner plugin for neovim written in Lua and Rust. It
  -- aims to provide stupidly fast partial code testing for interpreted and
  -- compiled languages . Sniprun blurs the line between standard save/run
  -- workflow, jupyter-like notebook, and REPL/interpreters.
  -- https://github.com/michaelb/sniprun
  plugin("michaelb/sniprun")

  -- A completion engine plugin for neovim written in Lua. Completion sources
  -- are installed from external repositories and "sourced".
  -- https://github.com/hrsh7th/nvim-cmp
  plugin("hrsh7th/nvim-cmp")

  -- A Neovim Lua plugin providing access to the SchemaStore catalog.
  -- https://github.com/b0o/SchemaStore.nvim
  use({ "b0o/SchemaStore.nvim", module = "schemastore" })

  -- Use Neovim as a language server to inject LSP diagnostics, code actions,
  -- and more via Lua.
  -- https://github.com/jose-elias-alvarez/null-ls.nvim
  plugin("jose-elias-alvarez/null-ls.nvim")

  ---------------
  -- Languages --
  ---------------

  -- Julia support for Vim.
  -- https://github.com/JuliaEditorSupport/julia-vim
  use({
    "JuliaEditorSupport/julia-vim",
    opt = false,
    config = function()
			vim.g.latex_to_unicode_tab = "off"
		end,})

  -- Plugin for formatting Julia code in (n)vim using `JuliaFormatter.jl`.
  -- https://github.com/kdheepak/JuliaFormatter.vim
  -- `:JuliaFormatterFormat` to use
  -- `:JuliaFormatterUpdate` to update the julia module
  use({"kdheepak/JuliaFormatter.vim", ft = "julia"})

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

  -- Dev setup for init.lua and plugin development with full signature help,
  -- docs and completion for the nvim lua API.
  -- https://github.com/folke/neodev.nvim
  use({ "folke/neodev.nvim", module = "neodev" })

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

  -- Enhanced increment/decrement plugin for Neovim. 
  -- https://github.com/monaqa/dial.nvim
  plugin("monaqa/dial.nvim")


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

  ----------------------
  -- SEARCH AND FUZZY --
  ----------------------

  -- A search panel for neovim.
  -- https://github.com/windwp/nvim-spectre
  use({
    "windwp/nvim-spectre",
    module = "spectre",
  })

  -- `telescope.nvim` is a highly extendable fuzzy finder over lists.
	-- https://github.com/nvim-telescope/telescope.nvim
  plugin("nvim-telescope/telescope.nvim")

  ------------------
  -- HIGHLIGHTING --
  ------------------

  -- Nvim Treesitter configurations and abstraction layer 
  -- https://github.com/nvim-treesitter/nvim-treesitter
  plugin("nvim-treesitter/nvim-treesitter")

  -- View treesitter information directly in Neovim!
  -- https://github.com/nvim-treesitter/playground"
  use({ "nvim-treesitter/playground", cmd = { "TSHighlightCapturesUnderCursor", "TSPlaygroundToggle" } })

  -- Vim plugin for automatically highlighting other uses of the word under the
  -- cursor using either LSP, Tree-sitter, or regex matching.
  -- https://github.com/RRethy/vim-illuminate
  plugin("RRethy/vim-illuminate")

  -- Highlight arguments' definitions and usages, asynchronously, using
  -- Treesitter
  -- https://github.com/m-demare/hlargs.nvim
  -- use({
  --   "m-demare/hlargs.nvim",
  --   disabled = true,
  --   requires = { "nvim-treesitter/nvim-treesitter"},
  --   event = "User PackerDefered",
  --   config = function()
  --     require("hlargs").setup()
  --   end,
  -- })

  -- todo-comments is a lua plugin for Neovim 0.5 to highlight and search for
  -- todo comments like TODO, HACK, BUG in your code base.
  -- https://github.com/folke/todo-comments.nvim
  plugin("folke/todo-comments.nvim")

  -- A high-performance color highlighter for Neovim
  -- https://github.com/norcalli/nvim-colorizer.lua
  plugin("NvChad/nvim-colorizer.lua")

  ---------------
  -- DASHBOARD --
  ---------------

  -- Fancy Fastest Async Start Screen Plugin of Neovim
  -- https://github.com/glepnir/dashboard-nvim
  plugin("glepnir/dashboard-nvim")

  ------------------
  -- UI and THEME --
  ------------------
  --
  -- This plugin adds indentation guides to all lines (including empty lines).
  -- https://github.com/lukas-reineke/indent-blankline.nvim
  plugin("lukas-reineke/indent-blankline.nvim")

  -- A snazzy nail_care buffer line (with tabpage integration) for Neovim built
  -- using lua.
  -- https://github.com/akinsho/nvim-bufferline.lua
  plugin("akinsho/nvim-bufferline.lua")

    -- Extensible Neovim Scrollbar
  -- https://github.com/petertriho/nvim-scrollbar
  plugin("petertriho/nvim-scrollbar")

  -- Automatically expand width of the current window. Maximizes and restore
  -- it. And all this with nice animations! 
  -- https://github.com/anuvyklack/windows.nvim
  plugin("anuvyklack/windows.nvim")

  -- VSCode One Monokai theme written in Lua for Neovim.
  -- https://github.com//cpea2506/one_monokai.nvim
  plugin("cpea2506/one_monokai.nvim")

  ------------
  -- MOTION -- 
  ------------

  -- Neoscroll: a smooth scrolling neovim plugin written in lua
  -- https://github.com/karb94/neoscroll.nvim
  plugin("karb94/neoscroll.nvim")

  -- Hop is an EasyMotion-like plugin allowing you to jump anywhere in a
  -- document with as few keystrokes as possible.
  -- https://github.com/phaazon/hop.nvim
  plugin("phaazon/hop.nvim")

  -- A blazing fast and easy to configure Neovim statusline written in Lua.
  -- https://github.com/nvim-lualine/lualine.nvim
  plugin("nvim-lualine/lualine.nvim")

  -- Show where your cursor moves when jumping large distances (e.g between
  -- windows). Fast and lightweight, written completely in Lua.
  -- https://github.com/edluffy/specs.nvim
  plugin("edluffy/specs.nvim")

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

  ----------------
  -- FOCUS MODE -- 
  ----------------

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

  -----------
  -- Other --
  -----------

  -- A tree like view for symbols in Neovim using the Language Server Protocol.
  -- Supports all your favourite languages.
  -- https://github.com/simrat39/symbols-outline.nvim",
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

  -- bufdelete.nvim aims to fix :bdelete by providing useful commands that
  -- allow you to delete a buffer without messing up your window layout.
  -- https://github.com/famiu/bufdelete.nvim
  use({ "famiu/bufdelete.nvim", cmd = "Bdelete" })


  -- A super powerful autopair plugin for Neovim that supports multiple
  -- characters.
  -- https://github.com/windwp/nvim-autopairs
  plugin("windwp/nvim-autopairs")

  -- Snippet Engine for Neovim written in Lua
  -- https://github.com/L3MON4D3/LuaSnip
  plugin("L3MON4D3/LuaSnip")

  -- Neo-tree is a Neovim plugin to browse the file system and other tree like
  -- structures in whatever style suits you, including sidebars, floating
  -- windows, netrw split style, or all of them at once!
  -- https://nvim-neo-tree/neo-tree.nvim
  plugin("nvim-neo-tree/neo-tree.nvim")



  -- https://github.com/danymat/neogen
  use({
    "danymat/neogen",
    module = "neogen",
    config = function()
      require("neogen").setup({ snippet_engine = "luasnip" })
    end,
  })

  -- Persistence is a simple lua plugin for automated session management.
  -- https://github.com/folke/persistence.nvim
  use({
    "folke/persistence.nvim",
    event = "BufReadPre",
    module = "persistence",
    config = function()
      require("persistence").setup()
    end,
  })

  -- vim-startuptime is a Vim plugin for viewing vim and nvim startup event
  -- timing information. The data is automatically obtained by launching (n)vim
  -- with the `--startuptime` argument. See `:help startuptime-configuration`
  -- for details on customization options.
  -- https://github.com/dstein64/vim-startuptime
  use({
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  })

  -- WhichKey is a lua plugin for Neovim 0.5 that displays a popup with
  -- possible key bindings of the command you started typing.
  -- https://github.com/folke/which-key.nvim
  use({
    "folke/which-key.nvim",
    module = "which-key",
  })

end

return packer.setup(config, plugins)
