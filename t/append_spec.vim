let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

function! s:line(str, line)
    if a:line == 0
        call setline(1, a:str)
    else
        call setline(a:line, a:str)
    endif
endfunction

command! -nargs=+ -count=0 Line call <SID>line(<args>, <count>)

describe '<Plug>(operator-surround-append)'
    before
        map s <Plug>(operator-surround-append)
        new
    end

    after
        close!
        unmap s
    end

    " error handling {{{
    it 'echos an error message when input is invalid.'
        Line "hoge huga poyo"
        normal! gg0w
        Expect 'normal siw&' to_throw_exception
        Expect 'normal viws&' to_throw_exception
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

