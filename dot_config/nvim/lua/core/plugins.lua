return require('packer').startup(function()
    ------------
    -- Packer --
    ------------

    -- https://github.com/wbthomason/packer.nvim
    use 'wbthomason/packer.nvim'

    ---------------
    -- Telescope --
    ---------------

    -- `telescope.nvim` is a highly extendable fuzzy finder over lists.
	-- https://github.com/nvim-telescope/telescope.nvim
    use {
	    'nvim-telescope/telescope.nvim',
	    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
        config = function()
            require("telescope").setup{}
        end,
    }

    -- https://github.com/nvim-telescope/telescope-fzy-native.nvim
    use "nvim-telescope/telescope-fzy-native.nvim"

    -- fzf-native is a c port of fzf. It only covers the algorithm and
    -- implements few functions to support calculating the score.
    -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
    use {
        "nvim-telescope/telescope-fzf-native.nvim",
        run = 'make',
        requires = {{'nvim-telescope/telescope.nvim'},},
        config = function ()
            require("telescope").load_extension("fzf")
        end,
    }

    -- Incorporating fzf into telescope using plenary's job writer
    -- functionality.
    -- https://github.com/nvim-telescope/telescope-fzf-writer.nvim
    use "nvim-telescope/telescope-fzf-writer.nvim"

    -- https://github.com/nvim-telescope/telescope-packer.nvim
    use {
        "nvim-telescope/telescope-packer.nvim",
        requires = {{'nvim-telescope/telescope.nvim'},},
        config = function ()
            require("telescope").load_extension("packer")
        end,
    }

    -- `telescope-symbols` provide its users with the ability of picking
    -- symbols and insert them at point.
    -- https://github.com/nvim-telescope/telescope-symbols.nvim
    use "nvim-telescope/telescope-symbols.nvim"

    -- Search and paste entries from *.bib files with telescope.nvim.
    -- https://github.com/nvim-telescope/telescope-bibtex.nvim
    use {
        "nvim-telescope/telescope-bibtex.nvim",
        requires = {{'nvim-telescope/telescope.nvim'},},
        config = function ()
            require("telescope").load_extension("bibtex")
        end,
    }

    -- An attempt to recreate cheat.sh with lua, neovim, sqlite.lua, and
    -- telescope.nvim.
    -- https://github.com/nvim-telescope/telescope-cheat.nvim
    use {
        "nvim-telescope/telescope-cheat.nvim",
        requires = {{'nvim-telescope/telescope.nvim'},},
        config = function ()
            require("telescope").load_extension("cheat")
        end,
    }

    -- A telescope.nvim extension that offers intelligent prioritization when
    -- selecting files from your editing history.
    -- https://github.com/nvim-telescope/telescope-frecency.nvim
    use "nvim-telescope/telescope-frecency.nvim"

    -- A Neovim Telescope extension for searching the web!
    -- https://github.com/nvim-telescope/telescope-arecibo.nvim
    use {
        "nvim-telescope/telescope-arecibo.nvim",
        rocks = { "openssl", "lua-http-parser" },
        config = function()
            require("telescope").load_extension("arecibo")
        end,
    }

    ----------------
    -- Treesitter --
    ----------------

    -- https://github.com/nvim-treesitter/nvim-treesitter
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    --------------------
    -- Autocompletion --
    --------------------
    use "hrsh7th/nvim-compe"
    
    ---------
    -- LSP --
    ---------

    -- Allows you to manage LSP servers (servers are installed inside :echo
    -- stdpath("data") by default). It works in tandem with `lspconfig`.
    -- https://github.com/williamboman/nvim-lsp-installer
    --
    use "williamboman/nvim-lsp-installer"

    -- A collection of common configurations for Neovim's built-in language
    -- server client.
    -- https://github.com/neovim/nvim-lspconfig
    use "neovim/nvim-lspconfig"

    -- This is a Neovim plugin/library for generating statusline components
    -- from the built-in LSP client.
    -- https://github.com/wbthomason/lsp-status.nvim
    use "wbthomason/lsp-status.nvim"

    -- Standalone UI for nvim-lsp progress
    -- https://github.com/j-hui/fidget.nvim
    use "j-hui/fidget.nvim"

    -- This tiny plugin adds vscode-like pictograms to neovim built-in lsp.
    -- https://github.com/onsails/lspkind-nvim
    use "onsails/lspkind-nvim"

    -- https://github.com/folke/trouble.nvim
    use {
      "folke/trouble.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
        require("trouble").setup {}
      end
    }

    ---------------
    -- Languages --
    ---------------

    -- Julia support for Vim.
    -- https://github.com/JuliaEditorSupport/julia-vim
    use "JuliaEditorSupport/julia-vim"

    -- Plugin for formatting Julia code in (n)vim using `JuliaFormatter.jl`.
    -- https://github.com/kdheepak/JuliaFormatter.vim
    -- `:JuliaFormatterFormat` to use
    -- `:JuliaFormatterUpdate` to update the julia module
    use "kdheepak/JuliaFormatter.vim"

    -----------------------
    -- Text Manipulation --
    -----------------------

    -- Quickly align text vertically
    -- https://github.com/godlygeek/tabular
    use "godlygeek/tabular"

    -- Repeat.vim remaps `.` in a way that plugins can tap into it.
    -- https://github.com/tpope/vim-repeat
    use "tpope/vim-repeat"

    -- Modernize `ga` to show many more information about the hovered
    -- character.
    -- https://github.com/tpope/vim-characterize
    use "tpope/vim-characterize"

    -- Make synchronous VIM compiler plugins asynchronous
    -- https://github.com/tpope/vim-dispatch
    use { "tpope/vim-dispatch", cmd = { "Dispatch", "Make" } }

    -- Smart and Powerful commenting plugin for neovim
    -- `gcc` for line comments `gbc` for block ones
    -- https://github.com/numToStr/Comment.nvim
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }

    -- Simplifies switching between a single-line statement and a multi-line
    -- one with `gS` and `gJ`.
    -- https://github.com/AndrewRadev/splitjoin.vim
    use {
      "AndrewRadev/splitjoin.vim",
      keys = { "gJ", "gS" },
    }

    -- `sandwich.vim` is a set of operator and textobject plugins to
    -- add/delete/replace surroundings of a sandwiched textobject.
    -- Examples:
    -- saiw( : foo -> (foo)
    -- sd( : (foo) -> foo
    -- sdb : (foo) -> foo
    -- https://github.com/machakann/vim-sandwich
    use "machakann/vim-sandwich"

    ---------
    -- Git --
    ---------

    -- Magit clone for Neovim that is geared toward the Vim philosophy
    -- https://github.com/TimUntersberger/neogit
    -- `:Neogit` to open
    use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }

    -- More pleasant editing on commit message
    -- https://github.com/rhysd/committia.vim
    use "rhysd/committia.vim"

    -- Reveals the hidden message from Git under the cursor quickly. It shows
    -- the history of commits under the cursor in popup window.
    -- Usage:
    -- Only one mapping (or one command) provides all features of this plugin.
    -- Briefly, move cursor to the position and run `:GitMessenger` or
    -- `<Leader>gm`
    -- https://github.com/rhysd/git-messenger.vim
    use "rhysd/git-messenger.vim"

    -- https://github.com/sindrets/diffview.nvim
    use {
        'sindrets/diffview.nvim',
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            require('diffview').setup {}
        end,
    }

    --------------
    -- Spelling -- 
    --------------

    -- Cycles spelling suggestions under the cursor.
    -- https://github.com/tweekmonster/spellrotate.vim
    use "tweekmonster/spellrotate.vim"

    -- Colorscheme
    -- use "glepnir/zephyr-nvim"
    use 'Mofiqul/adwaita.nvim'
   
    -- A high-performance color highlighter for Neovim
    -- https://github.com/norcalli/nvim-colorizer.lua
    use {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    }

    -- A high performance filetype mode for Neovim which leverages conceal and
    -- highlights your buffer with the correct color codes.
    -- https://github.com/norcalli/nvim-terminal.lua
    use {
      "norcalli/nvim-terminal.lua",
      config = function()
        require("terminal").setup()
      end,
    }

    -----------
    -- Icons --
    -----------

    -- https://github.com/kyazdani42/nvim-web-devicons
    -- https://github.com/yamatsum/nvim-nonicons
    use {
      'yamatsum/nvim-nonicons',
      requires = {'kyazdani42/nvim-web-devicons'}
    }

    -----------------
    -- Status Line --
    -----------------

    -- galaxyline is a light-weight and Super Fast statusline plugin
    -- https://github.com/glepnir/galaxyline.nvim
    use 'glepnir/galaxyline.nvim'

    -----------
    -- Other --
    -----------

    -- Lua Development for Neovim
    -- https://github.com/tjdevries/nlua.nvim
    --use 'tjdevries/nlua.nvim'

    -- Clipboard manager for neovim
    -- https://github.com/AckslD/nvim-neoclip.lua
    use {
      "AckslD/nvim-neoclip.lua",
      requires = {
        {'tami5/sqlite.lua', module = 'sqlite'},
        {'nvim-telescope/telescope.nvim'},
      },
      config = function()
        require('neoclip').setup()
      end,
    }

    -- https://github.com/rcarriga/nvim-notify
    use "rcarriga/nvim-notify"

    -- Cool tags based viewer
    -- :Vista  <-- Opens up a really cool sidebar with info about file.
    use { "liuchengxu/vista.vim", cmd = "Vista" }

end)
