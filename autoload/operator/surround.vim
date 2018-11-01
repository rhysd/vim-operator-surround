let s:save_cpo = &cpo
set cpo&vim

" customization {{{
function! s:getg(name, default) abort
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

let g:operator#surround#uses_input_if_no_block = s:getg('uses_input_if_no_block', 1)
let g:operator#surround#recognizes_both_ends_as_surround = s:getg('recognizes_both_ends_as_surround', 1)
let g:operator#surround#ignore_space = s:getg('ignore_space', 1)
" }}}
" input {{{
function! s:get_block_or_prefix_match_in_filetype(blocks, filetype, input, motion) abort
    if !has_key(a:blocks, a:filetype)
        return 0
    endif
    for b in a:blocks[a:filetype]
        if index(b.motionwise, a:motion) >= 0
            if index(b.keys, a:input) >= 0
                " completely matched
                return b.block
            elseif filter(copy(b.keys), 'v:val =~# "^\\V'.escape(a:input, '"\').'"') != []
                " prefix matching
                return 1
            endif
        endif
    endfor
    return 0
endfunction

function! s:get_block_or_prefix_match_blocks(blocks, input, motion) abort
    let result = s:get_block_or_prefix_match_in_filetype(a:blocks, &filetype, a:input, a:motion)
    if type(result) == type([]) || result
        return result
    endif

    " '-' has the lowest priority
    return s:get_block_or_prefix_match_in_filetype(a:blocks, '-', a:input, a:motion)
endfunction

function! s:get_block_or_prefix_match(input, motion) abort
    if exists('b:operator#surround#blocks')
        let ret = s:get_block_or_prefix_match_blocks(b:operator#surround#blocks, a:input, a:motion)
        if type(ret) == type([]) || ret
            return ret
        endif
    endif

    let ret = s:get_block_or_prefix_match_blocks(g:operator#surround#blocks, a:input, a:motion)
    if type(ret) == type([]) || ret
        return ret
    endif

    if !s:getg('no_default_blocks', 0)
        return s:get_block_or_prefix_match_blocks(g:operator#surround#default_blocks, a:input, a:motion)
    endif

    return 0
endfunction

function! s:get_block_from_input(motion) abort
    echon 'block : '
    let input = ''
    while 1
        let char = getchar()
        let char = type(char) == type(0) ? nr2char(char) : char

        " cancel when <C-c> or <Esc> is input
        if char ==# "\<C-c>" || char ==# "\<Esc>"
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
function! s:is_empty_region(begin, end) abort
    return a:begin[1] == a:end[1] && a:end[2] < a:begin[2]
endfunction

function! s:normal(cmd) abort
    execute 'keepjumps' 'silent' 'normal!' a:cmd
endfunction

function! s:echomsg(message, ...) abort
    if a:0 == 1 | execute 'echohl' a:1 | endif
    echomsg type(a:message) == type('') ? a:message : string(a:message)
    if a:0 == 1 | echohl None | endif
endfunction

function! s:get_paste_command(visual, region, motion_end_last_col) abort
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

function! operator#surround#from_keymap() abort
    let s:state.from_keymap = 1
endfunction

" check whether the target region should be extended to each end of lines or not.
function! s:is_extended_blockwise_visual() abort
    if getpos("'[")[0:2] != getpos("'<")[0:2] || getpos("']")[0:2] != getpos("'>")[0:2]
        return 0
    endif
    normal! gv
    let is_extended = winsaveview().curswant == 1/0
    execute "normal! \<Esc>"
    return is_extended
endfunction

" }}}

" TODO
" - escape string when the surround is "" or ''
"   - add an option to escape for g:operator#surround#blocks

let s:state = { 'from_keymap' : 0, 'block' : '' }

" append {{{

" Check it should skip white spaces.
" If srounded object consists of white spaces only,
" skipping white spaces doesn't work.
function! s:should_skip_spaces() abort
    let sel_save = &l:selection
    let [save_unnamed_reg, save_unnamed_regtype] = [getreg('"'), getregtype('"')]
    let [save_g_reg, save_g_regtype] = [getreg('g'), getregtype('g')]
    try
        let &l:selection = 'inclusive'

        " Update `> and `<
        call s:normal("`[v`]\"gy")

        return g:operator#surround#ignore_space &&
                    \ getreg('g') !~# '^[[:space:]\n]*$'
    finally
        call setreg('g', save_g_reg, save_g_regtype)
        call setreg('"', save_unnamed_reg, save_unnamed_regtype)
        let &l:selection = sel_save
    endtry
endfunction
function! s:surround_characters(block_begin, block_end) abort
    let should_skip_spaces = s:should_skip_spaces()
    " insert block to the region
    call s:normal('`>')
    if should_skip_spaces
        call search('\S', 'bcW')
    endif
    call s:normal(printf("a%s\<Esc>", a:block_end))
    call s:normal('`<')
    if should_skip_spaces
        call search('\S', 'cW')
    endif
    call s:normal(printf("i%s\<Esc>", a:block_begin))
endfunction

function! s:surround_lines(block_begin, block_end) abort
    " insert block to the head and tail of lines
    call s:normal( printf("%dgg$a%s\<Esc>%dgg0i%s\<Esc>",
                         \ getpos("']")[1],
                         \ a:block_end,
                         \ getpos("'[")[1],
                         \ a:block_begin)
                 \ )
endfunction

function! s:surround_blocks(block_begin, block_end) abort
    let [_, start_line, start_col, _] = getpos("'[")
    let [_, last_line, end_col, _] = getpos("']")
    let is_extended = s:is_extended_blockwise_visual()
    for line in range(start_line, last_line)
        if getline(line) =~# '^\s*$'
          continue
        endif
        " insert block to the one line in the block region
        call s:normal(printf("%dgg%d|a%s\<Esc>%d|i%s\<Esc>",
                    \        line,
                    \        is_extended ? col([line, '$']) : end_col,
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
            throw 'Invalid motion: ' . a:motion
        endif
    finally
        call setpos('.', pos_save)
        let &autoindent = autoindent_save
        let &cindent = cindent_save
        let &smartindent = smartindent_save
        let &selection = selection_save
    endtry
endfunction

function! operator#surround#append(motion) abort
    if s:is_empty_region(getpos("'["), getpos("']"))
        return
    endif

    let result = s:state.from_keymap ? s:get_block_from_input(a:motion) : s:state.block
    if type(result) == type(0) && ! result
        return
    endif
    let block = result

    call s:append_block(block, a:motion)

    let s:state.from_keymap = 0
    let s:state.block = block
endfunction
" }}}

" delete {{{
function! s:get_surround_in_with_filetype(filetype, blocks, region) abort
    let space_skipper = g:operator#surround#ignore_space
                \ ? '\[[:space:]\n]\*'
                \ : '\n\*'

    for b in a:blocks[a:filetype]
        " if the block surrounds the object
        if match(a:region, printf('^\V%s%s\.\*%s%s\$', space_skipper, b.block[0], b.block[1], space_skipper)) >= 0
            return b.block
        endif
    endfor
    return []
endfunction

function! s:get_surround_from_blocks_in(blocks, region) abort
    if has_key(a:blocks, &filetype)
        let result = s:get_surround_in_with_filetype(&filetype, a:blocks, a:region)
        if result != [] | return result | endif
    endif

    " '-' has the lowest priority
    if has_key(a:blocks, '-')
        return s:get_surround_in_with_filetype('-', a:blocks, a:region)
    else
        return []
    endif
endfunction

function! s:get_surround_in(region) abort
    if exists('b:operator#surround#blocks')
        let ret = s:get_surround_from_blocks_in(b:operator#surround#blocks, a:region)
        if ret != [] | return ret | endif
    endif

    let ret = s:get_surround_from_blocks_in(g:operator#surround#blocks, a:region)
    if ret != [] | return ret | endif

    if !s:getg('no_default_blocks', 0)
        return s:get_surround_from_blocks_in(g:operator#surround#default_blocks, a:region)
    endif

    return []
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

        let after = substitute(region, '^\V'. space_skipper . '\zs' . escape(block[0], '\') , '', '')
        let after = substitute(after, '\V' . escape(block[1], '\') . '\ze' . space_skipper . '\$', '', '')

        call setreg('g', after, a:visual)
        call s:normal('"g'.put_command)
    catch /^vim-operator-surround: /
        call s:echomsg('no block matches to the region', 'ErrorMsg')
    finally
        call setreg('g', save_reg_g, save_regtype_g)
        call setreg('"', save_reg_unnamed, save_regtype_unnamed)
    endtry
endfunction

function! s:delete_surrounds_in_block() abort
    let [_, start_line, start_col, _] = getpos("'[")
    let [_, last_line, last_col, _] = getpos("']")
    let [save_reg_g, save_regtype_g] = [getreg('g'), getregtype('g')]
    let [save_reg_unnamed, save_regtype_unnamed] = [getreg('"'), getregtype('"')]
    let is_extended = s:is_extended_blockwise_visual()
    try
        for line in range(start_line, last_line)
            if getline(line) =~# '^\s*$'
              continue
            endif
            " yank to set '[ and ']
            call s:normal(line.'gg')
            let end_of_line_col = last_col > col('$')-1 || is_extended ? col('$')-1 : last_col
            call s:normal(printf('%d|v%d|"gy', start_col, end_of_line_col))
            call s:delete_surround('v')
        endfor

        " leave whole region as a history of buffer changes
        call s:normal(printf("%dgg%d|\<C-v>`]%s\"gy", start_line, start_col, is_extended ? '$' : ''))
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
            throw 'Invalid motion: ' . a:motion
        endif
    finally
        call setpos('.', pos)
        let &selection = selection
    endtry
endfunction
" }}}

" replace {{{
function! operator#surround#replace(motion) abort
    " get input at first because of undo history
    let result = s:state.from_keymap ? s:get_block_from_input(a:motion) : s:state.block
    if type(result) == type(0) && ! result
        return
    endif
    let block = result

    call operator#surround#delete(a:motion)
    call s:append_block(block, a:motion)

    let s:state.from_keymap = 0
    let s:state.block = block
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
