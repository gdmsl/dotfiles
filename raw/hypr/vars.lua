-- Shared variables (themes, cursor, DPI). Other modules `require("vars")`
-- and read them as table fields. Replaces the `$system_theme = ...` set of
-- variables that lived at the top of the old hyprland.conf.
local M = {}

M.system_theme = "Arc-Dark"
M.cursor_theme = "Bibata-Modern-Ice"
M.cursor_size  = 24
M.icon_theme   = "Colloid-Dark"
M.dpi_scale    = 1
M.text_scale   = 1

-- Default modifier for keybinds. SUPER is the "Windows" / "Meta" key.
M.mainMod = "SUPER"

return M
