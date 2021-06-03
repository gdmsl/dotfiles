local has_lsp, lspconfig = pcall(require, "lspconfig")
if not has_lsp then
    return 
end

local lsp_status = require "lsp-status"
require("core.lsp.status").activate()

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

local servers = { 'clangd', 'texlab' , 'julials' }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup { on_init = oninit, on_attach = on_attach }
end
