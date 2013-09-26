if exists('g:loaded_operator_surround')
    finish
endif

call operator#user#define('surround-append', 'operator#surround#append')
call operator#user#define('surround-delete', 'operator#surround#delete')
" TODO unimplemented
call operator#user#define('surround-replace', 'operator#surround#replace')


let g:loaded_operator_surround = 1
