let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

command! -nargs=+ -count=1 Line call setline(<count>, <args>)

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

    it 'skips whitespaces (fixes issue #13)'
        Line "hoge('aaa' , 'bbb')"
        normal! gg0fb
        normal sa'"
        Expect getline('.') ==# "hoge('aaa' , \"bbb\")"
        normal Fa
        normal sa'"
        Expect getline('.') ==# "hoge(\"aaa\" , \"bbb\")"
    end

    it 'does not skip whitespaces if g:operator#surround#ignore_space is 0'
        let saved = g:operator#surround#ignore_space
        let g:operator#surround#ignore_space = 0

        Line "( {abc} )"
        normal! gg0fb
        normal si("
        Expect getline('.') ==# "(\"{abc}\")"

        let g:operator#surround#ignore_space = saved
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

    " issue fixes {{{
    it 'ensures to fix #23'
        Line "aaa '' bbb"

        execute 'normal' "gg0f'sa'{"
        Expect getline(1) ==# "aaa { }bbb"

        Line "aaa '   ' bbb"

        execute 'normal' "gg0f'sa'{"
        Expect getline(1) ==# "aaa {    }bbb"
    end
    " }}}
end
