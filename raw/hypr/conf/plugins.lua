-- Plugin configuration.
--
-- Plugins are loaded out-of-band by hyprpm (see ../autostart.lua). Their
-- *settings* live inside `hl.config({ plugin = { <name> = { ... } } })`.
-- Repeated hyprlang keywords like `hyprbars-button = ...` become Lua
-- list-valued entries.

hl.config({
    plugin = {
        touch_gestures = {
            sensitivity              = 4.0,
            workspace_swipe_fingers  = 3,
            -- Edge swipe direction to switch workspaces (l/r/u/d, or anything
            -- else to disable). Independent of workspace_swipe_fingers.
            workspace_swipe_edge     = "d",
            long_press_delay         = 400,  -- ms
            experimental = {
                -- Send real cancel events to windows instead of synthetic
                -- touch_up. Disabled until upstream stabilises.
                send_cancel = 0,
            },
        },

        hyprbars = {
            bar_height                  = 28,
            bar_color                   = "rgb(1e1e1e)",
            ["col.text"]                = "rgb(ffffff)",  -- dotted hyprbars key
            bar_text_size               = 11,
            bar_text_font               = "Inter",
            bar_button_padding          = 10,
            bar_padding                 = 10,
            bar_precedence_over_border  = true,
            -- Title-bar buttons. Each entry is a raw hyprlang value string
            -- (color, size, icon, command) because the keyword expects that
            -- shape verbatim and the plugin doesn't expose a structured form.
            ["hyprbars-button"] = {
                "rgb(ffffff), 16, , hyprctl dispatch killactive",
                "rgb(ffffff), 16, , hyprctl dispatch fullscreen 2",
                "rgb(ffffff), 16, , hyprctl dispatch togglefloating",
            },
        },
    },
})

-- Touch gesture binds (edge:/swipe:/longpress:) live in the touch_gestures
-- plugin's own bind parser, which the Lua-mode `hl.bind` parser doesn't
-- currently accept. Re-enable these once the plugin gains a Lua-friendly
-- entry point (or wire them through `hyprctl keyword bind ...` for now).
--
-- bind = ,edge:r:l,workspace,e+1
-- bind = ,edge:l:r,workspace,e-1
-- bind = ,swipe:4:d,killactive
-- bind = ,longpress:3,movewindow
