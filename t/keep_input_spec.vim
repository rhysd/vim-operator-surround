let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

command! -nargs=+ -count=1 Line call setline(<count>, <args>)

describe 'g:operator#surround#keeps_input_if_no_block'

    before
        let g:operator#surround#keeps_input_if_no_block = 1
        map sa <Plug>(operator-surround-append)
        map sr <Plug>(operator-surround-replace)
        new
    end

    after
        close!
        unmap sa
        unmap sr
    end

    it 'keeps input until the input is a block'
        Line "hoge"
        normal saiw,test(
        Expect getline('.') ==# ",test(hoge)"
    end

    it 'replaces input with blocks and characters kept while the input is not a block'
        Line "(hoge)"
        normal sra(,test[
        Expect getline('.') ==# ",test[hoge]"
    end

    it 'can work with multibyte block keys'
        call add(g:operator#surround#blocks['-'], {'block': ['foo', 'oof'], 'motionwise': ['char', 'line', 'block'], 'keys': ['foo'] })
        Line "hoge"
        normal saiw,foo
        Expect getline('.') ==# ",foohogeoof"
    end

    it 'make g:operator#surround#uses_input_if_no_block take no effect'
        let g:operator#surround#uses_input_if_no_block = 0
        Line "hoge"
        normal saiw,test[
        Expect getline('.') ==# ",test[hoge]"
        unlet g:operator#surround#uses_input_if_no_block
    end
end
