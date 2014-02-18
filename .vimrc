" ---------------------------------------------------------- "
"               ~/.vimrc a config for True Gods              "
"                       by (Guido Masella)                   "
"                    (guido.masella@gmail.com)               "
" ---------------------------------------------------------- "

" Let's drop vi compatibility. Be iMproved!
set nocompatible

" ?
filetype off

" Load external configuration to be done before anything else is done
if filereadable(expand("~/.vim/before.vimrc"))
	source ~/.vim/before.vimrc
endif

" Change the mapleader to comma
let mapleader = ","
let maplocalleader = "\\"

" Load local configuration file
let s:localrc = expand($HOME . '/.vim/local.vimrc')
if filereadable(s:localrc)
    exec ':so ' . s:localrc
endif

" Setup Vundle
let s:bundle_path=$HOME."/.vim/bundle/"
execute "set rtp+=".s:bundle_path."vundle/"
call vundle#rc()

" let Vundle manage vundle
Bundle 'gmarik/vundle'

" packages to be loaded
if ! exists('g:gmas_packages')
	let g:gmas_packages = ['general', 'look', 'editing']
endif

" load bundles
if filereadable(expand("~/.vim/bundles.vimrc"))
	source ~/.vim/bundles.vimrc
endif

" Allow backspacing over everithing in insert mode
set backspace=indent,eol,start

if has("vms")
	set nobackup	" do not keep a backup file, use versions instead
else
	set backup	" keep a backup file
endif

set history=1000	" keep 1K lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" Switch syntax highlighting on, when terminal has colors.
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has ("gui_running")
	syntax on
	set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
	" Enable file type detection and use the default filetype settings.
	" .. Also load indent files, to automatically do language-dependent
	" .. indenting
	filetype plugin indent on

	" Puth these in an autocmd group, so that we can delete them easily.
	augroup vimrcEx
	au!

	" For all text files set 'textwidth' to 78 chars
	autocmd FileType text setlocal textwidth=78

	" When editing a file, always jump to the last know cursor position.
	" .. Don't do it when the position is invalid or when inside and event
	" .. handler (happens when dropping a file on gvim).
	" .. Also don't do it when the mark is in the first line, this is the
	" .. default position when opening a file
	autocmd BufReadPost *
		\ if line("'\"") > 1 && line("'\"") <= line("$") |
		\ 	exe "normal! g`\"" |
		\ endif

	augroup END

else

	" Always set autoindenting on
	set autoindent

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" .. file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
	command Difforig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		\ | wincmd p | diffthis
endif


" God Like mode. U can't use the arrow keys! Muahahah!
noremap <left> <nop>
noremap <up> <nop>
noremap <down> <nop>
noremap <right> <nop>
" Neither in insert mode! muahahah!
inoremap <left> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <right> <nop>
" Using arrow keys in vim visual mode is for loosers!
vnoremap <left> <nop>
vnoremap <up> <nop>
vnoremap <down> <nop>
vnoremap <right> <nop>
" I do not know what o-mode stands for and now I'm feeling too lazy to
" .. check the wiki. But, no matter what o stand for and no matter in what
" .. mode do you are, you will never be allowed to use arrow keys for
" .. movements!
onoremap <left> <nop>
onoremap <up> <nop>
onoremap <down> <nop>
onoremap <right> <nop>

" Less god like mode - change the escape key to jj in
"  .. command and insert mode and to v in visual mode
ino jj <esc>
cno jj <c-c>
vno v <esc>


" A different color for the 80th column
set colorcolumn=80
