" vim: set ft=vim sw=4 ts=4 sts=4 et tw=78 fdm=marker fdl=0 foldmarker={{{,}}} :
"
"   .nvimrc
"   AUTHOR: Guido Masella <guido.masella@gmail.com>
"
" Plugins --------------------------------------------------------------------

" LoadPlugins {{{
call plug#begin('.nvim/plugged')

Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'kien/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'bronson/vim-trailing-whitespace'
Plug 'myusuf3/numbers.vim'
Plug 'bling/vim-airline'
Plug 'flazz/vim-colorschemes'
Plug 'spf13/vim-autoclose'
Plug 'scrooloose/nerdcommenter'
Plug 'jcf/vim-latex'
Plug 'edkolev/tmuxline.vim'
Plug 'JuliaLang/julia-vim'
Plug 'chriskempson/base16-vim'
Plug 'benekastah/neomake'
Plug 'tpope/vim-markdown', {'for' : 'markdown'}
Plug 'scrooloose/syntastic'
Plug 'kien/rainbow_parentheses.vim'

call plug#end()
" }}}


" Plugin Configurations ------------------------------------------------------

" Airline {{{
augroup airline_config
  autocmd!
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#syntastic#enabled = 1
  let g:airline#extensions#tabline#buffer_nr_format = '%s '
  let g:airline#extensions#tabline#buffer_nr_show = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#fnamecollapse = 0
  let g:airline#extensions#tabline#fnamemod = ':t'
  let g:airline_theme = 'base16'
augroup END
" }}}

" CtrlP {{{
augroup ctrlp_config
  autocmd!
  let g:ctrlp_map = '<c-p>'
  let g:ctrlp_cmd = 'CtrlP'
  let g:ctrlp_working_path_mode = 'ra'
  set wildignore+=*/tmp/*,*.so,*.swp,*.zip
augroup END
" }}}

" Autoclose {{{
augroup autoclose_config
    autocmd!
    let g:autoclose_vim_commentmode = 1
augroup END
" }}}

" LaTeX {{{
augroup latex_config
    autocmd!
    let g:tex_flavor = 'latex'
    let g:tex_conceal = ''
augroup END
" }}}

" Tmuxline {{{
augroup tmuxline_config
    autocmd!
    let g:tmuxline_preset = 'full'
augroup END
" }}}

" Pandoc {{{
augroup pandoc_config
    autocmd!
    let g:pandoc#syntax#conceal#use = 0
augroup END
" }}}

" Base16 {{{
augroup base16_config
    let base16colorspace=256
    let g:base16_shell_path="~/.base16/"
augroup END
" }}}

" Fugitive {{{
augroup fugitive_config
    autocmd!
    nnoremap <silent> <leader>gs :Gstatus<CR>
    nnoremap <silent> <leader>gd :Gdiff<CR>
    nnoremap <silent> <leader>gc :Gcommit<CR>
    nnoremap <silent> <leader>gb :Gblame<CR>
    nnoremap <silent> <leader>gl :Glog<CR>
    nnoremap <silent> <leader>gp :Git push<CR>
    nnoremap <silent> <leader>gr :Gread<CR>:GitGlutter<CR>
    nnoremap <silent> <leader>gw :Gwrite<CR>:GitGlutter<CR>
    nnoremap <silent> <leader>ge :Gedit<CR>
    nnoremap <silent> <leader>gg :GitGlutterToggle<CR>
augroup END
" }}}

" NERDTREE {{{
augroup nerdtree_config
    autocmd!
    map <C-e> <plug>NERDTreeTabsToggle<CR>
    map <leader>e :NERDTreeFind<CR>
    nmap <leader>nt :NERDTreeFind<CR>
    let NERDTreeShowBookmarks = 1
    let NERDTreeIgnore = ['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
    let NERDTreeChDirMode = 0
    let NERDTreeQuitOnOpen = 1
    let NERDTreeShowHidden = 1
    let NERDTreeKeepTreeInNewTab = 1
    let g:nerdtree_tabs_open_on_gui_startup = 0
" }}}

" Syntastic {{{
augroup syntastic_config
  autocmd!
  let g:syntastic_error_symbol = '✗'
  let g:syntastic_warning_symbol = '⚠'
augroup END
" }}}

" Settings -------------------------------------------------------------------

" NeoVim {{{
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
" }}}

" Local Directories {{{
set backupdir=~/.nvim/backups
set directory=~/.nvim/swaps
set undodir=~/.nvim/undo
" }}}

" Mapleader {{{
let mapleader = ','
let g:mapleader = ','
" }}}

" Colorscheme {{{
set t_Co=256
set background=dark
syntax on
colorscheme base16-tomorrow
" }}}

"Folding {{{
set foldenable
set fdm=syntax
"}}}

" Textwidth {{{
set colorcolumn=80
" }}}

" Scrooll {{{
set scrolljump=5
set scrolloff=3
" }}}

" LineNumbers {{{
set number
" }}}

" Alarms {{{
set noerrorbells
set novisualbell
" }}}

" HighlightBrakets {{{
set showmatch
set mat=2
" }}}

" Search {{{
set ignorecase
set incsearch
set smartcase
" }}}

" CommandBar {{{
set cmdheight=2
" }}}

" SetEditor {{{
set nospell
set backspace=indent,eol,start
set wrap
set autoindent
set smartindent
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set softtabstop=4
" }}}

" ArrowKeys {{{
noremap <left> <nop>
noremap <up> <nop>
noremap <down> <nop>
noremap <right> <nop>

inoremap <left> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <right> <nop>

vnoremap <left> <nop>
vnoremap <up> <nop>
vnoremap <down> <nop>
vnoremap <right> <nop>

onoremap <left> <nop>
onoremap <up> <nop>
onoremap <down> <nop>
onoremap <right> <nop>
" }}}

" FastSwitches {{{
ino jj <esc>
cno jj <c-c>
vno v <esc>
" }}}


" File Types -----------------------------------------------------------------

" General {{{
filetype plugin on
filetype indent on
" }}}

" TextFiles {{{
augroup text_files
    autocmd FileType text setlocal textwidth=78
augroup END
" }}}




