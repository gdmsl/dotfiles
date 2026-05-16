-- Monitors. See https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Each hl.monitor({...}) call configures one display. `output = ""` is the
-- catch-all that applies to any otherwise-unconfigured monitor (replaces the
-- bare `monitor=,preferred,auto,auto` row from hyprlang).

hl.monitor({ output = "eDP-1",    mode = "1920x1080", position = "0x0",  scale = 1     })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = "auto" })
hl.monitor({ output = "",         mode = "preferred", position = "auto", scale = "auto" })
