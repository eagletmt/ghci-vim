command! -buffer -nargs=0 GhciQuit call ghci#quit()
command! -buffer -nargs=? GhciType call s:type(<q-args>)
command! -buffer -nargs=? GhciInfo call s:info(<q-args>)
command! -buffer -nargs=0 GhciLoad call s:load()
command! -buffer -nargs=1 GhciModule call s:module(<q-args>)
command! -buffer -nargs=+ GhciSend call s:send(<q-args>)

nnoremap <buffer> <silent> <LocalLeader>t :<C-u>GhciType<CR>
nnoremap <buffer> <silent> <LocalLeader>i :<C-u>GhciInfo<CR>
nnoremap <buffer> <silent> <LocalLeader>l :<C-u>GhciLoad<CR>

augroup ghci
  autocmd!
  autocmd VimLeave * call ghci#quit()
augroup END

function! s:type(qarg)"{{{
  if empty(a:qarg)
    let l:expr = expand('<cword>')
  else
    let l:expr = a:qarg
  endif
  let [l:ok, l:ret] = ghci#type(l:expr)
  if l:ok
    echo l:ret
  else
    call s:echo_error(l:ret)
  endif
endfunction"}}}

function! s:info(qarg)"{{{
  if empty(a:qarg)
    let l:symbol = expand('<cword>')
  else
    let l:symbol = matchstr(a:qarg, '^\S\+')
  endif
  let [l:ok, l:ret] = ghci#info(l:symbol)
  if l:ok
    echo l:ret
  else
    call s:echo_error(l:ret)
  endif
endfunction"}}}

function! s:load()"{{{
  let l:path = expand('%:p')
  let l:escaped = substitute(l:path, '"', '\\"', 'g')
  let [l:ok, l:ret] = ghci#load('"' . l:escaped . '"')
  if l:ok
    echo l:ret
  else
    call s:echo_error(l:ret)
  endif
endfunction"}}}

function! s:module(mod)"{{{
  let [l:ok, l:ret] = ghci#module(a:mod)
  if l:ok
    echo 'loaded ' . a:mod
  else
    call s:echo_error(l:ret)
  endif
endfunction"}}}

function! s:send(qarg)"{{{
  let [l:ok, l:ret] = ghci#send(a:qarg . "\n")
  if l:ok
    echo l:ret
  else
    call s:echo_error(l:ret)
  endif
endfunction"}}}

" utils
function! s:echo_error(msg)"{{{
  echohl Error
  echo a:msg
  echohl None
endfunction"}}}
