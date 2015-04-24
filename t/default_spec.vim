let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

let g:operator#surround#blocks = {
            \ '-' : [
            \       { 'block' : ['a', 'b'], 'motionwise' : [], 'keys' : ["\<Left>"] }
            \ ],
            \ 'test' : [
            \       { 'block' : ['a', 'b'], 'motionwise' : [], 'keys' : ["\<Left>"] }
            \ ]
            \ }

try
    call feedkeys('(')
    call operator#surround#append('char')
catch
endtry

describe 'Default settings'
    it 'provide variables to customize'
        Expect 'g:operator#surround#blocks' to_exist
        Expect g:operator#surround#blocks == {
                \   'test' : [
                \       { 'block' : ['a', 'b'], 'motionwise' : [], 'keys' : ["\<Left>"] },
                \   ],
                \   '-' : [
                \       { 'block' : ['a', 'b'], 'motionwise' : [], 'keys' : ["\<Left>"] },
                \       { 'block' : ['(', ')'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['(', ')'] },
                \       { 'block' : ['[', ']'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['[', ']'] },
                \       { 'block' : ['{', '}'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['{', '}'] },
                \       { 'block' : ['<', '>'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['<', '>'] },
                \       { 'block' : ['"', '"'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['"'] },
                \       { 'block' : ["'", "'"], 'motionwise' : ['char', 'line', 'block'], 'keys' : ["'"] },
                \       { 'block' : ['`', '`'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['`'] },
                \       { 'block' : ['( ', ' )'], 'motionwise' : ['char', 'line', 'block'], 'keys' : [' (', ' )'] },
                \       { 'block' : ['{ ', ' }'], 'motionwise' : ['char', 'line', 'block'], 'keys' : [' {', ' }'] },
                \       { 'block' : ['$', '$'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['d'] },
                \   ],
                \ }
        for [_, ft] in items(g:operator#surround#blocks)
            for b in ft
                for [k, v] in items(b)
                    Expect k to_be_string
                    Expect k =~# '\(block\|motionwise\|keys\)'
                    Expect v to_be_list
                endfor
            endfor
        endfor

        Expect 'g:operator#surround#uses_input_if_no_block' to_exist_and_default_to 1
        Expect 'g:operator#surround#recognizes_both_ends_as_surround' to_exist_and_default_to 1
        Expect 'g:operator#surround#ignore_space' to_exist_and_default_to 1

        Expect g:operator#surround#default_blocks ==
                \ {
                \   '-' : [
                \       { 'block' : ['(', ')'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['(', ')'] },
                \       { 'block' : ['[', ']'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['[', ']'] },
                \       { 'block' : ['{', '}'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['{', '}'] },
                \       { 'block' : ['<', '>'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['<', '>'] },
                \       { 'block' : ['"', '"'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['"'] },
                \       { 'block' : ["'", "'"], 'motionwise' : ['char', 'line', 'block'], 'keys' : ["'"] },
                \       { 'block' : ['`', '`'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['`'] },
                \       { 'block' : ['( ', ' )'], 'motionwise' : ['char', 'line', 'block'], 'keys' : [' (', ' )'] },
                \       { 'block' : ['{ ', ' }'], 'motionwise' : ['char', 'line', 'block'], 'keys' : [' {', ' }'] },
                \       { 'block' : ['$', '$'], 'motionwise' : ['char', 'line', 'block'], 'keys' : ['d'] },
                \   ],
                \ }
    end

    it 'provide functions to make operator'
        Expect '*operator#surround#append' to_exist
        Expect '*operator#surround#replace' to_exist
        Expect '*operator#surround#delete' to_exist
    end

    it 'provide default <Plug> mappings'
        Expect maparg('<Plug>(operator-surround-append)') not to_be_empty
        Expect maparg('<Plug>(operator-surround-replace)') not to_be_empty
        Expect maparg('<Plug>(operator-surround-delete)') not to_be_empty
    end

    it 'can''t change the default blocks'
        Expect 'let g:operator#surround#default_blocks.a = 0' to_throw_exception
    end
end

