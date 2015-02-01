" vim: set ft=vim sw=4 ts=4 sts=4 et tw=78 fdm=marker fdl=0 foldmarker={,} :
"
" ~/.vimrc
"

"
" AUTHOR: Guido Masella <guido.masella@gmail.com>
" DESCRIPTION: My personal Awesome VIMRC file. It uses Vundle as plug-in
"              management system.
"

" Sections in this files:
" General
" Vundle

" General Settings like vi compatibility, command histroy etc...
" General "{
" ============================================================================

" Let's drop Vi compatibility. Be iMproved! ;)
set nocompatible

" Change the mapleader to comma
" With a leader it's possible to do extra key combinations.
" Use <leader> in mapping commands
let mapleader = ","
let g:mapleader = ","

" Set the number of commands vim has to remember
set history=999

" Script encoding to unicode
"scriptencoding utf-8


" ============================================================================
" } General

" Vundle and plugins
" Vundle {
" ============================================================================

" Setup Vundle
let s:bundle_path=$HOME."/.vim/bundle/"
execute "set rtp+=".s:bundle_path."vundle/"
call vundle#begin()

" let Vundle manage vundle
Bundle 'gmarik/vundle'

" CTRLP
" CTRLP {
    Bundle 'kien/ctrlp.vim'
    let g:ctrlp_map = '<c-p>'
    let g:ctrlp_cmd = 'CtrlP'
    let g:ctrlp_working_path_mode = 'ra'
    set wildignore+=*/tmp/*,*.so,*.swp,*.zip
" }

" NERDTREE
" NERDTREE {
    Bundle 'scrooloose/nerdtree'
    Bundle 'jistr/vim-nerdtree-tabs'
    map <C-e> <plug>NERDTreeTabsToggle<CR>
    map <leader>e :NERDTreeFind<CR>
    nmap <leader>nt :NERDTreeFind<CR>
    let NERDTreeShowBookmarks=1
    let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
    let NERDTreeChDirMode=0
    let NERDTreeQuitOnOpen=1
    let NERDTreeShowHidden=1
    let NERDTreeKeepTreeInNewTab=1
    let g:nerdtree_tabs_open_on_gui_startup=0

" }

" Fugitive
" Fugitive {
    Bundle 'tpope/vim-fugitive'
    nnoremap <silent> <leader>gs :Gstatus<CR>
    nnoremap <silent> <leader>gd :Gdiff<CR>
    nnoremap <silent> <leader>gc :Gcommit<CR>
    nnoremap <silent> <leader>gb :Gblame<CR>
    nnoremap <silent> <leader>gl :Glog<CR>
    nnoremap <silent> <leader>gp :Git push<CR>
    nnoremap <silent> <leader>gr :Gread<CR>:GitGutter<CR>
    nnoremap <silent> <leader>gw :Gwrite<CR>:GitGutter<CR>
    nnoremap <silent> <leader>ge :Gedit<CR>
    nnoremap <silent> <leader>gg :GitGutterToggle<CR>
" }

" Easymotions
" Easymotions {
	Bundle 'Lokaltog/vim-easymotion'
" }

" Surround
" Surround {
	Bundle 'tpope/vim-surround'
" }

" Trailing Whitespaces
" Trailing Whitespaces {
	Bundle 'bronson/vim-trailing-whitespace'
" }

" Numbers.vim
" Numbers.vim {
	Bundle 'myusuf3/numbers.vim'
" }

" Airline
" Airline {
	Bundle 'bling/vim-airline'
	let g:airline#extensions#tabline#enabled = 1
    let g:airline_theme = 'base16'    " :echo g:airline_theme_map for list
    let g:airline_left_sep = ''        " Slightly fancier than '>'
    let g:airline_right_sep = ''       " Slightly fancier than '<'
    let g:airline#extensions#tabline#left_sep = ''
    let g:airline#extensions#tabline#left_alt_sep = ''
" }

" Colorschemes
" Colorschemes {
	Bundle 'altercation/vim-colors-solarized'
	Bundle 'flazz/vim-colorschemes'
" }

" Autoclose
" Autoclose {
    Bundle 'spf13/vim-autoclose'
    let g:autoclose_vim_commentmode = 1 " adjust for comment in vimfiles
"}

" NERDcommenter
" NERDcommenter {
    Bundle 'scrooloose/nerdcommenter'
" }

" LaTeX
" LaTeX {
    Bundle 'jcf/vim-latex'
    let g:tex_flavor='latex'
    let g:tex_conceal = ""
" }

" Markdown
" Markdown {
    Bundle 'tpope/vim-markdown'
    Bundle 'spf13/vim-preview'
" }

" Tmuxline
" Tmuxline {
    Bundle 'edkolev/tmuxline.vim'
    " tune airline separators for tmuxline
    let g:tmuxline_separators = {
        \ 'left' : '',
        \ 'left_alt': '>',
        \ 'right' : '',
        \ 'right_alt' : '<',
        \ 'space' : ' '}
" }

" Julia Plugin
" Julia Lang {
    Plugin 'JuliaLang/julia-vim'
" }

" Base 16
" Base 16 {
    Bundle 'chriskempson/base16-vim'
    let base16colorspace=256  " Access colors present in 256 colorspace
" }

" Synatstic
" Syntastic {
    Bundle 'scrooloose/syntastic'
" }

call vundle#end()
" ============================================================================
" } Vundle

" Enable filetypes plugins to automatically detect file types
filetype plugin on
filetype indent on


" Settings for the vim user interface
" UI "{
" ============================================================================

" Assume a dark background
set background=dark

if has('cmd_info')
    " Always show the current cursor position
    set ruler
    set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " taken from spf13-vim

    " Show partial commands in statusline and selected chars/lines in
    " visual mode
    set showcmd
endif

" Enable syntax coloring
syntax on

" Set the height of the command bar to 2 lines instead of the
" default 1
set cmdheight=2

" Disable sound and visual bell on errors
set noerrorbells
set novisualbell

" Highlight matching brakets when cursor is over them
set showmatch
set mat=2 " * 0.1 seconds blinking when brakets are matched

" Display the current mode
set showmode

" Maximum number of tabs to show
set tabpagemax=10

" Enable line numbers
set number

" Search "{
    set hlsearch    " Highlight search terms
    set ignorecase  " Case insensitive searching
    set incsearch   " Search like modern browser (moving while typing)
    set smartcase   " Case sensitive when uc present
" } Search

" Wild Menu {
    set wildmenu                    " enable the wild menu
    set wildignore=*.o,*.pyc,*~     " ignore compiled files
    set wildmode=list:longest,full  " taken from spf13-vim
" }

" Lines to jump when cursor leaves the screen
set scrolljump=5

" Min number of lines to keep above and below the cursor
set scrolloff=3

" Statusline {
    if has('statusline')
        set laststatus=2

        " Broken down into easily includeable segments
        set statusline=%<%f\                        " Filename
        set statusline+=%w%h%m%r                    " Options
        set statusline+=%{fugitive#statusline()}    " Git Hotness
        set statusline+=\[%{&ff}/%Y]                " Filetype
        set statusline+=\[%{getcwd()}]              " Current dir
        set statusline+=%=%-14.(%l,%c%V%)\ %p%%     " Right aligned nav info
    endif
" }

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions+=e
    set t_Co=256
    set guitablabel=%M\ %t
else
    set term=xterm-256color
    set t_Co=256
endif

" Set a colorscheme
"colorscheme  ir_black
let g:base16_shell_path="/home/gdmsl/.base16/output/shell/"
colorscheme base16-monokai

" Always enable folding
set foldenable
set fdm=syntax


" Color the 80th column
set colorcolumn=80

" ============================================================================
" }

" Settings relative to text formatting, tabs, indentations and editing
" behaivour
" Editing "{
" ============================================================================

" Backspace for dummies
set backspace=indent,eol,start

set wrap            " Wrap long lines
set autoindent      " Use auto indentation
set smartindent     " Use smart indentation
set expandtab       " Insert spaces instead of tabs
set smarttab        " Be smart when using tabs
set shiftwidth=4    " Indents of 4 spaces
set tabstop=4       " An indent every 4 columns
set softtabstop=4   " Let Bakspace delete an indentation

" Encoding for the current file
set encoding=utf8

" Use UNIX as default file type
set ffs=unix,dos,mac
"
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

" ============================================================================
" } Editing

" Movement related keys (re)mapping
" Movements {
" ============================================================================

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
" check the wiki. But, no matter what o stand for and no matter in what
" mode do you are, you will never be allowed to use arrow keys for
" movements!
onoremap <left> <nop>
onoremap <up> <nop>
onoremap <down> <nop>
onoremap <right> <nop>

" Less god like mode - change the escape key to jj in
" command and insert mode and to v in visual mode
ino jj <esc>
cno jj <c-c>
vno v <esc>

" ============================================================================
" }

" Files and Backups
" Backups {
" ============================================================================

" Let's assume that you are ever using git or another vms
" so you do not need backups
set nobackup

" Let's assume that you always know where you are writing and
" what you are overwriting
set nowritebackup

" ============================================================================
" }
