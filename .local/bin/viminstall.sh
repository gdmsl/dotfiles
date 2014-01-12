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
