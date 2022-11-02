local M = {
  cmd = { "Telescope" },
  module = "telescope",
  requires = {
    { "nvim-telescope/telescope-file-browser.nvim", module = "telescope._extensions.file_browser" },
    { "nvim-telescope/telescope-z.nvim", module = "telescope._extensions.z" },
    { "nvim-telescope/telescope-symbols.nvim", module = "telescope._extensions.symbols" },
    { "nvim-telescope/telescope-fzf-native.nvim", module = "telescope._extensions.fzf", run = "make" },
  },
}

function M.project_files(opts)
  opts = opts or {}
  opts.show_untracked = true
  if vim.loop.fs_stat(".git") then
    require("telescope.builtin").git_files(opts)
  else
    local client = vim.lsp.get_active_clients()[1]
    if client then
      opts.cwd = client.config.root_dir
    end
    require("telescope.builtin").find_files(opts)
  end
end

function M.config()
  -- local actions = require("telescope.actions")
  local trouble = require("trouble.providers.telescope")

  local telescope = require("telescope")
  local borderless = true
  telescope.setup({
    extensions = {
      -- fzf = {
      --   fuzzy = true, -- false will only do exact matching
      --   override_generic_sorter = true, -- override the generic sorter
      --   override_file_sorter = true, -- override the file sorter
      --   case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      --   -- the default case_mode is "smart_case"
      -- },
    },
    defaults = {
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
      },
      sorting_strategy = "ascending",
      mappings = {
        i = {
          ["<c-t>"] = trouble.open_with_trouble,
          ["<c-Down>"] = require("telescope.actions").cycle_history_next,
          ["<c-Up>"] = require("telescope.actions").cycle_history_prev,
        }
      },
      prompt_prefix = " ",
      selection_caret = " ",
      winblend = borderless and 0 or 10,
    },
  })

  -- telescope.load_extension("frecency")
  telescope.load_extension("fzf")
  telescope.load_extension("z")
  telescope.load_extension("file_browser")
  telescope.load_extension("neoclip")
  -- telescope.load_extension("project")
end

function M.init()
  vim.keymap.set("n", "<leader><space>", function()
    require("plugins.telescope").project_files()
  end, { desc = "Find File" })

  vim.keymap.set("n", "<leader>fd", function()
    require("telescope.builtin").git_files({ cwd = "~/dot" })
  end, { desc = "Find Dot File" })

  vim.keymap.set("n", "<leader>fz", function()
    require("telescope").extensions.z.list({ cmd = { vim.o.shell, "-c", "zoxide query -ls" } })
  end, { desc = "Find Zoxide" })

  vim.keymap.set("n", "<leader>pp", function()
    require("telescope").extensions.project.project({})
  end, { desc = "Find Project" })
end

return M
