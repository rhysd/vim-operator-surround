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

describe 'g:operator#surround#recognizes_both_end_as_surround'

    before
        let g:operator#surround#recognizes_both_end_as_surround = 1
        map sd <Plug>(operator-surround-delete)
        map sr <Plug>(operator-surround-replace)
        new
    end

    after
        close!
        unmap sd
        unmap sr
    end

    it 'deltes both end when they are the same character if they are not block'
        Line "-hoge-"
        normal sdiW
        Expect getline('.') ==# "hoge"
    end

    it 'replaces both end when they are the same character even if they are not block'
        Line "~hoge~"
        normal sriW,
        Expect getline('.') ==# ",hoge,"
    end
end
