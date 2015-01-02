#!/bin/bash

if [ `systemctl --user is-active feh-wallpaper.timer` = "active" ]; then
    systemctl --user stop feh-wallpaper.timer
    DISPLAY=:0 bash ~/.fehbg
    echo " stopped service and changed wallpaper"
else
    systemctl --user start feh-wallpaper.service feh-wallpaper.timer
    echo " started service"
fi
