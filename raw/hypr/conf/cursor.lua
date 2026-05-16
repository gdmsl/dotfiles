-- Cursor theme/size. These run on every reload (top-level hl.exec_cmd is
-- the Lua-mode equivalent of hyprlang's `exec=`, not `exec-once=`).
local vars = require("vars")

hl.exec_cmd(string.format("hyprctl setcursor %s %d", vars.cursor_theme, vars.cursor_size))
hl.exec_cmd(string.format("gsettings set org.gnome.desktop.interface cursor-theme '%s'", vars.cursor_theme))
hl.exec_cmd(string.format("gsettings set org.gnome.desktop.interface cursor-size %d", vars.cursor_size))
