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

" Enable filetypes plugins to automatically detect file types
filetype plugin on
filetype indent on

" Script encoding to unicode
scriptencoding utf-8

" ============================================================================
" } General

" Vundle and plugins
" Vundle {
" ============================================================================

" Setup Vundle
let s:bundle_path=$HOME."/.vim/bundle/"
execute "set rtp+=".s:bundle_path."vundle/"
call vundle#rc()

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
	set number
" }

" Airline
" Airline {
	Bundle 'bling/vim-airline'
	let g:airline#extensions#tabline#enabled = 1
    "let g:airline_theme = 'molokai'    " :echo g:airline_theme_map for list
    let g:airline_left_sep = '›'        " Slightly fancier than '>'
    let g:airline_right_sep = '‹'       " Slightly fancier than '<'
" }

" Colorschemes
" Colorschemes {
	Bundle 'altercation/vim-colors-solarized'
	Bundle 'flazz/vim-colorschemes'
    colorscheme tango
" }

" Autoclose
" Autoclose {
    Bundle 'spf13/vim-autoclose'
    let g:autoclose_vim_commentmode = 1 " adjust for comment in vimfiles
"}

" Neocomplcache
" Neocomplcache {
    Bundle 'Shougo/neocomplcache.vim'
    " Neocomplcache settings {
        " Disable AutoComplPop.
        let g:acp_enableAtStartup = 0
        " Use neocomplcache.
        let g:neocomplcache_enable_at_startup = 1
        " Use smartcase.
        let g:neocomplcache_enable_smart_case = 1
        " Set minimum syntax keyword length.
        let g:neocomplcache_min_syntax_length = 3
        let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

        " Enable heavy features.
        " Use camel case completion.
        "let g:neocomplcache_enable_camel_case_completion = 1
        " Use underbar completion.
        "let g:neocomplcache_enable_underbar_completion = 1

        " Define dictionary.
        let g:neocomplcache_dictionary_filetype_lists = {
            \ 'default' : '',
            \ 'vimshell' : $HOME.'/.vimshell_hist',
            \ 'scheme' : $HOME.'/.gosh_completions'
                \ }

        " Define keyword.
        if !exists('g:neocomplcache_keyword_patterns')
            let g:neocomplcache_keyword_patterns = {}
        endif
        let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

        " Plugin key-mappings.
        inoremap <expr><C-g>     neocomplcache#undo_completion()
        inoremap <expr><C-l>     neocomplcache#complete_common_string()

        " Recommended key-mappings.
        " <CR>: close popup and save indent.
        inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
        function! s:my_cr_function()
          return neocomplcache#smart_close_popup() . "\<CR>"
          " For no inserting <CR> key.
          "return pumvisible() ? neocomplcache#close_popup() : "\<CR>"
        endfunction
        " <TAB>: completion.
        inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
        " <C-h>, <BS>: close popup and delete backword char.
        inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
        inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
        inoremap <expr><C-y>  neocomplcache#close_popup()
        inoremap <expr><C-e>  neocomplcache#cancel_popup()
        " Close popup by <Space>.
        "inoremap <expr><Space> pumvisible() ? neocomplcache#close_popup() : "\<Space>"

        " For cursor moving in insert mode(Not recommended)
        "inoremap <expr><Left>  neocomplcache#close_popup() . "\<Left>"
        "inoremap <expr><Right> neocomplcache#close_popup() . "\<Right>"
        "inoremap <expr><Up>    neocomplcache#close_popup() . "\<Up>"
        "inoremap <expr><Down>  neocomplcache#close_popup() . "\<Down>"
        " Or set this.
        "let g:neocomplcache_enable_cursor_hold_i = 1
        " Or set this.
        "let g:neocomplcache_enable_insert_char_pre = 1

        " AutoComplPop like behavior.
        "let g:neocomplcache_enable_auto_select = 1

        " Shell like behavior(not recommended).
        "set completeopt+=longest
        "let g:neocomplcache_enable_auto_select = 1
        "let g:neocomplcache_disable_auto_complete = 1
        "inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

        " Enable omni completion.
        autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
        autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
        autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
        autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
        autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

        " Enable heavy omni completion.
        if !exists('g:neocomplcache_omni_patterns')
          let g:neocomplcache_omni_patterns = {}
        endif
        let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
        let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
        let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

        " For perlomni.vim setting.
        " https://github.com/c9s/perlomni.vim
        let g:neocomplcache_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
    "}

    Bundle 'Shougo/neosnippet'
    Bundle 'Shougo/neosnippet-snippets'
    Bundle 'honza/vim-snippets'

    " Snippets {
        " Use honza's snippets.
        let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

        " Enable neosnippet snipmate compatibility mode
        let g:neosnippet#enable_snipmate_compatibility = 1

        " Plugin key-mappings.
        imap <C-k>     <Plug>(neosnippet_expand_or_jump)
        smap <C-k>     <Plug>(neosnippet_expand_or_jump)
        xmap <C-k>     <Plug>(neosnippet_expand_target)

        " SuperTab like snippets behavior.
        imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
        \ "\<Plug>(neosnippet_expand_or_jump)"
        \: pumvisible() ? "\<C-n>" : "\<TAB>"
        smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
        \ "\<Plug>(neosnippet_expand_or_jump)"
        \: "\<TAB>"

        " For snippet_complete marker.
        if has('conceal')
            set conceallevel=2 concealcursor=i
        endif

        " Disable the neosnippet preview candidate window
        " When enabled, there can be too much visual noise
        " especially when splits are used.
        set completeopt-=preview
    " }
" }

" NERDcommenter
" NERDcommenter {
    Bundle 'scrooloose/nerdcommenter'
" }

" Python
" Python {
    Bundle 'klen/python-mode'
    " Disable if python support not present
    if !has('python')
       let g:pymode = 0
    endif
    Bundle 'python.vim'
    Bundle 'python_match.vim'
    Bundle 'pythoncomplete'
" }

" LaTeX
" LaTeX {
    " Bundle 'jcf/vim-latex'
    " let g:tex_flavor='latex'
" }

" Markdown
" Markdown {
    Bundle 'tpope/vim-markdown'
    Bundle 'spf13/vim-preview'
" }

" ============================================================================
" } Vundle

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
endif

" Always enable folding
set foldenable

" Enable syntax coloring
syntax on

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
