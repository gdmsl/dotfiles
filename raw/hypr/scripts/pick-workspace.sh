#!/bin/sh
# Pick a Hyprland workspace from a fuzzel list and switch to it.
#
# Lines are "<id>\t<name>"; fuzzel shows only the name (--with-nth) and
# --accept-nth hands back the id. Special workspaces (negative ids) are left out.
id=$(hyprctl workspaces -j \
  | jq -r 'map(select(.id > 0)) | sort_by(.id)[] | "\(.id)\t\(.name)"' \
  | fuzzel --dmenu --prompt "workspace ❯ " --with-nth 2 --accept-nth 1)
[ -n "$id" ] && hyprctl dispatch workspace "$id"
