local has_lsp, lspconfig = pcall(require, "lspconfig")
if not has_lsp then
    return 
end

local lsp_status = require "lsp-status"
require("core.lsp.status").activate()

_ = require("lspkind").init()

local mapper = function(mode, key, result)
  vim.api.nvim_buf_set_keymap(0, mode, key, "<cmd>lua " .. result .. "<CR>", { noremap = true, silent = true })
end

local nvim_exec = function(txt)
    vim.api.nvim_exec(txt, false)
end

local on_init = function(client)
    client.config.flags = client.config.flags or {}
    client.config.flags.allow_incremental_sync = true
end

local on_attach = function(client)
    local filetype = vim.api.nvim_buf_get_option(0, "filetype")

    lsp_status.on_attach(client)

    vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

    mapper('n', 'gD', 'vim.lsp.buf.declaration()')
    mapper('n', 'gd', 'vim.lsp.buf.definition()')
    mapper('n', 'K', 'vim.lsp.buf.hover()')
    mapper('n', 'gi', 'vim.lsp.buf.implementation()')
    mapper('n', '<C-k>', 'vim.lsp.buf.signature_help()')
    mapper('n', '<space>wa', 'vim.lsp.buf.add_workspace_folder()')
    mapper('n', '<space>wr', 'vim.lsp.buf.remove_workspace_folder()')
    mapper('n', '<space>wl', 'print(vim.inspect(vim.lsp.buf.list_workspace_folders()))')
    mapper('n', '<space>D', 'vim.lsp.buf.type_definition()')
    mapper('n', '<space>rn', 'vim.lsp.buf.rename()')
    mapper('n', '<space>ca', 'vim.lsp.buf.code_action()')
    mapper('n', 'gr', 'vim.lsp.buf.references()')
    mapper('n', '<space>e', 'vim.lsp.diagnostic.show_line_diagnostics()')
    mapper('n', '[d', 'vim.lsp.diagnostic.goto_prev()')
    mapper('n', ']d', 'vim.lsp.diagnostic.goto_next()')
    mapper('n', '<space>q', 'vim.lsp.diagnostic.set_loclist()')
    mapper('n', '<space>f', 'vim.lsp.buf.formatting()')

    -- Set autocommands conditional on server_capabilities
    if client.resolved_capabilities.document_highlight then
        nvim_exec [[
            augroup lsp_document_highlight
                autocmd! * <buffer>
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
        ]]
    end
end

local servers = { 'clangd', 'texlab' , 'julials', 'cmake', 'sumneko_lua', 'bashls', 'jedi_language_server', 'rome'}

require("nvim-lsp-installer").setup {
    -- ensure these servers are always installed
    ensure_installed = servers,
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

for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup { on_init = on_init, on_attach = on_attach }
end

