syntax on
set re=0
set ts=4
set sw=4
set et
set ru
set nocompatible
set backspace=indent,eol,start
set autoread
autocmd BufEnter * :syntax sync fromstart
nnoremap <CR> :noh<CR><CR>
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
