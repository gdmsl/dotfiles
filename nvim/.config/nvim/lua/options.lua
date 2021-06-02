local opt = vim.opt

-- Ignore compiled files
opt.wildignore = "__pycache__"
opt.wildignore = opt.wildignore + { "*.o", "*~", "*.pyc", "*pycache*" }

opt.wildmode = { "longest", "list", "full" }

-- Cool floating window popup menu for completion on command line
opt.pumblend = 15

opt.wildmode = opt.wildmode - "list"
opt.wildmode = opt.wildmode + { "longest", "full" }

opt.wildoptions = "pum"

-- Set the width of the text
opt.colorcolumn = "80"

-- Line numbers
opt.relativenumber = true -- Show line numbers
opt.number = true -- But show the actual number for the line we're on

-- Appareance
opt.cmdheight = 1 -- Height of the command bar
opt.fillchars = { eob = "~" } -- fill empty lines at the end of buffer
opt.cursorline = true -- Highlight the current line

-- Search options
opt.ignorecase = true
opt.incsearch = true
opt.smartcase = true

-- Windows
opt.equalalways = false -- I don't like my windows changing all the time
opt.splitright = true -- Prefer windows splitting to the right
opt.splitbelow = true -- Prefer windows splitting to the bottom

-- Scrolling
opt.scrolloff = 5 -- Always 5 lines under the cursor
opt.scrolljump = 5 -- Jump 5 lines when scrolling

-- Highlight
opt.showmatch = true -- show matching brackets when text indicator is over them

-- Tabs, indent and breaks
opt.autoindent = true
opt.cindent = true
opt.wrap = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.breakindent = true
opt.showbreak = string.rep(" ", 3) -- Make it so that long lines wrap smartly
opt.linebreak = true

-- Folding
opt.foldmethod = "syntax"
opt.foldlevel = 0

-- Search
opt.ignorecase = true -- Ignore case when searching...
opt.smartcase = true -- ... unless there is a capital letter in the query
opt.hidden = true -- I like having buffers stay around
opt.hlsearch = true

-- Formatting
--
-- Helpful related items:
--   1. :center, :left, :right
--   2. gw{motion} - Put cursor back after formatting motion.
--
opt.formatoptions = opt.formatoptions
  - "a" -- Auto formatting is BAD.
  - "t" -- Don't auto format my code. I got linters for that.
  + "c" -- In general, I like it when comments respect textwidth
  + "q" -- Allow formatting comments w/ gq
  - "o" -- O and o, don't continue comments
  + "r" -- But do continue when pressing enter.
  + "n" -- Indent past the formatlistpat, not underneath it.
  + "j" -- Auto-remove comments if possible.
  - "2" -- ??
opt.joinspaces = false -- Dont use two spaces after .?! when joining

-- General
opt.showmode = false
opt.showcmd = true
opt.updatetime = 1000 -- Make updates happen faster
opt.modelines = 1
opt.belloff = "all" -- Just turn the dang bell off
opt.clipboard = "unnamedplus"
opt.mouse = "n"
opt.inccommand = "split"
opt.swapfile = false -- Living on the edge
opt.shada = { "!", "'1000", "<50", "s10", "h" }
