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

    -- Treesitter
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    -- Autocompletion
    use "hrsh7th/nvim-compe"
    
    -- LSP
    use "neovim/nvim-lspconfig"
    use "wbthomason/lsp-status.nvim"

    -- Colorscheme
    use "glepnir/zephyr-nvim"
end)
