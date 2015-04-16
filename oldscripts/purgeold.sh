#!/bin/bash
#
# Author: guido.masella@gmail.com
#

for filename in `cat files.list`; do
	if [ -h "$HOME/$filename" ]; then
        rm "$HOME/$filename"
	fi
done

for directory in `cat dirpurge.list`; do
    if [ -d "$HOME/$directory" ]; then
        rm -Rf "$HOME/$directory"
    fi
done
