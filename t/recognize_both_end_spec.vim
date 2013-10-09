let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

command! -nargs=+ -count=1 Line call setline(<count>, <args>)

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

    it 'deletes both end when they are the same character if they are not block'
        Line "-hoge-"
        normal sdiW
        Expect getline('.') ==# "hoge"
    end

    it 'replaces both end when they are the same character even if they are not block'
        Line "~hoge~"
        normal sriW,
        Expect getline('.') ==# ",hoge,"
    end

    it 'deletes both end when they are the same multi characters if they are not block'
        Line "**hoge**"
        normal sdiW
        Expect getline('.') ==# "hoge"
    end

    it 'replaces both end when they are the same multi characters if they are not block'
        Line "**hoge**"
        normal sriW!
        Expect getline('.') ==# "!hoge!"
    end
end
