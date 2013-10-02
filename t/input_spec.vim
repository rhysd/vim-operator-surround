let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

describe 'input'
    before
        map s <Plug>(operator-surround-append)
        new
    end

    after
        close!
        unmap s
    end

    it 'is canceled with <C-c>'
        call setline(1, 'aaa')
        let prev_line = getline('.')
        let prev_linum = line('$')
        execute 'normal' "siw\<C-c>"
        Expect prev_line == 'aaa'
        Expect prev_linum == line('$')
    end

    it 'is canceled with <Esc>'
        call setline(1, 'aaa')
        let prev_line = getline('.')
        let prev_linum = line('$')
        execute 'normal' "siw\<Esc>"
        Expect prev_line == 'aaa'
        Expect prev_linum == line('$')
    end
end
