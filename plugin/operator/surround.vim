if exists('g:loaded_operator_surround')
    finish
endif

call operator#user#define('surround-append', 'operator#surround#append')
call operator#user#define('surround-delete', 'operator#surround#delete')
call operator#user#define('surround-replace', 'operator#surround#replace')

nnoremap <Plug>(operator-surround-repeat) .

" hack to input block in advance
if get(g:, 'operator#surround#input_block_in_advance', 0)
    function! s:wrap_operator_mapping(lhs)
        for m in ['n', 'v']
            let map = maparg(a:lhs, m)
            if map !=# ''
                execute m . 'noremap' '<expr><silent><script>' a:lhs 'operator#surround#wrap(' . string(map) . ')'
            endif
        endfor
    endfunction
    call s:wrap_operator_mapping('<Plug>(operator-surround-append)')
    call s:wrap_operator_mapping('<Plug>(operator-surround-replace)')
endif

let g:loaded_operator_surround = 1
