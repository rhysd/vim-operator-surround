let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir

call vspec#matchers#load()

set rtp+=~/.vim/bundle/vim-operator-user
runtime plugin/operator/surround.vim

function! s:line(str, line)
    if a:line == 0
        call setline(1, a:str)
    else
        call setline(a:1, a:str)
    endif
endfunction

command! -nargs=+ -count=0 Line call <SID>line(<args>, <count>)

" characterwise {{{
describe '<Plug>(operator-surround-append)'
    before
        map s <Plug>(operator-surround-append)
        new
    end

    after
        close!
        unmap s
    end

    it 'appends blocks to inner word with an operator mapping'
        Line "hoge huga poyo"
        normal! gg0w
        normal siw(l
        Expect getline('.') ==# "hoge (huga) poyo"
        normal siw[l
        Expect getline('.') ==# "hoge ([huga]) poyo"
        normal siw{l
        Expect getline('.') ==# "hoge ([{huga}]) poyo"
        normal siw<l
        Expect getline('.') ==# "hoge ([{<huga>}]) poyo"
        normal siw"l
        Expect getline('.') ==# "hoge ([{<\"huga\">}]) poyo"
        normal siw'l
        Expect getline('.') ==# "hoge ([{<\"'huga'\">}]) poyo"
        normal siw`l
        Expect getline('.') ==# "hoge ([{<\"'`huga`'\">}]) poyo"
        normal siw )ll
        Expect getline('.') ==# "hoge ([{<\"'`( huga )`'\">}]) poyo"
        normal siw }ll
        Expect getline('.') ==# "hoge ([{<\"'`( { huga } )`'\">}]) poyo"
        echon ' '
    end

    it 'appends blocks to inner word with visual mode mapping'
        Line "hoge huga poyo"
        normal! gg0ww
        normal viws(l
        Expect getline('.') ==# "hoge huga (poyo)"
        normal viws[l
        Expect getline('.') ==# "hoge huga ([poyo])"
        normal viws{l
        Expect getline('.') ==# "hoge huga ([{poyo}])"
        normal viws<l
        Expect getline('.') ==# "hoge huga ([{<poyo>}])"
        normal viws"l
        Expect getline('.') ==# "hoge huga ([{<\"poyo\">}])"
        normal viws'l
        Expect getline('.') ==# "hoge huga ([{<\"'poyo'\">}])"
        normal viws`l
        Expect getline('.') ==# "hoge huga ([{<\"'`poyo`'\">}])"
        echon ' '
    end

    it 'appends blocks to inner word which is head of line'
        Line "hoge huga poyo"
        normal! gg0
        normal siw(l
        Expect getline('.') ==# "(hoge) huga poyo"
        normal siw[l
        Expect getline('.') ==# "([hoge]) huga poyo"
        normal siw{l
        Expect getline('.') ==# "([{hoge}]) huga poyo"
        normal siw<l
        Expect getline('.') ==# "([{<hoge>}]) huga poyo"
        normal siw"l
        Expect getline('.') ==# "([{<\"hoge\">}]) huga poyo"
        normal siw'l
        Expect getline('.') ==# "([{<\"'hoge'\">}]) huga poyo"
        normal siw`l
        Expect getline('.') ==# "([{<\"'`hoge`'\">}]) huga poyo"
        echon ' '
    end

    it 'echos an error message when input is invalid'
        Line "hoge huga poyo"
        normal! gg0w
        Expect 'normal siw&' to_throw_exception
        Expect 'normal viws&' to_throw_exception
        try
            Expect 'normal siw&' not to_move_cursor
            Expect 'normal viws&' not to_move_cursor
        catch
        endtry
    end
end
" }}}

" linewise {{{
" TODO not implemented yet
" }}}

" blockwise {{{
" TODO not implemented yet
" }}}
