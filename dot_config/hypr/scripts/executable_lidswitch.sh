#!/bin/bash

# check the status of the lid
if grep open /proc/acpi/button/lid/LID0/state; then
	hyprctl keyword monitor "eDP-1, 1920x1080, 0x0, 1"
	~/.config/hypr/scripts/monitor-config.sh
else
	if [[ $(hyprctl monitors | grep -c "Monitor") != 1 ]]; then
		hyprctl keyword monitor "eDP-1, disable"
	fi
fi

# sleep to avoid bad picture in swaylock
sleep 1

# lock the screen
swaylock
