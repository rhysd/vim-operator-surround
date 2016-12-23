let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

command! -nargs=+ -count=1 Line call setline(<count>, <args>)

describe '<Plug>(operator-surround-delete)'
    before
        let g:operator#surround#uses_input_if_no_block = 0
        map s <Plug>(operator-surround-delete)
        new
    end

    after
        close!
        unmap s
    end

    " error handling {{{
    it 'echos an error when no block is found in the object if g:operator#surround#uses_input_if_no_block is not specified'
        Line 'hoge huga poyo'
        redir => buffer
            silent normal gg0wsiw
        redir END
        Expect buffer =~# 'no block matches to the region'
        let buffer = ''
        redir => buffer
            silent normal gg0wviws
        redir END
        Expect buffer =~# 'no block matches to the region'
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
    it 'deletes blocks in a linewise object with an operator mapping'
        1Line ''
        2Line "\"'[<({huga huga "
        3Line "piyo})>]'\""
        normal 2ggsip
        Expect getline(2).getline(3) ==# "'[<({huga huga piyo})>]'"
        normal 2ggsip
        Expect getline(2).getline(3) ==# "[<({huga huga piyo})>]"
        normal 2ggsip
        Expect getline(2).getline(3) ==# "<({huga huga piyo})>"
        normal 2ggsip
        Expect getline(2).getline(3) ==# "({huga huga piyo})"
        normal 2ggsip
        Expect getline(2).getline(3) ==# "{huga huga piyo}"
        normal 2ggsip
        Expect getline(2).getline(3) ==# "huga huga piyo"
    end
    " }}}

    " blockwise {{{
    it 'deletes blocks in a blockwise object with an operator mapping'
        1Line '(hoge)'
        2Line '[huga]'
        3Line '<piyo>'
        4Line '"hoge"'
        5Line '{huga}'
        6Line "'piyo'"
        execute "normal! gg\<C-v>G$"
        normal s
        Expect getline(1) ==# 'hoge'
        Expect getline(2) ==# 'huga'
        Expect getline(3) ==# 'piyo'
        Expect getline(4) ==# 'hoge'
        Expect getline(5) ==# 'huga'
        Expect getline(6) ==# 'piyo'
    end

    it 'deletes blocks in a blockwise object when it includes the line which is shorter than the object'
        1Line '(hogeee)'
        2Line '[huga]'
        3Line '<piyopoyo>'
        execute "normal! gg\<C-v>G$"
        normal s
        Expect getline(1) ==# 'hogeee'
        Expect getline(2) ==# 'huga'
        Expect getline(3) ==# 'piyopoyo'
    end
    " }}}

    " for issues {{{
    it 'does not occur an error when :set selection=exclusive (Issue #1)'
        let selection = &selection
        set selection=exclusive

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

        let &selection = selection
    end

    it 'does not pollute unnamed registers (Pull request #9)'
        call setreg('"', 'vim kawaii', 'v')
        Line "hoge \"'[<({huga})>]'\" piyo"
        normal! gg0ww
        normal siWw

        Expect getreg('"') ==# 'vim kawaii'
        Expect getregtype('"') ==# 'v'
    end

    " }}}

end
