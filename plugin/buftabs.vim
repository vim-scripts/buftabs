"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Buftabs (C) 2006 Ico Doornekamp
"
" This is a simple script that allows switching between buffers with the F1 and
" F2 keys, while showing a tabs-like list of buffers in the bottom of the
" window. The biggest advantage of this script over various others is that it
" does not take any lines of the window.
"
" The default mappings can be changed by modifiying the maps in the bottom of
" this file
" 
" 0.1	2006-09-22	Initial version	
"
" 02	2006-09-22	Better handling when the list of buffers is longer
" 			then the window width.
"
" 0.3	2006-09-27	Some cleanups, set 'hidden' mode by default
"
" 0.4	2007-02-26	Don't draw buftabs until VimEnter event to avoid
" 			clutter at startup in some circumstances
"
" 0.5	2007-02-26	Added option for showing only filenames without
" 			directories in tabs
" 
" 
" Configuration parameters go here :
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set this flag to true to only show filenames without directories
" in the tabs. For example /etc/inittab is shown as only 'inittab'

let s:only_basename = 0



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" End of configuration parameters, code starts here
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"
" Called on VimEnter event
"

let s:buftabs_enabled = 0

function! Buftabs_enable()
	let s:buftabs_enabled = 1
endfunction


"
" Draw the actual buftabs
"

function! Buftabs_show()

	let l:i = 1
	let l:list = ''
	let l:start = 0
	let l:end = 0
	if ! exists("g:from") 
		let g:from = 0
	endif

	if s:buftabs_enabled != 1 
		return
	endif
	
	" Add all buffer names to the list. Visible buffers are enclosed in
	" []'s, modified buffers get an exclaimation mark appended.

	while(l:i <= bufnr('$'))

		" Skip help and hidden windows
		
		if getbufvar(l:i, "&modifiable") != 1 || getbufvar(l:i, "&hidden") == 0
			break
		endif

		if bufwinnr(l:i) != -1
			let l:list = l:list . '['
			let l:start = strlen(l:list)
		else
			let l:list = l:list . ' '
		endif
			
		let l:list = l:list . l:i . "-" 

		if s:only_basename 
			let l:list = l:list . fnamemodify(bufname(l:i), ":t")
		else
			let l:list = l:list . bufname(l:i)
		endif

		if getbufvar(l:i, "&modified") == 1
			let l:list = l:list . "!"
		endif
		
		if bufwinnr(l:i) != -1
			let l:list = l:list . ']'
			let l:end = strlen(l:list)
		else
			let l:list = l:list . ' '
		endif

		let l:i = l:i + 1
	endwhile

	" If the resulting list is too long to fit on the screen, chop
	" out the appropriate part

	let l:width = winwidth(0) - 12

	if(l:start < g:from) 
		let g:from = l:start - 1
	endif
	if l:end > g:from + l:width
		let g:from = l:end - l:width 
	endif
		
	let l:list = strpart(l:list, g:from, l:width)

	" Show the list
	
	redraw
	echon l:list

endfunction

" Show buftabs at startup and map F1/F2 to switch between buffers

autocmd VimEnter * call Buftabs_enable()
autocmd VimEnter * call Buftabs_show()
autocmd BufNew * call Buftabs_show()
:noremap <f1> :bprev<return>:call Buftabs_show()<enter>
:noremap <f2> :bnext<return>:call Buftabs_show()<enter>

set hidden

" end

