let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

command! -nargs=+ -count=1 Line call setline(<count>, <args>)

describe '<Plug>(operator-surround-append)'
    before
        let g:operator#surround#uses_input_if_no_block = 0
        map s <Plug>(operator-surround-append)
        new
    end

    after
        close!
        unmap s
    end

    " error handling {{{
    it 'echos an error message when input is invalid if g:operator#surround#uses_input_if_no_block is not specified.'
        Line "hoge huga poyo"
        normal! gg0w
        redir => buffer
            silent normal siw&
        redir END
        Expect buffer =~# "& is not defined. Please check g:operator#surround#blocks."
        let buffer = ''
        redir => buffer
            silent normal viws&
        redir END
        Expect buffer =~# "& is not defined. Please check g:operator#surround#blocks."
        try
            Expect 'normal siw&' not to_move_cursor
            Expect 'normal viws&' not to_move_cursor
        catch
        endtry
    end
    " }}}

    " characterwise {{{
    it 'appends blocks to a characterwise object with an operator mapping.'
        Line "hoge huga poyo"
        normal! gg0w
        normal siw(l
        Expect "hoge (huga) poyo" to_be_current_line
        normal siw[l
        Expect "hoge ([huga]) poyo" to_be_current_line
        normal siw{l
        Expect "hoge ([{huga}]) poyo" to_be_current_line
        normal siw<l
        Expect "hoge ([{<huga>}]) poyo" to_be_current_line
        normal siw"l
        Expect "hoge ([{<\"huga\">}]) poyo" to_be_current_line
        normal siw'l
        Expect "hoge ([{<\"'huga'\">}]) poyo" to_be_current_line
        normal siw`l
        Expect "hoge ([{<\"'`huga`'\">}]) poyo" to_be_current_line
        normal siw )ll
        Expect "hoge ([{<\"'`( huga )`'\">}]) poyo" to_be_current_line
        normal siw }ll
        Expect "hoge ([{<\"'`( { huga } )`'\">}]) poyo" to_be_current_line
        echon ' '
    end

    it 'appends blocks to a characterwise object with visual mode mapping.'
        Line "hoge huga poyo"
        normal! gg0ww
        normal viws(l
        Expect "hoge huga (poyo)" to_be_current_line
        normal viws[l
        Expect "hoge huga ([poyo])" to_be_current_line
        normal viws{l
        Expect "hoge huga ([{poyo}])" to_be_current_line
        normal viws<l
        Expect "hoge huga ([{<poyo>}])" to_be_current_line
        normal viws"l
        Expect "hoge huga ([{<\"poyo\">}])" to_be_current_line
        normal viws'l
        Expect "hoge huga ([{<\"'poyo'\">}])" to_be_current_line
        normal viws`l
        Expect "hoge huga ([{<\"'`poyo`'\">}])" to_be_current_line
        echon ' '
    end

    it 'appends blocks to a characterwise object which is head of line.'
        Line "hoge huga poyo"
        normal! gg0
        normal siw(l
        Expect "(hoge) huga poyo" to_be_current_line
        normal siw[l
        Expect "([hoge]) huga poyo" to_be_current_line
        normal siw{l
        Expect "([{hoge}]) huga poyo" to_be_current_line
        normal siw<l
        Expect "([{<hoge>}]) huga poyo" to_be_current_line
        normal siw"l
        Expect "([{<\"hoge\">}]) huga poyo" to_be_current_line
        normal siw'l
        Expect "([{<\"'hoge'\">}]) huga poyo" to_be_current_line
        normal siw`l
        Expect "([{<\"'`hoge`'\">}]) huga poyo" to_be_current_line
        echon ' '
    end

    it 'does not ignore spaces both side of the block when g:operator#surround#ignore_space is 0.'
        let saved = g:operator#surround#ignore_space
        let g:operator#surround#ignore_space = 0

        Line "'   foo   bar   baz   '"
        normal! gg0ff
        normal si'(
        Expect "'(   foo   bar   baz   )'" to_be_current_line

        let g:operator#surround#ignore_space = saved
    end

    it 'ignore spaces both side of the block.'
        Line "'   foo   bar   baz   '"
        normal! gg0ff
        normal si'(
        Expect "'   (foo   bar   baz)   '" to_be_current_line
    end
    " }}}

    " linewise {{{
    it 'appends blocks to linewise object with an operator mapping.'
        1Line "hoge huga poyo"
        2Line "hoge huga poyo"
        normal! gg0

        normal sip(
        Expect getline(1).getline(2) =~# '^(.\+)$'

        normal sip{
        Expect getline(1).getline(2) =~# '^{(.\+)}$'

        normal sip[
        Expect getline(1).getline(2) =~# '^\[{(.\+)}]$'

        normal sip<
        Expect getline(1).getline(2) =~# '^<\[{(.\+)}]>$'

        normal sip" to_be_current_line
        Expect getline(1).getline(2) =~# '^"<\[{(.\+)}]>"$'

        normal sip'
        Expect getline(1).getline(2) =~# '^''"<\[{(.\+)}]>"''$'

        normal sip`
        Expect getline(1).getline(2) =~# '^`''"<\[{(.\+)}]>"''`$'

        normal sip )
        Expect getline(1).getline(2) =~# '^( `''"<\[{(.\+)}]>"''` )$'

        normal sip }
        Expect getline(1).getline(2) =~# '^{ ( `''"<\[{(.\+)}]>"''` ) }$'
    end

    it 'appends blocks to linewise object with an visual mode mapping.'
        1Line "hoge huga poyo"
        2Line "hoge huga poyo"
        normal! gg0

        normal vips(
        Expect getline(1).getline(2) =~# '^(.\+)$'

        normal vips{
        Expect getline(1).getline(2) =~# '^{(.\+)}$'

        normal vips[
        Expect getline(1).getline(2) =~# '^\[{(.\+)}]$'

        normal vips<
        Expect getline(1).getline(2) =~# '^<\[{(.\+)}]>$'

        normal vips" to_be_current_line
        Expect getline(1).getline(2) =~# '^"<\[{(.\+)}]>"$'

        normal vips'
        Expect getline(1).getline(2) =~# '^''"<\[{(.\+)}]>"''$'

        normal vips`
        Expect getline(1).getline(2) =~# '^`''"<\[{(.\+)}]>"''`$'

        normal vips )
        Expect getline(1).getline(2) =~# '^( `''"<\[{(.\+)}]>"''` )$'

        normal vips }
        Expect getline(1).getline(2) =~# '^{ ( `''"<\[{(.\+)}]>"''` ) }$'
    end
    " }}}

    " blockwise {{{
    it 'appends blocks to a blockwise object with an visual mode mapping.'
        1Line "hoge huga poyo"
        2Line "hoge huga poyo"
        execute 'normal' "gg0w\<C-v>jt\<Space>s("
        Expect getline(1) ==# "hoge (huga) poyo"
        Expect getline(2) ==# "hoge (huga) poyo"

        execute 'normal' "gg0w\<C-v>jt\<Space>s{"
        Expect getline(1) ==# "hoge {(huga)} poyo"
        Expect getline(2) ==# "hoge {(huga)} poyo"

        execute 'normal' "gg0w\<C-v>jt\<Space>s["
        Expect getline(1) ==# "hoge [{(huga)}] poyo"
        Expect getline(2) ==# "hoge [{(huga)}] poyo"

        execute 'normal' "gg0w\<C-v>jt\<Space>s\""
        Expect getline(1) ==# "hoge \"[{(huga)}]\" poyo"
        Expect getline(2) ==# "hoge \"[{(huga)}]\" poyo"

        execute 'normal' "gg0w\<C-v>jt\<Space>s'"
        Expect getline(1) ==# "hoge '\"[{(huga)}]\"' poyo"
        Expect getline(2) ==# "hoge '\"[{(huga)}]\"' poyo"

        execute 'normal' "gg0w\<C-v>jt\<Space>s<"
        Expect getline(1) ==# "hoge <'\"[{(huga)}]\"'> poyo"
        Expect getline(2) ==# "hoge <'\"[{(huga)}]\"'> poyo"

        execute 'normal' "gg0w\<C-v>jt\<Space>s\<Space>)"
        Expect getline(1) ==# "hoge ( <'\"[{(huga)}]\"'> ) poyo"
        Expect getline(2) ==# "hoge ( <'\"[{(huga)}]\"'> ) poyo"

        echon ' '
    end
    " }}}

end

