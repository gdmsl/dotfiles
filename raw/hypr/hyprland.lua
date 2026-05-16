--   _  _                   _                 _
--  | || | _  _  _ __  _ _ | | __ _  _ _   __| |
--  | __ || || || '_ \| '_|| |/ _` || ' \ / _` |
--  |_||_| \_, || .__/|_|  |_|\__,_||_||_|\__,_|
--         |__/ |_|
--
--   Beagle Werd Lua config — main entry point.
--
-- Hyprland 0.55+ uses Lua for its config file. This file is evaluated once
-- on startup and on every `hyprctl reload`. Each `require("foo")` below
-- loads `~/.config/hypr/foo.lua` (Hyprland adds that directory to
-- package.path), so you can split the config into focused modules.

-- Monitors and workspaces
require("monitors")
require("workspaces")

-- Autostart (exec-once equivalents wired to the hyprland.start event)
require("conf.autostart")

-- Cursor (re-applied on every reload, matches the old `exec=` semantics)
require("conf.cursor")

-- Environment variables (hl.env)
require("conf.environment")

-- GTK theme (re-applied on every reload via gsettings)
require("conf.gtk")

-- Keyboard / input
require("conf.keyboard")

-- Look and feel
require("conf.window")        -- general (gaps, borders, layout)
require("conf.group")         -- group border colors
require("conf.decoration")    -- rounding, blur, shadow, opacity
require("conf.layout")        -- dwindle + master tuning
require("conf.gestures")      -- touchpad swipe
require("conf.devices")       -- per-device tweaks
require("conf.misc")          -- misc compositor toggles

-- Keybindings + window rules + plugin configuration + animations + per-host
require("conf.keybindings")
require("conf.windowrule")
require("conf.plugins")
require("conf.animations")
require("conf.custom")
