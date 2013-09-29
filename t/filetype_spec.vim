let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir
set rtp+=/Users/rhayasd/Github/vim-operator-surround

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

describe 'filetype specific settings'

    before
        map sa <Plug>(operator-surround-append)
        map sd <Plug>(operator-surround-delete)
        set ft=ruby
        let g:operator#surround#blocks = {}
        let g:operator#surround#blocks['ruby'] = [
                    \   { 'block' : ["do\n", "\nend"],  'motionwise' : ['char', 'line', 'block'], 'keys' : ['do'] },
                    \   { 'block' : ["{|i| ", " }"],  'motionwise' : ['char', 'line', 'block'], 'keys' : ['{'] },
                    \ ]
    end

    after
        close!
        unmap sa
        unmap sd
    end

    it 'reflect'
        Line "hoge"
        normal gg0saiwdo
        Expect getline(1) ==# 'do'
        Expect getline(2) ==# 'hoge'
        Expect getline(3) ==# 'end'
    end

    it 'has higher priority than ''-'''
        Line "hoge"
        normal gg0saiw{
        Expect getline('.') ==# '{|i| hoge }'
    end
end
