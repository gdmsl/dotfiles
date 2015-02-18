#!/bin/bash

if [ `systemctl --user is-active feh-wallpaper.timer` = "active" ]; then
    systemctl --user stop feh-wallpaper.timer
    DISPLAY=:0 bash ~/.fehbg
    notify-send "Stopped feh-wallpaper.service and changed wallpaper"
else
    systemctl --user start feh-wallpaper.service feh-wallpaper.timer
    notify-send "Started feh-wallpaper.service"
fi
