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

describe '<Plug>(operator-surround-delete)'
    before
        map s <Plug>(operator-surround-delete)
        new
    end

    after
        close!
        unmap s
    end

    " error handling {{{
    it 'echos an error when no block is found in the object'
        Line 'hoge huga poyo'
        Expect 'normal gg0wsiw' to_throw_exception
        Expect 'normal gg0wviws' to_throw_exception
        try
            Expect 'normal gg0wsiw' not to_move_cursor
            Expect 'normal gg0wviws' not to_move_cursor
        catch
        endtry
    end

    " special case
    it 'deletes a block in the object at the end of line'
        Line 'hoge huga(poyo)'
        normal gg03wsa(
        Expect 'hoge hugapoyo' to_be_current_line
    end
    " }}}

    " characterwise {{{
    it 'deletes blocks in a characterwise object with an operator mapping'
        Line "hoge \"'[<({huga})>]'\" piyo"
        normal! gg0ww
        normal siWw
        Expect getline('.') ==# "hoge '[<({huga})>]' piyo"
        normal siWw
        Expect getline('.') ==# "hoge [<({huga})>] piyo"
        normal siWw
        Expect getline('.') ==# "hoge <({huga})> piyo"
        normal siWw
        Expect getline('.') ==# "hoge ({huga}) piyo"
        normal siWw
        Expect getline('.') ==# "hoge {huga} piyo"
        normal siWw
        Expect getline('.') ==# "hoge huga piyo"
    end
    " }}}

    " linewise {{{
    " TODO not implemented
    " }}}

    " blockwise {{{
    " TODO not implemented
    " }}}

end
