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
                \       { 'block' : ['(', ')'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['(', ')'] },
                \       { 'block' : ['[', ']'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['[', ']'] },
                \       { 'block' : ['{', '}'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['{', '}'] },
                \       { 'block' : ['<', '>'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['<', '>'] },
                \       { 'block' : ['"', '"'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['"'] },
                \       { 'block' : ["'", "'"], 'motionwise' : ['char', 'line', 'block'], 'keys' : ["'"] },
                \       { 'block' : ['`', '`'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['`'] },
                \       { 'block' : [' ', ' '], 'motionwise' : ['char', 'line', 'block'], 'keys' : ["\<Space>"] },
                \   ],
                \ } )

    delfunction s:merge
endif


function! s:block(input_char, motion)
    for b in g:operator#surround#blocks['-']
        if index(b.keys, a:input_char) >= 0 && index(b.motionwise, a:motion) >= 0
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

function! s:surround_characters(block_begin, block_end)
    let pos = getpos('.')
    execute 'silent' 'normal!' "`[v`]\<Esc>"
    execute 'silent' 'normal!' printf("`>a%s\<Esc>`<i%s\<Esc>", a:block_end, a:block_begin)
    call setpos('.', pos)
endfunction

function! s:append_block(block_pair, motion)
    if type(a:block_pair) == type(0) && ! a:block_pair
        return
    endif

    if a:motion ==# 'char'
        call s:surround_characters(a:block_pair[0], a:block_pair[1])
    else
        throw "Not implemented"
    endif
endfunction


function! operator#surround#append(motion)
    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    let char = s:getchar()
    return s:append_block(s:block(char, a:motion), a:motion)
endfunction


function! operator#surround#replace(motion)
    throw "Not implemented"
endfunction


function! operator#surround#delete(motion)
    throw "Not implemented"
endfunction
