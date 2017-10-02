let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

command! -nargs=+ -count=1 Line call setline(<count>, <args>)

describe 'auto indentation'

    before
        map sa <Plug>(operator-surround-append)
        map sr <Plug>(operator-surround-replace)
        new
        set autoindent
        set cindent
        set smartindent
    end

    after
        close!
        unmap sa
        unmap sr
    end

    it 'doesn''t make auto indentation when inserting surrounds'
        Line '    hoge'

        " at 'h'
        normal! gg0w

        normal saiw{
        Expect getline('.') ==# '    {hoge}'
    end

    it 'doesn''t make auto indentation when replacing surrounds'
        Line '    ahogea'

        " at 'h'
        normal! gg0w

        normal sriw{
        Expect getline('.') ==# '    {hoge}'
    end

end

describe 'backslash in surrounds'
    before
        let s:saved_blocks = g:operator#surround#blocks
        let g:operator#surround#blocks = {}
        let g:operator#surround#blocks['-'] = [
            \  {'block' : ['\', '\'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['\']},
            \  {'block' : ['(', ')'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['(', ')']},
            \ ]
        new
        map <buffer>sa <Plug>(operator-surround-append)
        map <buffer>sr <Plug>(operator-surround-replace)
    end

    after
        close!
        let g:operator#surround#blocks = s:saved_blocks
    end

    it 'can be contained in surroundings (#18, #31)'
        Line 'hoge'
        normal saiw\
        Expect getline('.') ==# '\hoge\'
    end

    it 'can be replaced properly as target'
        Line '\hoge\'
        normal! gg0v$
        normal sr(
        Expect getline('.') ==# '(hoge)'
    end
end
