if exists('g:loaded_operator_surround')
    finish
endif

call operator#user#define('surround-append', 'operator#surround#append')
" TODO unimplemented
call operator#user#define('surround-replace', 'operator#surround#replace')
" TODO unimplemented
call operator#user#define('surround-delete', 'operator#surround#delete')


let g:loaded_operator_surround = 1
