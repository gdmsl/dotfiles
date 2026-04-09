#!/bin/bash

if grep -q open /proc/acpi/button/lid/LID0/state; then
    kanshictl switch home || kanshictl switch presenter
else
    kanshictl switch home-nolid || kanshictl switch presenter-nolid
    systemctl suspend-then-hibernate
fi
