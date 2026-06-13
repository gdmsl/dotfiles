-- Keybindings.
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
--
-- Lua-mode conventions:
--   * `hl.bind(keys, dispatcher, opts?)`. `keys` is a single string like
--     "SUPER + SHIFT + Q"; mods come first, glued with " + ".
--   * Dispatchers come from `hl.dsp.*`. They return *plans*, not actions —
--     e.g. `hl.dsp.exec_cmd("ghostty")` returns an opaque handle that
--     `hl.bind` then attaches.
--   * `{ mouse = true }`  = old `bindm`. `{ locked = true }` = old `bindl`.
local vars = require("vars")
local mod  = vars.mainMod

-- ── Applications ─────────────────────────────────────────────────────────
hl.bind(mod .. " + Return",        hl.dsp.exec_cmd("uwsm app -- ghostty"))
hl.bind(mod .. " + B",             hl.dsp.exec_cmd("uwsm app -- firefox"))
hl.bind(mod .. " + SHIFT + B",     hl.dsp.exec_cmd("uwsm app -- bimbumbam"))
hl.bind(mod .. " + X",             hl.dsp.exec_cmd("uwsm app -- kitty -e yazi"))
hl.bind(mod .. " + SHIFT + X",     hl.dsp.exec_cmd("uwsm app -- cosmic-files"))
hl.bind(mod .. " + Space",         hl.dsp.exec_cmd("vicinae toggle"))
hl.bind(mod .. " + SHIFT + Space", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(mod .. " + ALT + Space",   hl.dsp.exec_cmd("uwsm app -- anyrun"))
hl.bind(mod .. " + Comma",         hl.dsp.exec_cmd("noctalia msg session lock"))

-- Clipboard history. Noctalia owns the clipboard manager itself (its own
-- wlr-data-control daemon + history store), opened via its IPC panel toggle.
-- Bound on the SHIFT slot because bare SUPER+P is shadowed by a later mapping.
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))

-- ── Session ──────────────────────────────────────────────────────────────
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())

-- ── Window management ────────────────────────────────────────────────────
hl.bind(mod .. " + SHIFT + Q",  hl.dsp.window.close())
hl.bind(mod .. " + F",          hl.dsp.window.fullscreen())                     -- toggle fullscreen
hl.bind(mod .. " + G",          hl.dsp.window.fullscreen_state({ internal = 1, client = 1 }))
hl.bind(mod .. " + SHIFT + G",  hl.dsp.window.fullscreen_state({ internal = 1, client = 2 }))
hl.bind(mod .. " + S",          hl.dsp.layout("togglesplit"))                   -- dwindle only
hl.bind(mod .. " + C",          hl.dsp.window.pseudo())                         -- dwindle only
hl.bind(mod .. " + SHIFT + W",  hl.dsp.group.toggle())
hl.bind(mod .. " + W",          hl.dsp.group.next())                            -- old changegroupactive (forward)
hl.bind(mod .. " + Space",      hl.dsp.window.float({ action = "toggle" }))

-- Move focus with mod + arrow keys
hl.bind(mod .. " + left",       hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + down",       hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + up",         hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + right",      hl.dsp.focus({ direction = "right" }))

-- Move focused window with mod + SHIFT + arrow keys
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left"  }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down"  }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up"    }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))

-- Move focus with vim-like mod + hjkl
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left"  }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down"  }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up"    }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Move focused window with vim-like mod + SHIFT + hjkl
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left"  }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down"  }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up"    }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Drag with mod + LMB/RMB (the { mouse = true } option = old `bindm`)
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Switch workspaces with mod + [0-9]   (key 0 → workspace 10)
-- Move active window to workspace with mod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10  -- 10 → 0
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Jump to the first empty workspace
hl.bind(mod .. " + M", hl.dsp.focus({ workspace = "empty" }))

-- Rename the active workspace via a tofi prompt (SHIFT+N is taken by
-- "move window to next workspace", so this lives on ALT+N)
hl.bind(mod .. " + ALT + N", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/rename-workspace.sh"))

-- Special workspace ("scratchpad") with mod + /
hl.bind(mod .. " + slash",         hl.dsp.workspace.toggle_special(""))
hl.bind(mod .. " + SHIFT + slash", hl.dsp.window.move({ workspace = "special" }))

-- Cycle workspaces with mod + scroll
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- (N)ext / (P)revious workspace
hl.bind(mod .. " + N", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + P", hl.dsp.focus({ workspace = "e-1" }))

-- Drag active window to next/previous workspace
hl.bind(mod .. " + SHIFT + N", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + P", hl.dsp.window.move({ workspace = "e-1" }))

-- Move the current workspace between monitors by direction
hl.bind(mod .. " + CTRL + H", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mod .. " + CTRL + J", hl.dsp.workspace.move({ monitor = "d" }))
hl.bind(mod .. " + CTRL + K", hl.dsp.workspace.move({ monitor = "u" }))
hl.bind(mod .. " + CTRL + L", hl.dsp.workspace.move({ monitor = "r" }))

-- Swap the active workspaces of monitors 0 and 1
hl.bind(mod .. " + O", hl.dsp.workspace.swap_monitors({ monitor1 = 0, monitor2 = 1 }))

-- Focus the most-recently-urgent window
hl.bind(mod .. " + U", hl.dsp.focus({ urgent_or_last = true }))

-- Pin the active floating window (sticky across workspaces)
hl.bind(mod .. " + I", hl.dsp.window.pin({ action = "toggle" }))

-- Logout menu
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("wlogout"))

-- ── Audio (PipeWire) ─────────────────────────────────────────────────────
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

-- ── Media player (works while a lockscreen is up: { locked = true }) ─────
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"),     { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl pause"),    { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),     { locked = true })

-- ── Brightness ───────────────────────────────────────────────────────────
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"))

-- ── Misc hardware keys ───────────────────────────────────────────────────
hl.bind("XF86Lock",       hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("uwsm app -- ghostty -e julia"))
hl.bind("XF86Favorites",  hl.dsp.exec_cmd("uwsm app -- firefox"))

-- ── Submap: resize ───────────────────────────────────────────────────────
-- `hl.define_submap` creates a named submap; every `hl.bind` *inside* the
-- callback is registered against that submap rather than globally.
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("right",  hl.dsp.window.resize({ x =  100, y =    0, relative = true }))
    hl.bind("left",   hl.dsp.window.resize({ x = -100, y =    0, relative = true }))
    hl.bind("up",     hl.dsp.window.resize({ x =    0, y = -100, relative = true }))
    hl.bind("down",   hl.dsp.window.resize({ x =    0, y =  100, relative = true }))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- ── Submap: passthrough ──────────────────────────────────────────────────
-- Lets SUPER reach a guest VM/KVM until Escape exits the submap.
hl.bind(mod .. " + Y", hl.dsp.submap("passthrough"))
hl.define_submap("passthrough", function()
    hl.bind("SUPER + Escape", hl.dsp.submap("reset"))
end)

-- ── Screenshots (grim → satty for annotate/crop, then copy/save) ─────────
hl.bind("Print",         hl.dsp.exec_cmd("grim - | satty --filename -"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | satty --filename -]]))
