-- GTK + GNOME interface settings, re-applied on every reload.
local vars = require("vars")

local gschema = "org.gnome.desktop.interface"

local function gset(key, value)
    hl.exec_cmd(string.format("gsettings set %s %s %s", gschema, key, value))
end

gset("gtk-theme",            string.format("'%s'", vars.system_theme))
gset("icon-theme",           string.format("'%s'", vars.icon_theme))
gset("cursor-theme",         string.format("'%s'", vars.cursor_theme))
gset("text-scaling-factor",  tostring(vars.text_scale))
gset("cursor-size",          tostring(vars.cursor_size))
gset("color-scheme",         "'prefer-dark'")
