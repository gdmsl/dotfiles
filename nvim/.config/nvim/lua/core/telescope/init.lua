local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  return
end

local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local action_mt = require "telescope.actions.mt"
local sorters = require "telescope.sorters"
local themes = require "telescope.themes"

telescope.setup{
    defaults = {
        prompt_prefix = "❯ ",
        selection_caret = "❯ ",

        winblend = 0,

        selection_strategy = "reset",
        prompt_position = "top",
        sorting_strategy = "descending",
        scroll_strategy = "cycle",
        color_devicons = true,

        mappings = {
            i = {
                ["<esc>"] = actions.close,
            },
        },
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = false,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
        arecibo = {
            ["selected_engine"]   = 'google',
            ["url_open_command"]  = 'xdg-open',
            ["show_http_headers"] = false,
            ["show_domain_icons"] = false,
        },
    }
}

telescope.load_extension("fzy_native")
telescope.load_extension("fzf")
telescope.load_extension("cheat")
telescope.load_extension("arecibo")
telescope.load_extension("bibtex")
telescope.load_extension("frecency")

