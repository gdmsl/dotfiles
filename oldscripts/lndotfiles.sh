#!/bin/bash
#
# Author: guido.masella@gmail.com
# Description: simple script to link all the files from the dotfiles github
#              repo to the user's $HOME
#

DEBUG=false;

if [ "$1" == "v" ]; then
	DEBUG=true;
fi

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
		if $DEBUG; then
			PS3="Overwrite?"
			select action in "yes" "no";do
				if [ "$action" == "yes" ]; then
					rm "$HOME/$filename"
					ln -s "$PWD/$filename" "$HOME/$filename"
				fi
				break;
			done
		else
			rm -f "$HOME/$filename"
			ln -s "$PWD/$filename" "$HOME/$filename"
		fi
	else
		rm "$HOME/$filename"
		ln -s "$PWD/$filename" "$HOME/$filename"
		$DEBUG && echo "Linked $filename in your HOME"
	fi
done
