#!/bin/bash

if [ ! -d $HOME/.vim/bundle ]; then
	mkdir $HOME/.vim/bundle
fi


if [ ! -d $HOME/.vim/bundle/vundle ]; then
    echo "Installing vundle"
	git clone http://github.com/gmarik/vundle $HOME/.vim/bundle/vundle
fi

echo "Installing all boundles from .vimrc"
vim -c 'BundleInstall'
