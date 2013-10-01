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

describe '<Plug>(operator-surround-replace)'
    before
        map s <Plug>(operator-surround-replace)
        new
    end

    after
        close!
        unmap s
    end

    " characterwise {{{
    it 'replace a characterwise object in operator pending mode'
        1Line '"hoge"'
        normal sa"{
        Expect getline('.') ==# '{hoge}'
        normal sa{'
        Expect getline('.') ==# "'hoge'"
        normal sa'[
        Expect getline('.') ==# '[hoge]'
        normal sa[ )
        Expect getline('.') ==# '( hoge )'
    end

    it 'replace a characterwise object in visual mode'
        1Line '"hoge"'
        normal va"s{
        Expect getline('.') ==# '{hoge}'
        normal va{s'
        Expect getline('.') ==# "'hoge'"
        normal va's[
        Expect getline('.') ==# '[hoge]'
        normal va[s )
        Expect getline('.') ==# '( hoge )'
    end
    " }}}

    " linewise {{{
    it 'replace a linewise object in operator pending mode'
        1Line '"hoge huga '
        2Line 'poyo"'
        3Line ''
        normal gg0sip{
        let line = getline(1).getline(2)
        Expect line ==# '{hoge huga poyo}'
        normal gg0sip'
        Expect getline(1).getline(2) ==# "'hoge huga poyo'"
        normal gg0sip[
        Expect getline(1).getline(2) ==# '[hoge huga poyo]'
        normal gg0sip )
        Expect getline(1).getline(2) ==# '( hoge huga poyo )'
    end

    it 'replace a linewise object in visual mode'
        1Line '"hoge huga '
        2Line 'poyo"'
        3Line ''
        normal gg0vips{
        let line = getline(1).getline(2)
        Expect line ==# '{hoge huga poyo}'
        normal gg0vips'
        Expect getline(1).getline(2) ==# "'hoge huga poyo'"
        normal gg0vips[
        Expect getline(1).getline(2) ==# '[hoge huga poyo]'
        normal gg0vips )
        Expect getline(1).getline(2) ==# '( hoge huga poyo )'
    end

    it 'replace even the object is whole code which is a corner case'
        1Line '" hoge huga '
        2Line 'poyo"'
        normal gg0sip{
        Expect getline(1) ==# '{ hoge huga '
        Expect getline(2) ==# 'poyo}'
    end

    " }}}

    " blockwise {{{
    it 'replace a blockwise object in visual mode'
        1Line "(hoge)"
        2Line "(huga)"
        3Line "(poyo)"

        execute 'normal' "gg0\<C-v>G$s{"
        Expect getline(1) ==# "{hoge}"
        Expect getline(2) ==# "{huga}"
        Expect getline(3) ==# "{poyo}"
    end

    it 'replace a blockwise object even if the object is not rectangle'
        1Line "(hogeee)"
        2Line "(huga)"
        3Line "(poyopiyo)"

        execute 'normal' "gg0\<C-v>G$s{"
        Expect getline(1) ==# "{hogeee}"
        Expect getline(2) ==# "{huga}"
        Expect getline(3) ==# "{poyopiyo}"
    end

    it 'replace a blockwise object even if the blocks in the object is not the same'
        1Line "(hogeee)"
        2Line "<huga>"
        3Line "'poyopiyo'"

        execute 'normal' "gg0\<C-v>G$s{"
        Expect getline(1) ==# "{hogeee}"
        Expect getline(2) ==# "{huga}"
        Expect getline(3) ==# "{poyopiyo}"
    end
    " }}}

end
