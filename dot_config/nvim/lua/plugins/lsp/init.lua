local M = {
  requires = {'folke/neodev.nvim'},
  event = "BufReadPre",
}

function M.config()
  require("neodev").setup({})
  require("mason")
  require("plugins.lsp.diagnostics").setup()
  require("plugins.lsp.handlers").setup()

  ---@type lspconfig.options
  local servers = {
    ansiblels = {},
    bashls = {},
    clangd = {},
    cssls = {},
    dockerls = {},
    tsserver = {},
    eslint = {},
    html = {},
    julials = {},
    jsonls = {
      settings = {
        json = {
          format = {
            enable = true,
          },
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    },
    marksman = {},
    pyright = {},
    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
          checkOnSave = {
            command = "clippy",
            extraArgs = { "--no-deps" },
          },
        },
      },
    },
    sumneko_lua = {
      single_file_support = true,
      settings = {
        Lua = {
          workspace = {
            checkThirdParty = false,
          },
          completion = {
            workspaceWord = true,
          },
          misc = {
            parameters = {
              "--log-level=trace",
            },
          },
          diagnostics = {
            unusedLocalExclude = { "_*" },
          },
          format = {
            enable = false,
            defaultConfig = {
              indent_style = "space",
              indent_size = "2",
              continuation_indent_size = "2",
            },
          },
        },
      },
    },
    teal_ls = {},
    vimls = {},
    -- tailwindcss = {},
  }

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  ---@type _.lspconfig.options
  local options = {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150,
    },
  }

  for server, opts in pairs(servers) do
    opts = vim.tbl_deep_extend("force", {}, options, opts or {})
    -- if server == "tsserver" then
    --   require("typescript").setup({ server = opts })
    -- else
    --  require("lspconfig")[server].setup(opts)
    -- end
    require("lspconfig")[server].setup(opts)
  end

  require("plugins.null-ls").setup(options)
end

return M
