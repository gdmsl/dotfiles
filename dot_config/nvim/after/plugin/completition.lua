vim.opt.completeopt = { "menuone", "noselect" }

-- Don't show dumb matching stuff.
vim.cmd [[set shortmess+=c]]

local has_compe, compe = pcall(require, "compe")
if has_compe then
    compe.setup {
        enabled = true,
        autocomplete = true,
        debug = false,
        min_length = 1,
        preselect= "enable",
        throttle_time = 200,
        source_timeout = 200,
        incomplete_delay = 400,
        allow_prefix_unmatch = false,

        source = {
            path = true,
            buffer = true,
            calc = false,
            vsnip = true,
            nvim_lsp = true,
            nvim_lua = true,
            spell = true,
            tags = true,
            treesitter = false,
            snippets_nvim = true,
        },
    }
end
