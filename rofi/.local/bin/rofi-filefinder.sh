#!/bin/bash

DMENU='rofi -dmenu'
input="$(find . -type f -mtime -1 -not -path '*/\.*' -print | $DMENU -p "file search":)"
if [ "$input" != '' ]
then
    result="$(echo "$input" | locate -e -r "$input" | $DMENU -p "search result:" )"
    xdg-open "$result"
fi
