#!/bin/bash
#
# AUTHOR: Guido Masella <guido.masella@gmail.com>
#

# initialize the home folder
mkdir $HOME/.i3
mkdir -p $HOME/.local/bin

# initialize cache for mutt
mkdir -p $HOME/.cache/mutt/{headers,bodies,certificates,tmp}

# initialize cache for mpd
mkdir -p $HOME/.cache/mpd/playlists
touch $HOME/.cache/mpd/{database,log,pid,state,sticker.sql}
