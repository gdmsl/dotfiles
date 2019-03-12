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

    " Fuzzy
    call dein#add('Shougo/denite.nvim', {'merged' : 0})
    call dein#add('pocari/vim-denite-emoji', {'merged' : 0})
    call dein#add('Shougo/neoyank.vim', {'merged' : 0})
    call dein#add('chemzqm/unite-location', {'merged' : 0})
    call dein#add('ozelentok/denite-gtags', {'merged' : 0})
    call dein#add('Shougo/neomru.vim', {'merged' : 0})

    " File manager
    call dein#add('scrooloose/nerdtree')
    call dein#add('Xuyuanp/nerdtree-git-plugin')

    " Git
    call dein#add('junegunn/gv.vim', { 'on_cmd' : 'GV' })
    call dein#add('lambdalisue/gina.vim', { 'on_cmd' : 'Gina'})

    " Colors
    call dein#add('joshdick/onedark.vim')

    " Sudo
    call dein#add('lambdalisue/suda.vim')

    " LSP
    call  dein#add('prabirshrestha/async.vim')
    call  dein#add('prabirshrestha/vim-lsp')

	" Autocomplete
    call dein#add('prabirshrestha/asyncomplete.vim')
    call dein#add('prabirshrestha/asyncomplete-lsp.vim')

    " Autocomplete Sources
    call dein#add('Shougo/neosnippet.vim')
    call dein#add('Shougo/neosnippet-snippets')
    call dein#add('Shougo/neoinclude.vim')
    call dein#add('prabirshrestha/asyncomplete-buffer.vim')
    call dein#add('prabirshrestha/asyncomplete-emoji.vim')
    call dein#add('prabirshrestha/asyncomplete-file.vim')
    call dein#add('prabirshrestha/asyncomplete-neosnippet.vim')
    call dein#add('kyouryuukunn/asyncomplete-neoinclude.vim')

    call dein#add('Raimondi/delimitMate', {
                \ 'merged' : 0
                \ })
    call dein#add('Shougo/echodoc.vim', {
                \ 'merged' : 0
                \ })

    " Syntax checking
    call dein#add('neomake/neomake', {
                \ 'merged' : 0, 'loadconf' : 1 , 'loadconf_before' : 1
                \ })

    " Languages
    call dein#add('JuliaEditorSupport/julia-vim')
    call dein#add('lervag/vimtex', {
                \ 'on_ft': 'tex'
                \ })
    call dein#add('rust-lang/rust.vim', {
                \ 'on_ft': 'rust'
                \ })
    call dein#add('chrisbra/csv.vim', {
                \ 'on_ft': 'csv'
                \ })
    call dein#add('rhysd/vim-clang-format')
    call dein#add('uplus/vim-clang-rename')
    call dein#add('cespare/vim-toml')

    " Markdown
    call dein#add('SpaceVim/vim-markdown', {
                \ 'on_ft' : 'markdown'
                \ })
    call dein#add('joker1007/vim-markdown-quote-syntax',{
                \ 'on_ft' : 'markdown'
                \ })
    call dein#add('mzlogin/vim-markdown-toc',{
                \ 'on_ft' : 'markdown'
                \ })
    call dein#add('iamcco/mathjax-support-for-mkdp',{
                \ 'on_ft' : 'markdown'
                \ })
    call dein#add('iamcco/markdown-preview.vim', {
                \ 'depends' : 'open-browser.vim',
                \ 'on_ft' : 'markdown'
                \ })
    call dein#add('lvht/tagbar-markdown',{
                \ 'merged' : 0
                \ })

    " Python
    call dein#add('zchee/deoplete-jedi', {
                \ 'on_ft' : 'python'
                \ })
    call dein#add('davidhalter/jedi-vim', {
                \ 'on_ft' : 'python', 'if' : has('python') || has('python3')
                \ })
    call dein#add('heavenshell/vim-pydocstring', {
                \ 'on_cmd' : 'Pydocstring'
                \ })
    call dein#add('Vimjas/vim-python-pep8-indent',  {
                \ 'on_ft' : 'python'
                \ })

    " Text utilities
    call dein#add('myusuf3/numbers.vim')
    call dein#add('tpope/vim-surround')
    call dein#add('bronson/vim-trailing-whitespace')
    call dein#add('vim-airline/vim-airline')
    call dein#add('vim-airline/vim-airline-themes')
    call dein#add('jiangmiao/auto-pairs')
    call dein#add('scrooloose/nerdcommenter')


    "linting
    "call dein#add('benekastah/neomake')
    call dein#add('w0rp/ale')
    call dein#add('tpope/vim-markdown')
    call dein#add('sudar/vim-arduino-syntax')
    call dein#add('easymotion/vim-easymotion')
    call dein#add('kien/rainbow_parentheses.vim')
    call dein#add('majutsushi/tagbar')
    call dein#add('vim-scripts/loremipsum')
    call dein#add('mhinz/vim-signify')
    call dein#add('kana/vim-arpeggio')
    call dein#add('mileszs/ack.vim')
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
  let g:airline_theme = 'onedark'
augroup END
" }}}

" Fuzzy{{{
augroup fuzzy_config
	autocmd!


    " denite option
    let s:denite_options = {
          \ 'default' : {
          \ 'winheight' : 15,
          \ 'mode' : 'insert',
          \ 'quit' : 1,
          \ 'highlight_matched_char' : 'MoreMsg',
          \ 'highlight_matched_range' : 'MoreMsg',
          \ 'direction': 'rightbelow',
          \ 'statusline' : has('patch-7.4.1154') ? v:false : 0,
          \ }}
    function! s:profile(opts) abort
        for fname in keys(a:opts)
            for dopt in keys(a:opts[fname])
                call denite#custom#option(fname, dopt, a:opts[fname][dopt])
            endfor
        endfor
    endfunction

    call s:profile(s:denite_options)

    " buffer source
    call denite#custom#var(
                \ 'buffer',
                \ 'date_format', '%m-%d-%Y %H:%M:%S')

    call denite#custom#alias('source', 'file_rec/git', 'file_rec')
    call denite#custom#var('file_rec/git', 'command',
                \ ['git', 'ls-files', '-co', '--exclude-standard'])

    " KEY MAPPINGS
    let s:insert_mode_mappings = [
                \ ['jk', '<denite:enter_mode:normal>', 'noremap'],
                \ ['<Tab>', '<denite:move_to_next_line>', 'noremap'],
                \ ['<C-j>', '<denite:move_to_next_line>', 'noremap'],
                \ ['<S-tab>', '<denite:move_to_previous_line>', 'noremap'],
                \ ['<C-k>', '<denite:move_to_previous_line>', 'noremap'],
                \ ['<C-t>', '<denite:do_action:tabopen>', 'noremap'],
                \ ['<C-v>', '<denite:do_action:vsplit>', 'noremap'],
                \ ['<C-s>', '<denite:do_action:split>', 'noremap'],
                \ ['<Esc>', '<denite:enter_mode:normal>', 'noremap'],
                \ ['<C-N>', '<denite:assign_next_matched_text>', 'noremap'],
                \ ['<C-P>', '<denite:assign_previous_matched_text>', 'noremap'],
                \ ['<Up>', '<denite:assign_previous_text>', 'noremap'],
                \ ['<Down>', '<denite:assign_next_text>', 'noremap'],
                \ ['<C-Y>', '<denite:redraw>', 'noremap'],
                \ ]

    let s:normal_mode_mappings = [
                \ ["'", '<denite:toggle_select_down>', 'noremap'],
                \ ['<C-n>', '<denite:jump_to_next_source>', 'noremap'],
                \ ['<C-p>', '<denite:jump_to_previous_source>', 'noremap'],
                \ ['<Tab>', '<denite:move_to_next_line>', 'noremap'],
                \ ['<C-j>', '<denite:move_to_next_line>', 'noremap'],
                \ ['<S-tab>', '<denite:move_to_previous_line>', 'noremap'],
                \ ['<C-k>', '<denite:move_to_previous_line>', 'noremap'],
                \ ['gg', '<denite:move_to_first_line>', 'noremap'],
                \ ['<C-t>', '<denite:do_action:tabopen>', 'noremap'],
                \ ['<C-v>', '<denite:do_action:vsplit>', 'noremap'],
                \ ['<C-s>', '<denite:do_action:split>', 'noremap'],
                \ ['q', '<denite:quit>', 'noremap'],
                \ ['r', '<denite:redraw>', 'noremap'],
                \ ]

    for s:m in s:insert_mode_mappings
        call denite#custom#map('insert', s:m[0], s:m[1], s:m[2])
    endfor
    for s:m in s:normal_mode_mappings
        call denite#custom#map('normal', s:m[0], s:m[1], s:m[2])
    endfor

    unlet s:m s:insert_mode_mappings s:normal_mode_mappings

	" Fuzzy  find registers
	nnoremap <silent> <Space>e :<C-u>Denite register<CR>

    " Resume Denite window
    nnoremap <silent> <Space>r :<C-u>Denite -resume<CR>

	" Fuzzy find yank history
	nnoremap <silent> <Space>h :<C-u>Denite neoyank<CR>

	" Fuzzy find jump
	nnoremap <silent> <Space>j :<C-u>Denite jump<CR>

    " Fuzzy find location list
    nnoremap <silent> <Space>l :<C-u>Denite location_list<CR>

	" Fuzzy find quickfix list
	nnoremap <silent> <Space>q :<C-u>Denite quickfix<CR>

	" Fuzzy find message
	nnoremap <silent> <Space>m :<C-u>Denite output:message<CR>

	" Fuzzy find outline
	nnoremap <silent> <Space>o :<C-u>Denite outline<CR>

	" Fuzzy find buffers
	nnoremap <silent> <Space>b :Denite buffer<CR>
augroup END
" }}}

" LaTeX {{{
augroup latex_config
    autocmd!
    let g:vimtex_fold_enabled = 1
augroup END
" }}}

" Sudo {{{
augroup sudo_config
    autocmd!

    " Read current file with sudo
    nnoremap <silent> <leader>fE :e suda://&<CR>

    " Write current file with sudo
    nnoremap <silent> <leader>fW :w suda://&<CR>
augroup END
" }}}
"
" File Manager {{{
augroup filemanager_config
    noremap <silent> <C-e> :NERDTreeToggle<CR>

    "automatically open when vim starts in a directory
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
augroup END
" }}}

" Git {{{
augroup git_config
    " This group contains the gina and GV configurations
    autocmd!
    nnoremap <silent> <leader>gs :Gina status --opener=10split<CR>
    nnoremap <silent> <leader>gS :Gina add %<CR>
    nnoremap <silent> <leader>gU :Gina reset -q %<CR>
    nnoremap <silent> <leader>gc :Gina commit<CR>
    nnoremap <silent> <leader>gp :Gina push<CR>
    nnoremap <silent> <leader>gp :Gina push<CR>
    nnoremap <silent> <leader>gd :Gina diff<CR>
    nnoremap <silent> <leader>gA :Gina add .<CR>
    nnoremap <silent> <leader>gb :Gina blame<CR>
    autocmd FileType diff nnoremap <buffer><silent> q :bd!<CR>
    " Instead of reverting the cursor to the last position in the buffer, we
    " set it to the first line when editing a git commit message
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

    " View git log of current file
    nnoremap <silent> <leader>gV :GV!<CR>

    " View git log of current repo
    nnoremap <silent> <leader>gv :GV<CR>
augroup END
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

" Autocomplete {{{
augroup autocomplete_config
    autocmd!

    " enable deoplete at startup
    let g:deoplete#enable_at_startup = 1

    " Register neosnippet as completition source
    call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
    \ 'name': 'neosnippet',
    \ 'whitelist': ['*'],
    \ 'completor': function('asyncomplete#sources#neosnippet#completor'),
    \ }))

    " Neosnippet trigger
    imap <C-k>     <Plug>(neosnippet_expand_or_jump)
    smap <C-k>     <Plug>(neosnippet_expand_or_jump)
    xmap <C-k>     <Plug>(neosnippet_expand_target)

    call asyncomplete#register_source(asyncomplete#sources#neoinclude#get_source_options({
    \ 'name': 'neoinclude',
    \ 'whitelist': ['cpp'],
    \ 'refresh_pattern': '\(<\|"\|/\)$',
    \ 'completor': function('asyncomplete#sources#neoinclude#completor'),
    \ }))

    call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
    \ 'name': 'file',
    \ 'whitelist': ['*'],
    \ 'priority': 10,
    \ 'completor': function('asyncomplete#sources#file#completor')
    \ }))

    call asyncomplete#register_source(asyncomplete#sources#emoji#get_source_options({
    \ 'name': 'emoji',
    \ 'whitelist': ['*'],
    \ 'completor': function('asyncomplete#sources#emoji#completor'),
    \ }))

augroup END
" }}}

" Syntax Checkers {{{
    " Full config: when writing or reading a buffer, and on changes in insert
    " and normal mode (after 1s; no delay when writing).
    call neomake#configure#automake('nrwi', 500)
" }}}

" LSP {{{
function SetLSPShortcuts()
  nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>
  nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
  nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
  nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
  nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
  nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
  nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
  nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
  nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
  nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>
endfunction()

augroup lsp_config
    autocmd!

    if executable('clangd')
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'clangd',
                    \ 'cmd': {server_info->['clangd']},
                    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
                    \ })
    endif

    if executable('php')
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'php-language-server',
                    \ 'cmd': {server_info->['php', expand('~/.vim/plugged/php-language-server/bin/php-language-server.php')]},
                    \ 'whitelist': ['php'],
                    \ })
    endif

    if executable('pyls')
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'pyls',
                    \ 'cmd': {server_info->['pyls']},
                    \ 'whitelist': ['python'],
                    \ 'workspace_config': {'pyls': {'plugins': {'pydocstyle': {'enabled': v:true}}}}
                    \ })
    endif

    if executable('rls')
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'rls',
                    \ 'cmd': {server_info->['rustup', 'run', 'stable', 'rls']},
                    \ 'whitelist': ['rust'],
                    \ })
    endif

    if executable('julia')
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'julia-language-server',
                    \ 'cmd': {server_info->['julia', '--startup-file=no', '--history-file=no', '-e', '
                    \       using LanguageServer;
                    \       using Pkg;
                    \       import StaticLint;
                    \       import SymbolServer;
                    \       env_path = dirname(Pkg.Types.Context().env.project_file);
                    \       debug = false;
                    \ 
                    \       server = LanguageServer.LanguageServerInstance(stdin, stdout, debug, env_path, "", Dict());
                    \       server.runlinter = true;
                    \       run(server);
                    \   ']},
                    \ 'whitelist': ['julia'],
                    \ })
    endif

    let g:echodoc#enable_at_startup = 1
    let g:echodoc#type = 'signature'
augroup END
" }}}

" Markdown {{{
augroup markdown_config
    " do not highlight markdown error
    let g:markdown_hi_error = 0
    " the fenced languages based on loaded language layer
    let g:markdown_fenced_languages = []
    let g:markdown_minlines = 100
    let g:markdown_syntax_conceal = 0
    let g:markdown_enable_mappings = 0
    let g:markdown_enable_insert_mode_leader_mappings = 0
    let g:markdown_enable_spell_checking = 0
    let g:markdown_quote_syntax_filetypes = {
                \ 'vim' : {'start' : "\\%(vim\\|viml\\)",},
                \ }
augroup END
" }}}

" Python {{{
augroup python_config
    autocmd!
    let g:jedi#completions_enabled = 0
    " If you execute :Pydocstring at no `def`, `class` line.
    " g:pydocstring_enable_comment enable to put comment.txt value.
    let g:pydocstring_enable_comment = 0

    " Disable this option to prevent pydocstring from creating any
    " key mapping to the `:Pydocstring` command.
    " Note: this value is overridden if you explicitly create a
    " mapping in your vimrc, such as if you do:
    let g:pydocstring_enable_mapping = 0

    " autoformat on save
    autocmd BufWritePost *.py Neoformat yapf
augroup END
" }}}

" Settings -------------------------------------------------------------------

" NeoVim {{{
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
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
set background=dark
syntax on
colorscheme onedark
" }}}

"Folding {{{
set foldenable
set fdm=syntax
"}}}

" Textwidth {{{
set colorcolumn=80
" }}}

" Scroll {{{
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

