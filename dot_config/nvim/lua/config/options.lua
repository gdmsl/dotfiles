local indent = 2

local notify = {
  old = vim.notify,
  lazy = nil,
}

notify .lazy = function(...)
  local args = { ... }
  vim.defer_fn(function()
    if vim.notify == notify.lazy then
      -- if vim.notify still hasn't been replaced yet, then something went wrong,
      -- so use the old vim.notify instead
      notify.old(unpack(args))
    else
      -- use the new notify
      vim.notify(unpack(args))
    end
  end, 300)
end
vim.notify = notify.lazy

if vim.fn.has("nvim-0.8") == 1 then
  vim.opt.cmdheight = 0
  local keymap_set = vim.keymap.set
  vim.keymap.set = function(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    return keymap_set(mode, lhs, rhs, opts)
  end
end

if vim.fn.has("nvim-0.9") == 1 then
  vim.opt.splitkeep = "scrren"
end

-- Leader key -> ","
--
-- The leader key has to be defined as early as possible so no plugin will use
-- the old definition in setting mappings.
vim.g.mapleader = ' '
vim.g.maplocalleader = ","

-- GUI
vim.opt.termguicolors = true
vim.opt.guifont = "FiraCode Nerd Font:h12"

-- Ignore compiled files
vim.opt.wildignore = {"*.o", "*~", "*.pyc", "*pycache*"}
vim.opt.wildmode = {"longest", "list", "full"}

-- options for insert mode completion
-- * `menu` and `menuone` will show a menu even if there is only one entry
-- * `noselect` will not select a match from the menu but will wait for the user
--   to do it.
vim.opt.completeopt = "menu,menuone,noselect"

-- Cool floating window popup menu for completion on command line
vim.opt.pumblend = 10 -- Popup blend
vim.opt.pumheight = 10 -- Maximum number of entries in a popup
vim.opt.wildoptions = "pum"

-- Set the width of the text
vim.opt.colorcolumn = {"80", "92", "120"}

-- Appareance
vim.opt.fillchars = {
  --   horiz = "━",
  --   horizup = "┻",
  --   horizdown = "┳",
  --   vert = "┃",
  --   vertleft = "┫",
  --   vertright = "┣",
  --   verthoriz = "╋",im.o.fillchars = [[eob: ,
  -- fold = " ",
  foldopen = "",
  -- foldsep = " ",
  foldclose = "",
  eob = "~",
}
vim.opt.cursorline = true -- Highlight the current line
vim.opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
vim.opt.concealcursor = "nc" -- Hide * markup for bold and italic
vim.opt.conceallevel = 3 -- Hide * markup for bold and italic

-- Line numbers
vim.opt.number = true -- But show the actual number for the line we're on
vim.opt.relativenumber = true -- Sho:nohw line numbers

-- Search options
vim.opt.ignorecase = true -- Ignore case when searching...
vim.opt.smartcase = true -- ... unless there is a capital letter in the query
vim.opt.hlsearch = true
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.inccommand = "nosplit" -- preview incremental substitute
vim.opt.list = true -- Show some invisible characters (tabs...

-- Buffers
vim.opt.hidden = true -- Enable modified buffers in background

-- Windows
vim.opt.equalalways = false -- I don't like my windows changing all the time
vim.opt.splitright = true -- Prefer windows splitting to the right
vim.opt.splitbelow = true -- Prefer windows splitting to the bottom

-- Scrolling
vim.opt.scrolloff = 5 -- Always 5 lines under the cursor
vim.opt.scrolljump = 5 -- Jump 5 lines when scrolling
vim.opt.scrolloff = 4 -- Lines of context
vim.opt.shiftround = true -- Round indent
vim.opt.sidescrolloff = 8 -- Columns of context

-- Highlight
vim.opt.showmatch = true -- show matching brackets when text indicator is over them

-- Folding
vim.opt.foldmethod = "syntax"
vim.opt.foldlevel = 0

-- Tabs, indent and breaks
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.cindent = true
vim.opt.wrap = false -- Disable line wrap
vim.opt.tabstop = indent -- Number of spaces tabs count for
vim.opt.shiftwidth = indent -- Size of an indent
vim.opt.softtabstop = 4
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.breakindent = true
vim.opt.showbreak = string.rep(" ", 3) -- Make it so that long lines wrap smartly
vim.opt.linebreak = true


-- Formatting
-- see :help formatoptions or :help fo-table for a list of values.
-- This table will be probably changed by filetype plugins.

-- Do not auto-wrap text using 'textwidth'. Leave the choice to formatters
vim.opt.formatoptions:remove("t")

-- Auto-wrap comments using 'textwidth'.
vim.opt.formatoptions:append("c")

-- Do not automatically insert the comment leader after o or O
vim.opt.formatoptions:remove("o")

-- ... but do so after pressing enter
vim.opt.formatoptions:remove("r")

-- Allow formatting of comments with `gq`
vim.opt.formatoptions:append("q")

-- Disable auto formatting of paragraphs
vim.opt.formatoptions:remove("a")

-- When formatting text, recognize numbered lists.
vim.opt.formatoptions:append("n")

-- Where it makes sense, remove a comment leader when joining lines
vim.opt.formatoptions:append("j")

-- No double spaces with join after a dot
vim.opt.joinspaces = false

-- General
vim.opt.showmode = false -- dont show mode since we have a statusline
vim.opt.showcmd = true
vim.opt.updatetime = 1000 -- Make updates happen faster
vim.opt.modelines = 1
vim.opt.belloff = "all" -- Just turn the dang bell off
vim.opt.clipboard = "unnamedplus" -- sync with system clipboard
vim.opt.inccommand = "split"
vim.opt.swapfile = false -- Living on the edge
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.shada = { "!", "'1000", "<50", "s10", "h" }
vim.opt.mouse = "a" -- enable mouse mode
vim.opt.confirm = true -- confirm to save changes before exiting modified buffer


vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }

-- if vim.fn.has("nvim-0.8") == 1 then
--   vim.opt.spell = true -- Put new windows below current
-- end

-- Use proper syntax highlighting in code blocks
local fences = {
  "lua",
  -- "vim",
  "json",
  "typescript",
  "javascript",
  "js=javascript",
  "ts=typescript",
  "shell=sh",
  "python",
  "math=tex",
  "sh",
  "console=sh",
}
vim.g.markdown_fenced_languages = fences
