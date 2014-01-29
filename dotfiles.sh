#!/bin/bash
#
# Author: guido.masella@gmail.com
# Description: simple script to copy all the files from the dotfiles github
#              repo to the user's $HOME
#

DEBUG=false;

if [ "$1" == "v" ]; then
	DEBUG=true;

for dirname in `cat directories.list`; do
	if [ -d "$HOME/$dirname" ]; then
		$DEBUG && echo "Directory $dirname already exists in your HOME"
	else
		mkdir -p "$HOME/$dirname"
		$DEBUG && echo "Created $dirname and all its parents in your HOME"
	fi
done

for filename in `cat files.list`; do
	if [ -e "$HOME/$filename" ]; then
		$DEBUG && echo "File $filename already exists in your HOME"
		if [ $DEBUG ]; then
			PS3="Overwrite?"
			select action in "yes no"; do
				if [ "$action" == "yes" ]; then
					cp -f "$filename" "$HOME/$filename"
				fi
			done
		else
			cp -f "$filename" "$HOME/$filename"
		fi
	else
		cp "$filename" "$HOME/$filename"
		$DEBUG && echo "Copied $filename in your HOME"
	fi
done
