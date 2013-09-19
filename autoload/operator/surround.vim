if exists('g:autoloaded_operator_surround')
    finish
endif
let g:autoloaded_operator_surround = 1

if ! get(g:, 'operator#surround#no_default_blocks', 0)

    function! s:merge(d1, d2)
        for [k, v] in items(a:d2)
            if has_key(a:d1, k)
                call extend(a:d1[k], v)
            else
                let a:d1[k] = v
            endif
        endfor
    endfunction

    let g:operator#surround#blocks = get(g:, 'operator#surround#blocks', {})
    call s:merge( g:operator#surround#blocks,
                \ {
                \   '-' : [
                \       { 'block' : ['(', ')'], 'mode' : "vV\<C-v>", 'keys' : ['(', ')'] },
                \       { 'block' : ['[', ']'], 'mode' : "vV\<C-v>", 'keys' : ['[', ']'] },
                \       { 'block' : ['{', '}'], 'mode' : "vV\<C-v>", 'keys' : ['{', '}'] },
                \       { 'block' : ['<', '>'], 'mode' : "vV\<C-v>", 'keys' : ['<', '>'] },
                \       { 'block' : ['"', '"'], 'mode' : "vV\<C-v>", 'keys' : ['"'] },
                \       { 'block' : ["'", "'"], 'mode' : "vV\<C-v>", 'keys' : ["'"] },
                \       { 'block' : ['`', '`'], 'mode' : "vV\<C-v>", 'keys' : ['`'] },
                \       { 'block' : [' ', ' '], 'mode' : "vV\<C-v>", 'keys' : ["\<Space>"] },
                \   ],
                \ } )
endif


function! s:block(input_char, motion)
    for b in g:operator#surround#blocks['-']
        if index(b.keys, a:input_char) >= 0 && b.mode =~# a:motion
            return b.block
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

function! s:motion_abbrv(motion)
    if a:motion ==# 'char'
        return 'v'
    elseif a:motion ==# 'line'
        return 'V'
    elseif a:motion ==# 'block'
        return "\<C-v>"
    else
        throw "invalid motion wiseness"
    endif
endfunction

function! s:append_block(block_pair)
    if type(a:block_pair) == type(0) && ! a:block_pair
        return
    endif

    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    let pos = getpos('.')
    execute 'silent' 'normal!' "`[v`]\<Esc>"
    execute 'silent' 'normal!' printf("`>a%s\<Esc>`<i%s\<Esc>", a:block_pair[1], a:block_pair[0])
    call setpos('.', pos)
endfunction


function! operator#surround#append(motion)
    if a:motion !=# 'char'
        throw "Not implemented"
    endif

    let char = s:getchar()
    return s:append_block(s:block(char, s:motion_abbrv(a:motion)))
endfunction


function! operator#surround#replace(motion)
    throw "Not implemented"
endfunction


function! operator#surround#delete(motion)
    throw "Not implemented"
endfunction
