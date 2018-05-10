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

# start gnome-keyring
eval $(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)
export GPG_AGENT_INFO SSH_AUTH_SOCK

export MOZ_USE_OMTC=1

if [ "$HOSTNAME" = "spectre" ]; then
    cat ~/.xbindkeys.d/m1.xbind > ~/.xbindkeysrc
    xbindkeys
fi

# load the Xresources
[[ -f ~/.Xresources ]] && xrdb ~/.Xresources

if [ "$HOSTNAME" = "rubick" ]; then
    xrdb -merge ~/.xrdb/fullhd.xresources
fi

# disable mouse acceleration
if [ "$HOSTNAME" = "spectre" ]; then
    xset m 0 0
fi

[[ -f ~/.screenlayout/default.sh ]] && ~/.screenlayout/default.sh

[[ -f ~/.xbindkeysrc ]] && xbindkeys

export MOZ_USE_OMTC=1

export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# exec gnome-session
# exec startkde
# exec startxfce4
exec i3
# ...or the Window Manager of your choice

#exec $1
