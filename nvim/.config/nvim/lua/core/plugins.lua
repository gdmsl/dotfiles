return require('packer').startup(function()
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Astronauta
    use  'tjdevries/astronauta.nvim'

    -- Telescope
    use {
	    'nvim-telescope/telescope.nvim',
	    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
    }
    use "nvim-telescope/telescope-fzy-native.nvim"
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use "nvim-telescope/telescope-fzf-writer.nvim"
    use "nvim-telescope/telescope-packer.nvim"
    use "nvim-telescope/telescope-symbols.nvim"
    use "nvim-telescope/telescope-bibtex.nvim"

    use "tami5/sql.nvim"
    use "nvim-telescope/telescope-cheat.nvim"
    use "nvim-telescope/telescope-frecency.nvim"
    use { "nvim-telescope/telescope-arecibo.nvim", rocks = { "openssl", "lua-http-parser" } }

    -- Treesitter
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    -- Autocompletion
    use "hrsh7th/nvim-compe"
    
    -- LSP
    use "neovim/nvim-lspconfig"
    use "wbthomason/lsp-status.nvim"
    use "glepnir/lspsaga.nvim"
    use "onsails/lspkind-nvim"

    -- Languages
    use "JuliaEditorSupport/julia-vim"

    -- Git
    use "TimUntersberger/neogit"
    use "rhysd/committia.vim"
    use "rhysd/git-messenger.vim"

    -- Colorscheme
    use "glepnir/zephyr-nvim"

    -- Icons
    use "kyazdani42/nvim-web-devicons"
    use "yamatsum/nvim-web-nonicons"

    -- Line
    use 'glepnir/galaxyline.nvim'

    -- Lua
    use 'tjdevries/nlua.nvim'

end)
