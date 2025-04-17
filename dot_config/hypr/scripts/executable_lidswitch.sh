#!/bin/bash

if grep open /proc/acpi/button/lid/LID0/state; then
    kanshictl switch home || kanshictl switch presenter
else
    kanshictl switch home-nolid || kanshictl switch presenter-nolid

    if [ $? -eq 1 ]; then
        sleep 1
        hyprlock
    fi
fi
