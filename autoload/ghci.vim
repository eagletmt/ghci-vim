let s:ghci = {'is_valid': 0}
let s:ghc_version = []

function! ghci#init()"{{{
  if has_key(s:ghci, 'kill')
    " kill SIGTERM
    call s:ghci.kill(15)
  endif
  let s:ghci = vimproc#popen2(['ghci'])
  let l:output = s:read_until_prompt(s:ghci, 'Prelude> ')
  let s:ghc_version = matchlist(l:output, 'version \(\d\+\)\.\(\d\+\)\.\(\d\+\)')[1:3]

  " set prompt for convenience
  call s:ghci.stdin.write(":set prompt >\n")
  call s:read_until_prompt(s:ghci, '>')
  " force recompile
  call s:ghci.stdin.write(":set -fforce-recomp\n")
  call s:read_until_prompt(s:ghci, '>')
endfunction"}}}

function! ghci#quit()"{{{
  if s:ghci.is_valid
    let l:str = ":quit\n"
    call s:ghci.stdin.write(l:str)
    let [l:cond, l:status] = s:ghci.waitpid()
    if l:cond != 'exit'
      " kill SIGTERM
      call s:ghci.kill(15)
    endif
    let s:ghci = {'is_valid': 0}
    return l:status
  endif
endfunction"}}}

function! ghci#type(expr)"{{{
  let l:ghci = s:ghci_process()
  let l:str = ':type ' . a:expr . "\n"
  if l:ghci.stdin.write(l:str) == strlen(l:str)
    let l:output = s:read_until_prompt(l:ghci, '>')
    if empty(l:output)
      let l:output = s:read_error(l:ghci)
      return [0, substitute(l:output, '^<interactive>:', '', '')]
    else
      return [1, l:output]
    endif
  else
    return [0, 'vimproc write error']
  endif
endfunction"}}}

function! ghci#info(symbol)"{{{
  let l:ghci = s:ghci_process()
  let l:str = ':info ' . a:symbol . "\n"
  if l:ghci.stdin.write(l:str) == strlen(l:str)
    let l:output = s:read_until_prompt(l:ghci, '>')
    if empty(l:output)
      let l:output = s:read_error(l:ghci)
      return [0, l:output]
    else
      return [1, l:output]
    endif
  else
    return [0, 'vimproc write error']
  endif
endfunction"}}}

function! ghci#load(path)"{{{
  let l:ghci = s:ghci_process()
  let l:str = ':load ' . a:path . "\n"
  if l:ghci.stdin.write(l:str) == strlen(l:str)
    let l:output = s:read_until_prompt(l:ghci, '>')
    if empty(l:output)
      let l:output = s:read_error(l:ghci)
      let l:output = substitute(l:output, '^<no location info>:\n', '', '')
      return [0, l:output]
    elseif l:output =~# 'Failed'
      let l:output = s:read_error(l:ghci)
      return [0, l:output]
    else
      " ignore 'Compiling' message
      if s:ghc_version[0] >= 7
        " GHC 7 send message to stdout
        let l:lines = split(l:output, '\n')
        call filter(l:lines, printf("v:val !~# '%s'", '^\[\d\+\s\+of\s\+\d\+\]\s\+Compiling\s'))
        let l:output = join(l:lines, "\n")
      else
        call s:read_error(l:ghci)
      endif
      return [1, l:output]
    endif
  else
    return [0, 'vimproc write error']
  endif
endfunction"}}}

function! ghci#module(mod)"{{{
  let l:ghci = s:ghci_process()
  let l:str = ':module +' . a:mod . "\n"
  if l:ghci.stdin.write(l:str) == strlen(l:str)
    call s:read_until_prompt(l:ghci, '>')
    let l:output = s:read_error(l:ghci)
    if empty(l:output)
      return [1, '']
    else
      return [0, l:output]
    endif
  endif
endfunction"}}}

function! ghci#send(str)"{{{
  let l:ghci = s:ghci_process()
  if l:ghci.stdin.write(a:str) == strlen(a:str)
    let l:output = s:read_until_prompt(l:ghci, '>')
    if empty(l:output)
      let l:output = s:read_error(l:ghci)
      return [0, l:output]
    else
      return [1, l:output]
    endif
  else
    return [1, 'vimproc write error']
  endif
endfunction"}}}

" utils
function! s:ghci_process()"{{{
  if !s:ghci.is_valid
    call ghci#init()
  endif
  return s:ghci
endfunction"}}}

function! s:read_until_prompt(proc, prompt)"{{{
  let l:regex = '\n' . a:prompt . '$'
  let l:output = a:proc.stdout.read(-1, 100)
  while empty(l:output)
    let l:output = a:proc.stdout.read(-1, 100)
  endwhile
  if l:output == a:prompt
    " no output
    return ''
  endif
  while l:output !~# l:regex
    let l:output .= a:proc.stdout.read(-1, 100)
  endwhile
  " delete prompt
  let l:output =  substitute(l:output, l:regex, '', '')
  return l:output
endfunction"}}}

function! s:read_error(proc)"{{{
  let l:output = a:proc.stderr.read(-1, 100)
  " strip
  let l:output =  substitute(l:output, '^\(\n\|\s\)*', '', '')
  let l:output = substitute(l:output, '\(\n\|\s\)*$', '', '')
  return l:output
endfunction"}}}
