let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir
set rtp+=/Users/rhayasd/Github/vim-operator-surround

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

command! -nargs=+ -count=1 Line call setline(<count>, <args>)

describe 'filetype specific settings'

    before
        map sa <Plug>(operator-surround-append)
        map sd <Plug>(operator-surround-delete)
        new
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

    it 'are reflected on appending and deleting surrounds'
        Line "hoge"
        normal gg0saiwdo
        Expect getline(1) ==# 'do'
        Expect getline(2) ==# 'hoge'
        Expect getline(3) ==# 'end'
        normal gg0vG$sd
        Expect getline(1) ==# 'hoge'
    end

    it 'has higher priority than ''-'''
        Line "hoge"
        normal gg0saiw{
        Expect getline('.') ==# '{|i| hoge }'
        normal gg0v$sd
        Expect getline(1) ==# 'hoge'
    end
end
