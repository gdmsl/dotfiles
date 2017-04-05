" vim: set ft=vim sw=4 ts=4 sts=4 et tw=78 fdm=marker fdl=0 foldmarker={{{,}}} :
"
"   .nvimrc
"   AUTHOR: Guido Masella <guido.masella@gmail.com>
"
" Plugins --------------------------------------------------------------------

" LoadPlugins {{{
call plug#begin('~/.config/nvim/plugged')

Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'bronson/vim-trailing-whitespace'
Plug 'myusuf3/numbers.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'flazz/vim-colorschemes'
Plug 'spf13/vim-autoclose'
Plug 'scrooloose/nerdcommenter'
Plug 'lervag/vimtex'
"Plug 'edkolev/tmuxline.vim'
Plug 'JuliaLang/julia-vim'
Plug 'chriskempson/base16-vim'
Plug 'benekastah/neomake'
Plug 'tpope/vim-markdown', {'for' : 'markdown'}
"Plug 'scrooloose/syntastic'
Plug 'sudar/vim-arduino-syntax'
Plug 'easymotion/vim-easymotion'
Plug 'kien/rainbow_parentheses.vim'
Plug 'majutsushi/tagbar'
Plug 'vim-scripts/loremipsum'
"Plug 'justmao945/vim-clang'
Plug 'roxma/clang_complete'
Plug 'roxma/nvim-completion-manager'
"Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-signify'
Plug 'rust-lang/rust.vim'
Plug 'kana/vim-arpeggio'
Plug 'mileszs/ack.vim'

call plug#end()
" }}}

" Plugin Configurations ------------------------------------------------------

" Airline {{{
augroup airline_config
  autocmd!
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#syntastic#enabled = 0
  let g:airline#extensions#tabline#buffer_nr_format = '%s '
  let g:airline#extensions#tabline#buffer_nr_show = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#fnamecollapse = 0
  let g:airline#extensions#tabline#fnamemod = ':t'
  "let g:airline#extensions#tmuxline#enabled = 0
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
  let g:ctrlp_custom_tag_files = '.git/tags'
  noremap <silent> <leader>b :CtrlPBuffer<CR>
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
    let g:vimtex_fold_enabled = 1
augroup END
" }}}

" Tmuxline {{{
"augroup tmuxline_config
    "autocmd!
    "let g:tmuxline_preset = 'minimal'
"augroup END
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
    "let g:base16_shell_path="~/.base16/"
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
"augroup syntastic_config
"  autocmd!
"  let g:syntastic_error_symbol = '✗'
"  let g:syntastic_warning_symbol = '⚠'
"  let g:syntastic_cpp_compiler_options = '-std=c++11'
"augroup END
" }}}

" NeoMake {{{
augroup neomake_config
    autocmd! BufWritePost * Neomake
    let g:neomake_cpp_enabled_makers = ['clang']
	let g:neomake_c_enabled_makers = ['clang']
    "let g:neomake_cpp_enabled_makers = ['clangtidy']
    "let g:neomake_cpp_clangtidy_args = ['-checks="*"', '--', '-std=c++14', '-Isrc', '-I.']
    "let g:neomake_c_enabled_makers = ['clangtidy']
    "let g:neomake_c_clangtidy_args = ['-checks="*"', '--', '-Isrc', '-I.']
augroup END
" }}}

" Tagbar {{{
augroup tagbar_config
    autocmd!
    nmap <F8> :TagbarToggle<CR>
augroup END
" }}}

" Easymotions {{{
augroup easymotion_config
    autocmd!
augroup END
" }}}

" RustLang {{{
augroup rust_config
    autocmd!
augroup END
" }}}

" Arpeggio {{{
augroup arpeggio_config
    autocmd!
    call arpeggio#map('i', '', 0, 'jk', '<Esc>')
    "let g:arpeggio_timeoutlen=20
augroup END
" }}}

" Ack {{{
augroup ack_config
    autocmd!
    let g:ackprg = 'ag --nogroup --nocolor --column'
augroup END
" }}}


" Settings -------------------------------------------------------------------

" NeoVim {{{
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
set termguicolors
" }}}

" Backups and Swap files {{{
set backupdir=/tmp/neovim///
set directory=/tmp/neovim//
set undodir=/tmp/neovim//
" }}}

" Mapleader {{{
"let mapleader = ','
"let g:mapleader = ','
" }}}

" Colorscheme {{{
set t_Co=256
set background=dark
syntax on
colorscheme base16-eighties
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
"ino jj <esc>
"cno jj <c-c>
vno v <esc>
" }}}

" Use The Silver Searcher {{{
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag -Q -l --nocolor --hidden -g "" %s'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0

  if !exists(":Ag")
    command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
    nnoremap \ :Ag<SPACE>
  endif
endif
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

