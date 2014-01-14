" ~/.vim/bundles.vimrc
" Author: Warden (Guido Masella)
"                (guido.masella@gmail.com)

" General utilities
if count(g:warden_packages, 'general')
	" ctrlp -
	Bundle 'kien/ctrlp.vim'
		let g:ctrlp_map = '<c-p>'
		let g:ctrlp_cmd = 'CtrlP'
		let g:ctrlp_working_path_mode = 'ra'
		set wildignore+=*/tmp/*,*.so,*.swp,*.zip

	" fugitive - deep git integration in vim
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

	" easymotions -
	Bundle 'Lokaltog/vim-easymotion'
endif


" Editing related plugins
if count(g:warden_packages, 'editing')
	" surround -
	Bundle 'tpope/vim-surround'

	" trailing spaces -
	Bundle 'bronson/vim-trailing-whitespace'
endif


" Look package
if count(g:warden_packages, 'look')
	" numbers.vim - a plugin to show relative line numbers or simple line
	" numbers depending on the mode you are in
	Bundle 'myusuf3/numbers.vim'
		set number
	" vim-airline - lean & mean statusline for vim that's light as air
	Bundle 'bling/vim-airline'
		set laststatus=2
		let g:airline#extensions#tabline#enabled = 1
		if !exists('g:airline_symbols')
			let g:airline_symbols = {}
		endif

		" unicode symbols
		let g:airline_left_sep = '»'
		let g:airline_left_sep = '▶'
		let g:airline_right_sep = '«'
		let g:airline_right_sep = '◀'
		let g:airline_symbols.linenr = '␊'
		let g:airline_symbols.linenr = '␤'
		let g:airline_symbols.linenr = '¶'
		let g:airline_symbols.branch = '⎇'
		let g:airline_symbols.paste = 'ρ'
		let g:airline_symbols.paste = 'Þ'
		let g:airline_symbols.paste = '∥'
		let g:airline_symbols.whitespace = 'Ξ'

	" vim-colors-solarized - a splendid solarized colorscheme
	Bundle 'altercation/vim-colors-solarized'
		set background=dark
		colorscheme solarized	" set a dark solarized scheme

	" vim-colorschemes - collections of colorschemes
	Bundle 'flazz/vim-colorschemes'
		"set background=dark
		"colorscheme ir_black
	"
endif
