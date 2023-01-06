-- Leader key -> " "
--
-- The leader key has to be defined as early as possible so no plugin will use
-- the old definition in setting mappings.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- GUI
vim.opt.termguicolors = true
vim.opt.guifont = "FiraCode Nerd Font:h11"

-- Ignore compiled files
vim.opt.wildignore = { "*.o", "*~", "*.pyc", "*pycache*" }
vim.opt.wildmode = { "longest", "list", "full" }

-- options for insert mode completion
-- `menu` and `menuone` will show a menu even if there is only one entry
-- `noselect` will not select a match from the menu but will wait for the user
-- to do it.
vim.opt.completeopt = "menu,menuone,noselect"

-- Scrolling
vim.opt.scrolloff = 4 -- Keep always 4 lines under the cursor when scrolling
vim.opt.scrolljump = 4 -- Scroll by 4 lines at a time.
vim.opt.sidescrolloff = 8 -- Columns of context

-- Tabs, indent, and breaks
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.shiftround = true -- Round indent
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.tabstop = 2 -- Number of spaces tabs count for
vim.opt.wrap = false -- Disable line wrap
vim.opt.expandtab = true -- Use spaces instead of tabs

-- Search
vim.opt.smartcase = true -- Don't ignore case with capitals
vim.opt.ignorecase = true -- Ignore case
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"

-- Formatting
-- see :help formatoptions or :help fo-table for a list of values.
-- This table will be probably changed by filetype plugins.
vim.opt.formatoptions = "jcroqlnt"

-- No double spaces after a dot when join lines
vim.opt.joinspaces = false

-- Buffers
vim.opt.hidden = true -- Enable modified buffers in background

-- Appearance
vim.opt.cursorline = true -- Enable highlighting of the current line
vim.opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
vim.opt.conceallevel = 3 -- Hide * markup for bold and italic
vim.opt.list = true -- Show some invisible characters (tabs...
vim.opt.showmode = false -- dont show mode since we have a statusline

-- Line Numbers
vim.opt.number = true -- Print line number
vim.opt.relativenumber = true -- Relative line numbers

-- Command line
vim.opt.pumblend = 10 -- Popup blend
vim.opt.pumheight = 10 -- Maximum number of entries in a popup
vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
vim.opt.cmdheight = 1

-- Windows
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current

-- General
vim.opt.autowrite = true -- enable auto write
vim.opt.clipboard = "unnamedplus" -- sync with system clipboard
vim.opt.confirm = true -- confirm to save changes before exiting modified buffer
vim.opt.inccommand = "nosplit" -- preview incremental substitute
vim.opt.laststatus = 0
vim.opt.mouse = "a" -- enable mouse mode
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
vim.opt.spelllang = { "en" }
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 200 -- save swap file and trigger CursorHold

if vim.fn.has("nvim-0.9.0") == 1 then
  vim.opt.splitkeep = "screen"
  vim.o.shortmess = "filnxtToOFWIcC"
end

if vim.g.started_by_frenvim then
  vim.opt.signcolumn = "no"
end

-- fix markdown indentation settings
vim.g.markdown_recommended_style = 0
