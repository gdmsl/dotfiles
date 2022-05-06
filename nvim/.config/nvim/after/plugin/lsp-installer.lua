require("nvim-lsp-installer").setup {
    -- ensure these servers are always installed
    ensure_installed = { 'clangd', 'bashls', 'sumneko_lua', 'julials', 'texlab', 'remark_ls', 'rome', 'jedi_language_server', 'cmake' },
    -- automatically detect which servers to install (based on which servers are set up via lspconfig)
    automatic_installation = true,
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
}

