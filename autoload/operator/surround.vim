if exists('g:autoloaded_operator_surround')
    finish
endif
let g:autoloaded_operator_surround = 1

let s:save_cpo = &cpo
set cpo&vim

" customization {{{
let g:operator#surround#blocks = get(g:, 'operator#surround#blocks', {})

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
                \       { 'block' : ['( ', ' )'], 'motionwise' : ['char', 'line', 'block'], 'keys' : [' (', ' )'] },
                \       { 'block' : ['{ ', ' }'], 'motionwise' : ['char', 'line', 'block'], 'keys' : [' {', ' }'] },
                \   ],
                \ } )

    delfunction s:merge
endif
" }}}

" input {{{
function! s:get_block_or_prefix_match(input, motion)
    for b in g:operator#surround#blocks['-']
        if index(b.motionwise, a:motion) >= 0
            if index(b.keys, a:input) >= 0
                " completely matched
                return b.block
            elseif filter(copy(b.keys), 'v:val =~# "^\\V'.escape(a:input, '"').'"') != []
                " prefix matching
                return 1
            endif
        endif
    endfor
    return 0
endfunction

function! s:get_block_from_input(motion)
    echon 'block : '
    let input = ''
    while 1
        let char = getchar()
        let input .= type(char) == type(0) ? nr2char(char) : char
        let result = s:get_block_or_prefix_match(input, a:motion)
        if type(result) == type([])
            return result
        elseif ! result
            echoerr input . ' is not defined. Please check g:operator#surround#blocks.'
            return 0
        endif
        unlet result
    endwhile
endfunction
" }}}

" helpers {{{
function! s:is_empty_region(begin, end)
    return a:begin[1] == a:end[1] && a:end[2] < a:begin[2]
endfunction

function! s:normal(cmd)
    execute 'silent' 'normal!' a:cmd
endfunction

function! s:echomsg(message, ...)
    if a:0 == 1 | execute 'echohl' a:1 | endif
    echomsg type(a:message) == type('') ? a:message : string(a:message)
    if a:0 == 1 | echohl None | endif
endfunction

function! s:get_paste_command()
    let pos = getpos('.')
    try
        normal! $
        return getpos('.') == pos ? 'p' : 'P'
    finally
        call setpos('.', pos)
    endtry
endfunction
" }}}


" append {{{
function! s:surround_characters(block_begin, block_end)
    call s:normal("`[v`]\<Esc>")
    call s:normal(printf("`>a%s\<Esc>`<i%s\<Esc>", a:block_end, a:block_begin))
endfunction

function! s:surround_lines(block_begin, block_end)
    call s:normal( printf("%dgg$a%s\<Esc>%dgg0i%s\<Esc>",
                         \ getpos("']")[1],
                         \ a:block_end,
                         \ getpos("'[")[1],
                         \ a:block_begin)
                 \ )
endfunction

function! s:surround_blocks(block_begin, block_end)
    let [_, start_line, start_col, _] = getpos("'[")
    let [_, last_line, end_col, _] = getpos("']")
    for line in range(start_line, last_line)
        call s:normal(printf("%dgg%d|a%s\<Esc>%d|i%s\<Esc>",
                    \        line,
                    \        end_col,
                    \        a:block_end,
                    \        start_col,
                    \        a:block_begin)
                    \ )
    endfor
endfunction

function! s:append_block(block_pair, motion)
    let pos = getpos('.')
    try
        if a:motion ==# 'char'
            call s:surround_characters(a:block_pair[0], a:block_pair[1])
        elseif a:motion ==# 'line'
            call s:surround_lines(a:block_pair[0], a:block_pair[1])
        elseif a:motion ==# 'block'
            call s:surround_blocks(a:block_pair[0], a:block_pair[1])
        else
            " never reached here
            throw "Invalid motion"
        endif
    finally
        call setpos('.', pos)
    endtry
endfunction


function! operator#surround#append(motion)
    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    let block = s:get_block_from_input(a:motion)
    if type(block) == type(0) && ! block
        return
    endif

    return s:append_block(block, a:motion)
endfunction
" }}}


" delete {{{
function! s:get_surround_in(region)
    for b in g:operator#surround#blocks['-']
        if match(a:region, '^\V\%(\s\|\n\)\*'.b.block[0].'\.\*'.b.block[1].'\%(\s\|\n\)\*\$') >= 0
            return b.block
        endif
    endfor
    return []
endfunction

function! s:delete_surround(visual)
    let save_reg_g = getreg('g')
    let save_regtype_g = getregtype('g')
    try
        call setreg('g', '', 'v')
        call s:normal('`['.a:visual.'`]"gy')
        let region = getreg('g')

        let block = s:get_surround_in(region)
        if block == []
            throw 'vim-operator-surround'
        endif

        call s:normal('`['.a:visual.'`]"_d')

        let after = substitute(region, '^\%(\s\|\n\)*\zs\V'.block[0], '', '')
        let after = substitute(after, '\V'.block[1].'\ze\%(\s\|\n\)\*\$', '', '')

        call setreg('g', after, 'v')
        call s:normal('"g'.s:get_paste_command())
    catch /vim-operator-surround/
        echoerr 'no block matches to the region'
    finally
        call setreg('g', save_reg_g, save_regtype_g)
    endtry
endfunction

function! s:delete_surrounds_in_block()
    let [_, start_line, start_col, _] = getpos("'[")
    let [_, last_line, last_col, _] = getpos("']")
    let save_reg_g = getreg('g')
    let save_regtype_g = getregtype('g')
    try
        for line in range(start_line, last_line)
            " yank to set '[ and ']
            call s:normal(line.'gg')
            let end_of_line_col = last_col > col('$')-1 ? col('$')-1 : last_col
            call s:normal(printf('%d|v%d|"gy', start_col, end_of_line_col))
            call s:delete_surround('v')
        endfor
    finally
        call setreg('g', save_reg_g, save_regtype_g)
    endtry
endfunction

function! operator#surround#delete(motion)
    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    let pos = getpos('.')
    try
        if a:motion ==# 'char'
            call s:delete_surround('v')
        elseif a:motion ==# 'line'
            call s:delete_surround('V')
        elseif a:motion ==# 'block'
            call s:delete_surrounds_in_block()
        else
            " never reached here
            throw "Invalid motion"
        endif
    finally
        call setpos('.', pos)
    endtry
endfunction
" }}}


" replace {{{
function! operator#surround#replace(motion)
    throw "Not implemented"
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
