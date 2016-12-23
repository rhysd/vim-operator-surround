if exists('g:loaded_operator_surround')
    finish
endif

call operator#user#define('surround-append', 'operator#surround#append', "call operator#surround#certify_as_keymapping()")
call operator#user#define('surround-delete', 'operator#surround#delete')
call operator#user#define('surround-replace', 'operator#surround#replace', "call operator#surround#certify_as_keymapping()")

nnoremap <Plug>(operator-surround-repeat) .

let g:loaded_operator_surround = 1
