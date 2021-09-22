--
-- Tags
--

-- standard library
local awful = require("awful")
local gears = require("gears")

-- Widget and layout library
local wibox = require("wibox")

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
end)
-- }}}
