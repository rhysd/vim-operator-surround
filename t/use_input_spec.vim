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
        Line "~hoge~"
        normal sriW,
        Expect getline('.') ==# ",hoge,"
    end
end
