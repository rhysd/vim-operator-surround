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
        echomsg string(getline(1, '$'))
        normal gg0sip{
        echomsg string(getline(1, '$'))
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
        echomsg string(getline(1, '$'))
        normal gg0vips{
        echomsg string(getline(1, '$'))
        let line = getline(1).getline(2)
        Expect line ==# '{hoge huga poyo}'
        normal gg0vips'
        Expect getline(1).getline(2) ==# "'hoge huga poyo'"
        normal gg0vips[
        Expect getline(1).getline(2) ==# '[hoge huga poyo]'
        normal gg0vips )
        Expect getline(1).getline(2) ==# '( hoge huga poyo )'
    end
    " }}}

    " blockwise {{{
    " it 'replace a blockwise object in visual mode' 
    " end                                            
    " }}}
end
