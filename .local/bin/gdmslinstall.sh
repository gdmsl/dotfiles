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

echo "Changing working directory to $HOME"
cd $HOME

echo "Installing all boundles from .vimrc"
vim -c 'BundleInstall'

echo "Installing ttytter-extension"
git clone https://github.com/oxhak/ttytter-extension ~/.ttytter/ttytter-extension

echo "Installing OHMYZSH"
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

echo "Installing base16-builder"
git clone git://github.com/chriskempson/base16-builder.git ~/.base16

echo "Installing Maliwan Color Scheme"
cd ~/.base16
./base16 ~/.maliwan.yml
bash ~/.base16/output/guake/base16-maliwan.dark.sh
bash ~/.base16/output/gnome-terminal/base16-maliwan.dark.sh
cp -f ~/.base16/output/xresources/base16-maliwan.dark.xresources ~/.xrdb/base16-maliwan.dark.xrdb
cp -f ~/.base16/output/bim/base16-maliwan.vim ~/.vim/colors/base16-maliwan.vimx


