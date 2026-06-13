#!/bin/sh
# Rename the active Hyprland workspace.
#
# tofi normally forces a choice from its list; --require-match=false makes it
# return whatever you type (the list is empty here, so it's a plain input box).
# `renameworkspace` takes a workspace *id*, so we pull the active one from
# `hyprctl activeworkspace`. Empty input — Escape, or Enter on an empty box —
# leaves the name untouched.
name=$(tofi --config "$HOME/.config/tofi/prompt" \
  --prompt-text "rename workspace ❯ " --require-match=false </dev/null)
[ -n "$name" ] && hyprctl dispatch renameworkspace \
  "$(hyprctl activeworkspace -j | jq -r '.id')" "$name"
