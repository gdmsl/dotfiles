-- Per-device tweaks.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/

-- Example placeholder kept from the old hyprlang config.
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- ThinkPad TrackPoint repurposed as a scroll stick.
-- Holding the middle button (the one below the spacebar) and pushing the nub
-- scrolls — up/down for vertical, left/right for horizontal. Real middle-click
-- is preserved via L+R chord (middle-emulation, set globally elsewhere if
-- desired). Device name comes from `hyprctl devices`; kernel reports
-- "TPPS/2 Elan TrackPoint" → Hyprland normalises to lowercase + hyphens.
hl.device({
    name          = "tpps/2-elan-trackpoint",
    scroll_method = "on_button_down",
    scroll_button = 274,  -- BTN_MIDDLE
})
