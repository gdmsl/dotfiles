#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

# Source xprofile
[ -f /etc/xprofile ] && . /etc/xprofile
[ -f ~/.xprofile ] && . ~/.xprofile

# Xresources
if [ -f ~/.Xresources ]; then
    xrdb ~/.Xresources
fi
if [ -e ~/.Xresources-$HOSTNAME ]; then
    xrdb -merge ~/.Xresources-$HOST
fi

# execute the best window manager in the world
exec i3
