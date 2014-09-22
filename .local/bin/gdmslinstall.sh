#!/bin/bash

echo "Changing working directory to $HOME"
cd $HOME

if [ ! -d .vim/bundle ]; then
	mkdir .vim/bundle
fi

echo "Changing working directory to $HOME/.vim/bundle"
cd .vim/bundle

if [ ! -d vundle ]; then
    echo "Installing vundle"
	git clone http://github.com/gmarik/vundle
fi

echo "Installing all boundles from .vimrc"
vim -c 'BundleInstall'

echo "Changing working directory to $HOME"
cd $HOME

echo "Installing ttytter-extension"
git clone https://github.com/oxhak/ttytter-extension ~/.ttytter/ttytter-extension

echo "Installing OHMYZSH"
echo "########################################################"
curl -L http://install.ohmyz.sh | sh
echo "########################################################"
