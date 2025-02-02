
function! s:isBunSh()
	if getline(1) =~# '^#!.\+env\s\+bun'
    return 1
  endif
	return 0
endfunction

autocmd BufRead * if !did_filetype() && s:isBunSh() | setf typescript | endif
