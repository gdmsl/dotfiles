#!/bin/sh
# Rename the active Hyprland workspace.
#
# fuzzel --prompt-only is a plain input box with no list. `renameworkspace`
# takes a workspace *id*, so we pull the active one from
# `hyprctl activeworkspace`. Empty input — Escape, or Enter on an empty box —
# leaves the name untouched. :shortcode: becomes an emoji, see `emojize`.
name=$(fuzzel --config "$HOME/.config/fuzzel/prompt.ini" \
  --dmenu --prompt-only "rename workspace ❯ " </dev/null \
  | emojize)
[ -n "$name" ] && hyprctl dispatch renameworkspace \
  "$(hyprctl activeworkspace -j | jq -r '.id')" "$name"
