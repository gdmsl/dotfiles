#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Get the connected monitors
monitors=$(xrandr | grep " connected" | awk '{ print $1 }')

counter=1
for m in $monitors; do
    postfix="$counter"
    if [ $counter -eq 1 ]; then
        postfix=''
    fi
    polybar $HOSTNAME$postfix &

    counter=$((counter+1))
done

echo "Bars launched..."
