let s:save_cpo = &cpo
set cpo&vim

" customization {{{
function! s:getg(name, default)
    return get(g:, 'operator#surround#'.a:name, a:default)
endfunction

let g:operator#surround#blocks = s:getg('blocks', {})

let g:operator#surround#default_blocks =
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
                \ }
lockvar! g:operator#surround#default_blocks

if ! s:getg('no_default_blocks', 0)

    function! s:merge(d1, d2)
        for [k, v] in items(a:d2)
            if has_key(a:d1, k)
                call extend(a:d1[k], v)
            else
                let a:d1[k] = v
            endif
        endfor
    endfunction

    call s:merge(g:operator#surround#blocks, g:operator#surround#default_blocks)

    delfunction s:merge
endif

let g:operator#surround#uses_input_if_no_block = s:getg('uses_input_if_no_block', 1)
let g:operator#surround#recognizes_both_ends_as_surround = s:getg('recognizes_both_ends_as_surround', 1)
let g:operator#surround#ignore_space = s:getg('ignore_space', 1)
" }}}
" input {{{
function! s:get_block_or_prefix_match_in_filetype(filetype, input, motion)
    for b in g:operator#surround#blocks[a:filetype]
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

function! s:get_block_or_prefix_match(input, motion)
    if has_key(g:operator#surround#blocks, &filetype)
        let result = s:get_block_or_prefix_match_in_filetype(&filetype, a:input, a:motion)
        if type(result) == type([]) || result
            return result
        endif
    endif

    " '-' has the lowest priority
    if has_key(g:operator#surround#blocks, '-')
        return s:get_block_or_prefix_match_in_filetype('-', a:input, a:motion)
    else
        return 0
    endif
endfunction

function! s:get_block_from_input(motion)
    echon 'block : '
    let input = ''
    while 1
        let char = getchar()
        let char = type(char) == type(0) ? nr2char(char) : char

        " cancel when <C-c> or <Esc> is input
        if char == "\<C-c>" || char == "\<Esc>"
            echo 'canceled.'
            return 0
        endif

        let input .= char
        let result = s:get_block_or_prefix_match(input, a:motion)
        if type(result) == type([])
            return result
        elseif ! result
            if g:operator#surround#uses_input_if_no_block
                return [input, input]
            else
                call s:echomsg(input . ' is not defined. Please check g:operator#surround#blocks.', 'ErrorMsg')
                return 0
            endif
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
    execute 'keepjumps' 'silent' 'normal!' a:cmd
endfunction

function! s:echomsg(message, ...)
    if a:0 == 1 | execute 'echohl' a:1 | endif
    echomsg type(a:message) == type('') ? a:message : string(a:message)
    if a:0 == 1 | echohl None | endif
endfunction

function! s:get_paste_command(visual, region, motion_end_last_col)
    let [motion_end_line, motion_end_col] = a:region[1]
    let start_line = a:region[0][0]

    if a:visual ==# 'v'
        return ((a:motion_end_last_col == motion_end_col)
                    \ || (line('$') == motion_end_line
                    \     && len(getline('$')) <= motion_end_col))
                    \ ? 'p' : 'P'
    elseif a:visual ==# 'V'
        if start_line == 1 && motion_end_line == line('$')
            " NOTE:
            " p and P can't insert linewise object in this case
            " because 1 line remains definitely and the line remains
            " after pasting.
            return 'p`[k"_ddggVG"gy'
        endif
        return line('$') == motion_end_line ? 'p' : 'P'
    else
        return 'P'
    endif
endfunction

" handle required information
function! s:get_info(name)
    if !exists('b:operator_surround')
        let b:operator_surround = {}
        let b:operator_surround.state = 0
        let b:operator_surround.block = ''
    endif
    return b:operator_surround[a:name]
endfunction

function! s:set_info(name, value)
    if !exists('b:operator_surround')
        call s:get_info('state')
    endif
    let b:operator_surround[a:name] = a:value
endfunction

function! operator#surround#certify_as_keymapping()
    call s:set_info('state', 1)
endfunction

" }}}

" TODO
" - escape string when the surround is "" or ''
"   - add an option to escape for g:operator#surround#blocks

function! s:is_ordered(pos1, pos2)
    if a:pos1[1] != a:pos2[1]
        return a:pos1[1] < a:pos2[1]
    endif

    return a:pos1[2] <= a:pos2[2]
endfunction

" append {{{

" Check it should skip white spaces.
" If srounded object consists of white spaces only,
" skipping white spaces doesn't work.
function! s:should_skip_spaces()
    let sel_save = &l:selection
    let [save_g_reg, save_g_regtype] = [getreg('g'), getregtype('g')]
    try
        let &l:selection = 'inclusive'

        " Update `> and `<
        call s:normal("`[v`]\"gy")

        return g:operator#surround#ignore_space &&
                    \ getreg('g') !~# '^[[:space:]\n]*$'
    finally
        call setreg('g', save_g_reg, save_g_regtype)
        let &l:selection = sel_save
    endtry
endfunction
function! s:surround_characters(block_begin, block_end)
    let should_skip_spaces = s:should_skip_spaces()
    " insert block to the region
    call s:normal("`>")
    if should_skip_spaces
        call search('\S', 'bcW')
    endif
    call s:normal(printf("a%s\<Esc>", a:block_end))
    call s:normal("`<")
    if should_skip_spaces
        call search('\S', 'cW')
    endif
    call s:normal(printf("i%s\<Esc>", a:block_begin))
endfunction

function! s:surround_lines(block_begin, block_end)
    " insert block to the head and tail of lines
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
        " insert block to the one line in the block region
        call s:normal(printf("%dgg%d|a%s\<Esc>%d|i%s\<Esc>",
                    \        line,
                    \        end_col,
                    \        a:block_end,
                    \        start_col,
                    \        a:block_begin)
                    \ )
    endfor
endfunction

function! s:append_block(block_pair, motion) abort
    let pos_save = getpos('.')
    let autoindent_save = &autoindent
    let cindent_save = &cindent
    let smartindent_save = &smartindent
    let selection_save = &selection
    set noautoindent
    set nocindent
    set nosmartindent
    set selection=inclusive

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
        call setpos('.', pos_save)
        let &autoindent = autoindent_save
        let &cindent = cindent_save
        let &smartindent = smartindent_save
        let &selection = selection_save
    endtry
endfunction

function! operator#surround#append(motion)
    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    let state  = s:get_info('state')
    let result = state ? s:get_block_from_input(a:motion) : s:get_info('block')
    if type(result) == type(0) && ! result
        return
    endif
    let block = result

    call s:append_block(block, a:motion)

    call s:set_info('state', 0)
    call s:set_info('block', block)
endfunction
" }}}

" delete {{{
function! s:get_surround_in_with_filetype(filetype, region)
    let space_skipper = g:operator#surround#ignore_space
                \ ? '\[[:space:]\n]\*'
                \ : '\n\*'

    for b in g:operator#surround#blocks[a:filetype]
        " if the block surrounds the object
        if match(a:region, printf('^\V%s%s\.\*%s%s\$', space_skipper, b.block[0], b.block[1], space_skipper)) >= 0
            return b.block
        endif
    endfor
    return []
endfunction

function! s:get_surround_in(region)
    if has_key(g:operator#surround#blocks, &filetype)
        let result = s:get_surround_in_with_filetype(&filetype, a:region)
        if result != [] | return result | endif
    endif

    " '-' has the lowest priority
    if has_key(g:operator#surround#blocks, '-')
        return s:get_surround_in_with_filetype('-', a:region)
    else
        return []
    endif
endfunction

function! s:get_same_str_surround(region) abort
    if g:operator#surround#ignore_space
        let region = matchstr(a:region, '^[[:space:]\n]*\zs.*\ze[[:space:]\n]*$')
    else
        let region = matchstr(a:region, '^\n*\zs.*\ze\n*$')
    endif

    let len = strlen(region)

    let [s, e] = [0, len - 1]

    while region[s] ==# region[e] && s < len && e >= 0
        let s += 1
        let e -= 1
    endwhile

    if s == 0
        throw 'vim-operator-surround: block is not found'
    endif

    let surround = region[ : s - 1]
    return [surround, surround]
endfunction

function! s:delete_surround(visual) abort
    let [save_reg_g, save_regtype_g] = [getreg('g'), getregtype('g')]
    let [save_reg_unnamed, save_regtype_unnamed] = [getreg('"'), getregtype('"')]
    try
        call setreg('g', '', 'v')
        call s:normal('`['.a:visual.'`]"gy')
        let region = getreg('g')

        let block = s:get_surround_in(region)
        if block == []
            if ! g:operator#surround#recognizes_both_ends_as_surround
                throw 'vim-operator-surround: block is not found'
            endif

            let block = s:get_same_str_surround(region)
        endif

        let put_command = s:get_paste_command(a:visual, [getpos("'[")[1:2], getpos("']")[1:2]], len(getline("']")))

        call s:normal('`['.a:visual.'`]"_d')

        " remove the former block and latter block
        let space_skipper = g:operator#surround#ignore_space
                    \ ? '\[[:space:]\n]\*'
                    \ : '\n\*'

        let after = substitute(region, '^\V'. space_skipper . '\zs' . block[0], '', '')
        let after = substitute(after, '\V' . block[1] . '\ze' . space_skipper . '\$', '', '')

        call setreg('g', after, a:visual)
        call s:normal('"g'.put_command)
    catch /^vim-operator-surround: /
        call s:echomsg('no block matches to the region', 'ErrorMsg')
    finally
        call setreg('g', save_reg_g, save_regtype_g)
        call setreg('"', save_reg_unnamed, save_regtype_unnamed)
    endtry
endfunction

function! s:delete_surrounds_in_block()
    let [_, start_line, start_col, _] = getpos("'[")
    let [_, last_line, last_col, _] = getpos("']")
    let [save_reg_g, save_regtype_g] = [getreg('g'), getregtype('g')]
    let [save_reg_unnamed, save_regtype_unnamed] = [getreg('"'), getregtype('"')]
    try
        for line in range(start_line, last_line)
            " yank to set '[ and ']
            call s:normal(line.'gg')
            let end_of_line_col = last_col > col('$')-1 ? col('$')-1 : last_col
            call s:normal(printf('%d|v%d|"gy', start_col, end_of_line_col))
            call s:delete_surround('v')
        endfor

        " leave whole region as a history of buffer changes
        call s:normal(printf("%dgg%d|\<C-v>`]\"gy", start_line, start_col))
    finally
        call setreg('g', save_reg_g, save_regtype_g)
        call setreg('"', save_reg_unnamed, save_regtype_unnamed)
    endtry
endfunction

function! operator#surround#delete(motion) abort
    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    let pos = getpos('.')
    let selection = &selection
    set selection=inclusive
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
        let &selection = selection
    endtry
endfunction
" }}}

" replace {{{
function! operator#surround#replace(motion)
    " get input at first because of undo history
    let state  = s:get_info('state')
    let result = state ? s:get_block_from_input(a:motion) : s:get_info('block')
    if type(result) == type(0) && ! result
        return
    endif
    let block = result

    call operator#surround#delete(a:motion)
    call s:append_block(block, a:motion)

    call s:set_info('state', 0)
    call s:set_info('block', block)
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
