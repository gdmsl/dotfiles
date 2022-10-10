--
--   ____ ____  __  __ ____  _
--  / ___|  _ \|  \/  / ___|| |        GDMSL
-- | |  _| | | | |\/| \___ \| |        https://github.com/gdmsl
-- | |_| | |_| | |  | |___) | |___     https://twitter.com/gdmsl
--  \____|____/|_|  |_|____/|_____|    https://gitlab.com/gdmsl
--
-- This configuration is heavily inspired (and often copyed) by tjdevires from
-- https://github.com/tjdevires/config_manager
-- https://github.com/folke/dot/

local util = require("util")

-- util.debug_pcall()

util.require("config.options")

vim.schedule(function()
  util.packer_defered()
  util.version()
  util.require("config.commands")
  util.require("config.mappings")
  util.require("config.plugins")
end)
