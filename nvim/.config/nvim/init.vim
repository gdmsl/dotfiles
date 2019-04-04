" vim: set ft=vim sw=4 ts=4 sts=4 et tw=78 fdm=marker fdl=0 foldmarker={{{,}}} :
"
"   .nvimrc
"   AUTHOR: Guido Masella <guido.masella@gmail.com>
"

" LoadPlugins {{{
" Add the dein installation directory into runtimepath
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('~/.cache/dein')
    call dein#begin('~/.cache/dein')

    call dein#add('~/.cache/dein')

    " Movement
    call dein#add('justinmk/vim-sneak')

    " Fuzzy
    call dein#add('Shougo/denite.nvim', {'merged' : 0})
    call dein#add('pocari/vim-denite-emoji', {'merged' : 0})
    call dein#add('Shougo/neoyank.vim', {'merged' : 0})
    call dein#add('chemzqm/unite-location', {'merged' : 0})
    call dein#add('ozelentok/denite-gtags', {'merged' : 0})
    call dein#add('Shougo/neomru.vim', {'merged' : 0})

    " File manager
    call dein#add('Shougo/defx.nvim')

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
    call dein#add('ntpeters/vim-better-whitespace')
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
    call dein#add('liuchengxu/vista.vim')
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

" Settings {{{
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading\ -S
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
" }}}

" Movement plugins {{{
let g:sneak#label = 1
" }}}

" Airline {{{
let g:airline_powerline_fonts = 1
let g:airline#extensions#syntastic#enabled = 0
let g:airline#extensions#tabline#buffer_nr_format = '%s '
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamecollapse = 0
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline_theme = 'onedark'
" }}}

" Fuzzy{{{
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

" Fuzzy  find registers
nnoremap <silent> <Space>p :<C-u>Denite file/rec<CR>

" Fuzzy find quickfix list
nnoremap <silent> <Space>q :<C-u>Denite quickfix<CR>

" Fuzzy find message
nnoremap <silent> <Space>m :<C-u>Denite output:message<CR>

" Fuzzy find outline
nnoremap <silent> <Space>o :<C-u>Denite outline<CR>

" Fuzzy find buffers
nnoremap <silent> <Space>b :Denite buffer<CR>
" }}}

" LaTeX {{{
let g:vimtex_fold_enabled = 1
" }}}

" Sudo {{{
" Read current file with sudo
nnoremap <silent> <leader>fE :e suda://&<CR>

" Write current file with sudo
nnoremap <silent> <leader>fW :w suda://&<CR>
" }}}
"
" File Manager {{{

" disable netrw.vim
let g:loaded_netrwPlugin = 1

function! s:defx_my_settings() abort
  " Define mappings
  nnoremap <silent><buffer><expr> <CR>
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> c
  \ defx#do_action('copy')
  nnoremap <silent><buffer><expr> m
  \ defx#do_action('move')
  nnoremap <silent><buffer><expr> p
  \ defx#do_action('paste')
  nnoremap <silent><buffer><expr> l
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> E
  \ defx#do_action('open', 'vsplit')
  nnoremap <silent><buffer><expr> P
  \ defx#do_action('open', 'pedit')
  nnoremap <silent><buffer><expr> o
  \ defx#do_action('open_or_close_tree')
  nnoremap <silent><buffer><expr> K
  \ defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> N
  \ defx#do_action('new_file')
  nnoremap <silent><buffer><expr> M
  \ defx#do_action('new_multiple_files')
  nnoremap <silent><buffer><expr> C
  \ defx#do_action('toggle_columns',
  \                'mark:filename:type:size:time')
  nnoremap <silent><buffer><expr> S
  \ defx#do_action('toggle_sort', 'time')
  nnoremap <silent><buffer><expr> d
  \ defx#do_action('remove')
  nnoremap <silent><buffer><expr> r
  \ defx#do_action('rename')
  nnoremap <silent><buffer><expr> !
  \ defx#do_action('execute_command')
  nnoremap <silent><buffer><expr> x
  \ defx#do_action('execute_system')
  nnoremap <silent><buffer><expr> yy
  \ defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> .
  \ defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> ;
  \ defx#do_action('repeat')
  nnoremap <silent><buffer><expr> h
  \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> ~
  \ defx#do_action('cd')
  nnoremap <silent><buffer><expr> q
  \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> <Space>
  \ defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> *
  \ defx#do_action('toggle_select_all')
  nnoremap <silent><buffer><expr> j
  \ line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k
  \ line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer><expr> <C-l>
  \ defx#do_action('redraw')
  nnoremap <silent><buffer><expr> <C-g>
  \ defx#do_action('print')
  nnoremap <silent><buffer><expr> cd
  \ defx#do_action('change_vim_cwd')
endfunction

augroup defx_config
    autocmd!
    autocmd FileType defx call s:defx_my_settings()
augroup END

nnoremap <silent>- :Defx `expand('%:p:h')` -show-ignored-files -search=`expand('%:p')`<CR>
nnoremap <Leader>- :Defx -split=vertical -winwidth=50 -direction=topleft<CR>

" }}}

" Trailing Whitespaces {{{

let g:better_whitespace_filetypes_blacklist=['defx', 'diff', 'gitcommit', 'unite', 'qf', 'help']

" }}}

" Git {{{
augroup git_config
    " This group contains the gina and GV configurations
    autocmd!
    autocmd FileType diff nnoremap <buffer><silent> q :bd!<CR>
    " Instead of reverting the cursor to the last position in the buffer, we
    " set it to the first line when editing a git commit message
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
augroup END

" Keybinds
nnoremap <silent> <leader>gs :Gina status --opener=10split<CR>
nnoremap <silent> <leader>gS :Gina add %<CR>
nnoremap <silent> <leader>gU :Gina reset -q %<CR>
nnoremap <silent> <leader>gc :Gina commit<CR>
nnoremap <silent> <leader>gp :Gina push<CR>
nnoremap <silent> <leader>gp :Gina push<CR>
nnoremap <silent> <leader>gd :Gina diff<CR>
nnoremap <silent> <leader>gA :Gina add .<CR>
nnoremap <silent> <leader>gb :Gina blame<CR>

" View git log of current file
nnoremap <silent> <leader>gV :GV!<CR>

" View git log of current repo
nnoremap <silent> <leader>gv :GV<CR>
" }}}

" Vista {{{
" Position to open the vista sidebar. On the right by default.
" Change to 'vertical topleft' to open on the left.
let g:vista_sidebar_position = 'vertical botright'

" Width of vista sidebar.
let g:vista_sidebar_width = 30

" Set this flag to 0 to disable echoing when the cursor moves.
let g:vista_echo_cursor = 1

" Time delay for showing detailed symbol info at current cursor.
let g:vista_cursor_delay = 400

" Close the vista window automatically close when you jump to a symbol.
let g:vista_close_on_jump = 0

" Move to the vista window when it is opened.
let g:vista_stay_on_open = 1

" Blinking cursor 2 times with 100ms interval after jumping to the tag.
let g:vista_blink = [2, 100]

" How each level is indented and what to prepend.
" This could make the display more compact or more spacious.
" e.g., more compact: ["▸ ", ""]
let g:vista_icon_indent = ["╰─▸ ", "├─▸ "]

" Executive used when opening vista sidebar without specifying it.
" See all the avaliable executives via `:echo g:vista#executives`.
let g:vista_default_executive = 'vim_lsp'

" To enable fzf's preview window set g:vista_fzf_preview.
" The elements of g:vista_fzf_preview will be passed as arguments to fzf#vim#with_preview()
" For example:
let g:vista_fzf_preview = ['right:50%']

nmap <F9> :Vista!!<CR>
" }}}

" Tagbar {{{
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
" }}}

" Arpeggio {{{
call arpeggio#map('i', '', 0, 'jk', '<Esc>')
"let g:arpeggio_timeoutlen=20
" }}}

" Ack {{{
let g:ackprg = 'ag --nogroup --nocolor --column'
" }}}

" ClangFormat {{{
augroup clangformat_config
    autocmd!
    " map to <Leader>cf in C++ code
    autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
    autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
    autocmd FileType c,cpp,objc let g:clang_format#code_style = 'mozilla'
augroup END
" }}}

" Autocomplete {{{
augroup autocomplete_config
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
                    \ 'workspace_config': {'pyls': {'plugins': {'pydocstyle': {'enabled': v:true} } } }
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

augroup END

" echodoc
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'signature'
" }}}

" Markdown {{{
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
" }}}

" Python {{{
augroup python_config
    autocmd!
    " autoformat on save
    autocmd BufWritePost *.py Neoformat yapf
augroup END
let g:jedi#completions_enabled = 0
" If you execute :Pydocstring at no `def`, `class` line.
" g:pydocstring_enable_comment enable to put comment.txt value.
let g:pydocstring_enable_comment = 0

" Disable this option to prevent pydocstring from creating any
" key mapping to the `:Pydocstring` command.
" Note: this value is overridden if you explicitly create a
" mapping in your vimrc, such as if you do:
let g:pydocstring_enable_mapping = 0
" }}}

" Settings {{{

" Enable True Colors
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors

" Change backup directories and undo directories
set backupdir=/tmp/neovim///
set directory=/tmp/neovim//
set undodir=/tmp/neovim//

" Set the colorscheme
set background=dark
syntax on
colorscheme onedark

" Enable syntax based folding
set foldenable
set fdm=syntax

" Set the width of the text
set colorcolumn=80

" Scroll parameters
set scrolljump=5
set scrolloff=3

" Show line numbers
set number

" No alarms, please
set noerrorbells
set novisualbell

" Hilight matching brakets
set showmatch
set mat=2

" Search options
set ignorecase
set incsearch
set smartcase

" Let the command bar be 2 lines
set cmdheight=2

" Editor settings
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

" Forbid the use of arrow keys in all modes
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


" Configure the silver searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  if !exists(":Ag")
    command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
  endif
endif

" General
set exrc
set secure
filetype plugin on
filetype indent on

" Text files have textwidth of 78 characters
augroup text_files
    autocmd FileType text setlocal textwidth=78
augroup END

" }}}

