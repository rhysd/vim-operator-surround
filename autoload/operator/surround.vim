
let g:operator#surround#blocks = get(g:, 'operator_surround_blocks',
            \ {
            \   '-' : [
            \       ['(', ')', '(', ')'],
            \       ['[', ']', '[', ']'],
            \       ['{', '}', '{', '}'],
            \       ['<', '>', '<', '>'],
            \       ['"', '"', '"'],
            \       ["'", "'", "'"],
            \       ['`', '`', '`'],
            \       [' ', ' ', "\<Space>"],
            \   ],
            \ })


function! s:block(input_char)
    for b in g:operator#surround#blocks['-']
        if index(b, a:input_char, 2) > 0
            return b
        endif
    endfor
    echoerr a:input_char . ' is not defined. Please check g:operator#surround#blocks.'
    return 0
endfunction


function! s:getchar()
    echon 'block : '
    let in = getchar()
    return type(in) == type(0) ? nr2char(in) : in
endfunction


function! s:is_empty_region(begin, end)
  return a:begin[1] == a:end[1] && a:end[2] < a:begin[2]
endfunction


function! s:append_block(block)
    if type(a:block) == type(0) && ! a:block
        return
    endif

    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    let pos = getpos('.')
    execute 'normal!' "`[v`]\<Esc>"
    execute 'normal!' printf("`>a%s\<Esc>`<i%s\<Esc>", a:block[1], a:block[0])
    call setpos('.', pos)

endfunction


function! operator#surround#append(motion)
    if a:motion !=# 'char'
        throw "Not implemented"
    endif

    let char = s:getchar()
    return s:append_block(s:block(char))
endfunction


function! operator#surround#replace(motion)
    
endfunction


function! operator#surround#delete(motion)
    
endfunction
