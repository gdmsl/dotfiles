" vim: set ft=vim sw=4 ts=4 sts=4 et tw=78 fdm=marker fdl=0 foldmarker={{{,}}} :
"
"   .nvimrc
"   AUTHOR: Guido Masella <guido.masella@gmail.com>
"
" Plugins --------------------------------------------------------------------

" LoadPlugins {{{
" Add the dein installation directory into runtimepath
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.cache/dein')
    call dein#begin('~/.cache/dein')

    call dein#add('~/.cache/dein')

    call dein#add('wsdjeg/dein-ui.vim')
    call dein#add('ctrlpvim/ctrlp.vim')
    call dein#add('scrooloose/nerdtree')
    call dein#add('jistr/vim-nerdtree-tabs')
    call dein#add('tpope/vim-fugitive')
    call dein#add('tpope/vim-surround')
    call dein#add('bronson/vim-trailing-whitespace')
    call dein#add('myusuf3/numbers.vim')
    call dein#add('vim-airline/vim-airline')
    call dein#add('vim-airline/vim-airline-themes')
    call dein#add('jiangmiao/auto-pairs')
    call dein#add('scrooloose/nerdcommenter')
    call dein#add('lervag/vimtex')
    call dein#add('JuliaLang/julia-vim')
    call dein#add('chriskempson/base16-vim')
    "linting
    "call dein#add('benekastah/neomake')
    call dein#add('w0rp/ale')
    call dein#add('tpope/vim-markdown')
    call dein#add('sudar/vim-arduino-syntax')
    call dein#add('easymotion/vim-easymotion')
    call dein#add('kien/rainbow_parentheses.vim')
    call dein#add('majutsushi/tagbar')
    call dein#add('vim-scripts/loremipsum')
    " BEGIN completition manager
    call dein#add('ncm2/ncm2')
    call dein#add('roxma/nvim-yarp')
    call dein#add('ncm2/ncm2-path')
    call dein#add('ncm2/ncm2-bufword')
    call dein#add('ncm2/ncm2-racer')
    call dein#add('ncm2/ncm2-pyclang')
    call dein#add('ncm2/ncm2-jedi')
    " END completition manager
    call dein#add('mhinz/vim-signify')
    call dein#add('rust-lang/rust.vim')
    call dein#add('kana/vim-arpeggio')
    call dein#add('mileszs/ack.vim')
    call dein#add('rhysd/vim-clang-format')
    call dein#add('chrisbra/csv.vim')
    call dein#add('uplus/vim-clang-rename')
    call dein#add('cespare/vim-toml')
    call dein#add('vimwiki/vimwiki')
    call dein#add('mhinz/vim-startify')

    call dein#end()
    call dein#save_state()
endif
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
"augroup autoclose_config
    "autocmd!
    "let g:autoclose_vim_commentmode = 1
"augroup END
" }}}

" LaTeX {{{
augroup latex_config
    autocmd!
    let g:vimtex_fold_enabled = 1
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

" Ale {{{
augroup ale_config
    autocmd!
    let g:ale_c_parse_compile_commands = 1
    let g:ale_linters = { 'cpp': ['clangtidy'] }
    let g:ale_c_build_dir_names = ['build', 'release', 'debug']
augroup END
" }}}

" Tagbar {{{
augroup tagbar_config
    autocmd!
    nmap <F8> :TagbarToggle<CR>
    let g:tagbar_type_julia = {
        \ 'ctagstype' : 'julia',
        \ 'kinds'     : [
        \ 't:struct', 'f:function', 'm:macro', 'c:const']
        \ }
    let g:tagbar_type_rust = {
        \ 'ctagstype' : 'rust',
        \ 'kinds' : [
            \'T:types,type definitions',
            \'f:functions,function definitions',
            \'g:enum,enumeration names',
            \'s:structure names',
            \'m:modules,module names',
            \'c:consts,static constants',
            \'t:traits',
            \'i:impls,trait implementations',
            \]
        \}
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

" ClangFormat {{{
augroup clangformat_config
    autocmd!
    " map to <Leader>cf in C++ code
    autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
    autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
    " if you install vim-operator-user
    " autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
    " Toggle auto formatting:
    " nmap <Leader>C :ClangFormatAutoToggle<CR>
    " autocmd FileType c,cpp,objc ClangFormatAutoEnable
    let g:clang_format#code_style = 'mozilla'
augroup END
" }}}

" NCM2 {{{
augroup ncm2_config
    autocmd!

    " enable ncm2 for all buffers
    autocmd BufEnter * call ncm2#enable_for_buffer()

    " IMPORTANTE: :help Ncm2PopupOpen for more information
    set completeopt=noinsert,menuone,noselect

    " suppress the annoying 'match x of y', 'The only match' and 'Pattern not
    " found' messages
    set shortmess+=c

    " CTRL-C doesn't trigger the InsertLeave autocmd . map to <ESC> instead.
    inoremap <c-c> <ESC>

    " When the <Enter> key is pressed while the popup menu is visible, it only
    " hides the menu. Use this mapping to close the menu and also start a new
    " line.
    inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")

    " Use <TAB> to select the popup menu:
    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    " a list of relative paths looking for .clang_complete
    let g:ncm2_pyclang#args_file_path = ['.clang_complete']

    " goto declaration
    autocmd FileType c,cpp nnoremap <buffer> gd :<c-u>call ncm2_pyclang#goto_declaration()<cr>
augroup END
" }}}

" VimWiki {{{
augroup vimwiki_config
    autocmd!
    let g:vimwiki_list = [{'path': '~/log/bwiki/', 'template_path' : '~/log/bwiki/templates'}]
augroup END
" }}}

" Settings -------------------------------------------------------------------

" NeoVim {{{
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif
if &term =~ '256color'
    set t_Co=256
    " Disable Background Color Erase (BCE) so that color schemes
    " work properly when Vim is used inside tmux and GNU screen.
    set t_ut=
endif
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
set background=dark
syntax on
let base16colorspace=256  " Access colors present in 256 colorspace
colorscheme base16-onedark
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
set exrc
set secure
filetype plugin on
filetype indent on

" }}}

" TextFiles {{{
augroup text_files
    autocmd FileType text setlocal textwidth=78
augroup END
" }}}

