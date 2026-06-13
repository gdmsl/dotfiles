#!/bin/sh
# Rename the active Hyprland workspace.
#
# tofi normally forces a choice from its list; --require-match=false makes it
# return whatever you type (the list is empty here, so it's a plain input box).
# `renameworkspace` takes a workspace *id*, so we pull the active one from
# `hyprctl activeworkspace`. Empty input — Escape, or Enter on an empty box —
# leaves the name untouched.
name=$(tofi --prompt-text "Workspace name: " \
  --require-match=false --width 25% --height 10% </dev/null)
[ -n "$name" ] && hyprctl dispatch renameworkspace \
  "$(hyprctl activeworkspace -j | jq -r '.id')" "$name"
