-- Environment variables for Wayland clients.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
local vars = require("vars")

hl.env("CLUTTER_BACKEND", "wayland")
hl.env("GDK_BACKEND",     "wayland,x11,*")
hl.env("GDK_DPI_SCALE",   tostring(vars.dpi_scale))
hl.env("GDK_SCALE",       tostring(vars.dpi_scale))

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE",    "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("QT_QPA_PLATFORM",                    "wayland;xcb")
-- QT_QPA_PLATFORMTHEME is deliberately not set here. home/desktop/qt.nix
-- exports it through environment.d, so both compositors get the same value
-- instead of each naming its own (they used to disagree).
hl.env("QT_WAYLAND_DISABLE_WINDOW_DECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",        tostring(vars.dpi_scale))

hl.env("SDL_VIDEODRIVER", "wayland")

hl.env("MOZ_ENABLE_WAYLAND",   "1")
hl.env("OBSIDIAN_USE_WAYLAND", "1")

hl.env("HYPRCURSOR_SIZE",  tostring(vars.cursor_size))
hl.env("HYPRCURSOR_THEME", vars.cursor_theme)
hl.env("XCURSOR_SIZE",     tostring(vars.cursor_size))
hl.env("XCURSOR_THEME",    vars.cursor_theme)
