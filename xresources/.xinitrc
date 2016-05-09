#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

[[ -f ~/.Xresources ]] && xrdb ~/.Xresources

# start gnome-keyring
eval $(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)
export GPG_AGENT_INFO SSH_AUTH_SOCK

#xrandr --output LVDS1 --gamma 0.8:0.9:0.7 --primary

export MOZ_USE_OMTC=1

if [ "$HOSTNAME" = "alchemist" ]; then
    cat ~/.xbindkeys.d/m1.xbind > ~/.xbindkeysrc
    xbindkeys
fi

# exec gnome-session
# exec startkde
# exec startxfce4
exec i3
# ...or the Window Manager of your choice

#exec $1
