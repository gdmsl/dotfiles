#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

wlan=$(ip link show | grep -E  '^[0-9]+: wlp' | awk '{print $2}' | tr -d ':' | head -n 1)
eth=$(ip link show | grep -E  '^[0-9]+: enp' | awk '{print $2}' | tr -d ':' | head -n 1)

if type "xrandr"; then
    # Get all the connected monitors
    monitors=$(xrandr | grep " connected" | awk '{ print $1 }')
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        ETH=$eth WLAN=$wlan MONITOR=$m polybar --reload top &
        ETH=$eth WLAN=$wlan MONITOR=$m polybar --reload bottom &
    done
else
    ETH=$eth WLAN=$wlan polybar --reload full &
fi

echo "Bars launched..."

