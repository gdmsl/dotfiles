#!/bin/bash
# Dunst "do not disturb" indicator for polybar. You should be able 
# to snooze and unsnooze notification by left-clicking the icon.
#
# Author: machaerus
# https://gitlab.com/machaerus
#
# Modified by: gdmsl
# https://github.com/gdmsl

dunst_notifications() {
	dunst_enabled=$(dunstctl is-paused)
	if [ "$dunst_enabled" == "false" ]; then
		dunst_indicator=""
	else
		dunst_indicator=""
	fi
	echo $dunst_indicator
}
dunst_notifications
