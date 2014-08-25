#!/bin/bash

cd $HOME

if [ ! -d .vim/bundle ]; then
	mkdir .vim/bundle
fi

cd .vim/bundle

if [ ! -d vundle ]; then
	git clone http://github.com/gmarik/vundle
fi

vim -c 'BundleInstall'

git clone https://github.com/chriskempson/base16-shell ~/.config/base16-shell
git clone https://github.com/chriskempson/base16-xresources ~/.xrdb/base16-xresources
