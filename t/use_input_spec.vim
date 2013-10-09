let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

command! -nargs=+ -count=1 Line call setline(<count>, <args>)

describe 'g:operator#surround#uses_input_if_no_block'

    before
        let g:operator#surround#uses_input_if_no_block = 1
        map sa <Plug>(operator-surround-append)
        map sr <Plug>(operator-surround-replace)
        new
    end

    after
        close!
        unmap sa
        unmap sr
    end

    it 'appends input if the input is not a block'
        Line "hoge"
        normal saiw,
        Expect getline('.') ==# ",hoge,"
    end

    it 'replaces input if the input is not a block'
        Line "(hoge)"
        normal sra(,
        Expect getline('.') ==# ",hoge,"
    end
end
