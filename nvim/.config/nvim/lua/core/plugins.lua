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
    use "nvim-telescope/telescope-packer.nvim"

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
end)
