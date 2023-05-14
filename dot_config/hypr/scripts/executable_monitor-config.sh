#!/bin/bash

# Get the HDMI monitor
hdmi_monitor=$(hyprctl monitors -j | jq 'map(select(.name == "HDMI-A-1"))[0]')
first_monitor=$(hyprctl monitors -j | jq '.[0].name')

if [ "$first_monitor" != '"eDP-1"' ]; then
  exit
fi

hdmi_make=$(echo "$hdmi_monitor" | jq '.make')
hdmi_model=$(echo "$hdmi_monitor" | jq '.model')

echo "model $hdmi_make"
echo "make $hdmi_model"

if [ "$hdmi_make" = '"Samsung Electric Company"' ] && [ "$hdmi_model" = '"U28E850"' ]; then
  hyprctl keyword monitor "HDMI-A-1,2560x1440@60,0x0,auto"
  sleep 1
  hyprctl keyword monitor "eDP-1,1920x1080,320x1440,1"
fi

