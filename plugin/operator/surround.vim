if exists('g:loaded_operator_surround')
    finish
endif

call operator#user#define('surround-append', 'operator#surround#append')
call operator#user#define('surround-delete', 'operator#surround#delete')
call operator#user#define('surround-replace', 'operator#surround#replace')

nnoremap <Plug>(operator-surround-repeat) .

nmap <silent><expr><Plug>(operator-surround-append-input-in-advance) operator#surround#input_before("\<Plug>(operator-surround-append)")
nmap <silent><expr><Plug>(operator-surround-replace-input-in-advance) operator#surround#input_before("\<Plug>(operator-surround-replace)")

let g:loaded_operator_surround = 1
