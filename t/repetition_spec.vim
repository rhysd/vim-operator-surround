let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

function! s:line(str, line)
    call setline(a:line==0 ? 1 : a:line, a:str)
endfunction

command! -nargs=+ -count=0 Line call <SID>line(<args>, <count>)

describe '.'
    before
        map sa <Plug>(operator-surround-append)
        map sd <Plug>(operator-surround-delete)
        map sr <Plug>(operator-surround-replace)
        new
    end

    after
        close!
        unmap sa
        unmap sd
        unmap sr
    end

    it 'repeats appending surrounds to the same object'
        SKIP because it doesn't work properly only in vspec environment
        Line "hoge"
        normal saiw(l
        normal .(l
        Expect getline('.') ==# "((hoge))"
        normal .{l
        Expect getline('.') ==# "(({hoge}))"
        normal .'
        Expect getline('.') ==# "(({'hoge'}))"
    end

    it 'repeats deleting surrounds to the same object'
        SKIP because it doesn't work properly only in vspec environment
        Line  "((((hoge))))"
        normal fhsda(
        normal .
        Expect getline('.') ==# "((hoge))"
        normal .
        Expect getline('.') ==# "(hoge)"
        normal .
        Expect getline('.') ==# "hoge"
    end

    it 'repeats replacing surrounds to the same object'
        SKIP because it doesn't work properly only in vspec environment
        Line  "(hoge)"
        normal sriW{
        normal! ggfh
        normal .(
        Expect getline('.') ==# "(hoge)"
        normal! ggfh
        normal ."
        Expect getline('.') ==# '"hoge"'
        normal .{
        Expect getline('.') ==# "{hoge}"
    end
end
