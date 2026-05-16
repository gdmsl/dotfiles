-- Window rules. See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--
-- Each `hl.window_rule({ match = { ... }, <effect> = <value> })` adds one
-- rule. `match` is a *regex* by default — preserve the literal patterns
-- from the old hyprlang file unless they're known to be plain strings.

-- Generic float-on-class rules
for _, cls in ipairs({
    "confirm", "dialog", "download", "notification", "error", "splash",
    "confirmreset", "Lxappearance", "Rofi", "pavucontrol-qt", "pavucontrol",
    "^(pavucontrol)$", "^(nm-connection-editor)$",
}) do
    hl.window_rule({ match = { class = cls }, float = true })
end

-- Generic float-on-title rules
for _, t in ipairs({ "Open File", "Open files", "Save As", "branchdialog" }) do
    hl.window_rule({ match = { title = t }, float = true })
end

-- Rofi: float + no animation
hl.window_rule({ match = { class = "Rofi" }, animation = "none" })

-- wlogout: fullscreen + the float-title variant the old config also set
hl.window_rule({ match = { class = "wlogout" }, fullscreen = true })
hl.window_rule({ match = { title = "wlogout" }, float = true })
hl.window_rule({ match = { title = "wlogout" }, fullscreen = true })

-- Idle inhibitor hints — keep displays awake while watching media.
hl.window_rule({ match = { class = "mpv" },     idle_inhibit = "focus" })
hl.window_rule({ match = { class = "firefox" }, idle_inhibit = "fullscreen" })

-- Force-tile some Chromium-family browsers (they like to ask for floating).
for _, cls in ipairs({ "^(Microsoft-edge)$", "^(Brave-browser)$", "^(Chromium)$" }) do
    hl.window_rule({ match = { class = cls }, tile = true })
end

-- clipse popup (clipboard manager): floating, fixed-size, sticky focus.
hl.window_rule({
    match = { class = "(me.gdmsl.clipse)" },
    float = true,
    size  = "622 652",
    stay_focused = true,
})
