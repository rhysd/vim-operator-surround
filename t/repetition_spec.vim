let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

command! -nargs=+ -count=1 Line call setline(<count>, <args>)

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
        SKIP "because it doesn't work properly only in vspec environment"
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
        SKIP "because it doesn't work properly only in vspec environment"
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
        SKIP "because it doesn't work properly only in vspec environment"
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
