if exists('g:loaded_operator_surround')
    finish
endif

call operator#user#define('surround-append', 'operator#surround#append', 'call operator#surround#from_keymap()')
call operator#user#define('surround-delete', 'operator#surround#delete')
call operator#user#define('surround-replace', 'operator#surround#replace', 'call operator#surround#from_keymap()')

nnoremap <Plug>(operator-surround-repeat) .

let g:loaded_operator_surround = 1
