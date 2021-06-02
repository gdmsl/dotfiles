--
--   ____ ____  __  __ ____  _
--  / ___|  _ \|  \/  / ___|| |        GDMSL
-- | |  _| | | | |\/| \___ \| |        https://github.com/gdmsl
-- | |_| | |_| | |  | |___) | |___     https://twitter.com/gdmsl
--  \____|____/|_|  |_|____/|_____|    https://gitlab.com/gdmsl
--
-- This configuration is heavily inspired by tjdevires from
-- https://github.com/tjdevires/config_manager

--[[


--]]

-- First run
--
-- Will install packer if this is the first run and then stop reading the rest
-- of the configuration
if require('first_load')() then
  return
end

-- Leader key -> "\"
--
-- The leader key has to be defined as early as possible so no plugin will use
-- the old definition in setting mappings.
vim.g.mapleader = '\\'

-- Load packer.nvim files
require('plugins')

-- Load neovim options
require('options')
