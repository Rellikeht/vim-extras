if has("nvim")
  " Because extras.lua is for nvim
  finish
endif
if exists("g:loaded_vim_extras")
  finish
endif
let g:loaded_vim_extras = 1

" vimscript specific utilities {{{

" }}}

" general utilities {{{

" roots {{{

function extras#get_root(cmd, dir='')
  if a:dir == ''
    return systemlist(a:cmd)[0]
  endif
  return systemlist('cd '.a:dir.' && '.a:cmd)[0]
endfunction

function extras#git_root(dir='')
  return extras#get_root('git rev-parse --show-toplevel', a:dir)
endfunction

function extras#hg_root(dir='')
  return extras#get_root('hg root', a:dir)
endfunction

function extras#part_root(dir='')
  return extras#get_root("df -P . | awk '/^\\// {print $6}'", a:dir)
endfunction

function extras#envrc_root(dir='')
  let l:root = extras#get_root(
        \ 'direnv status | '.
        \ "sed -En 's#Found RC path (.*)/[^/]*#\\1#p'",
        \ a:dir)
  if l:root == ''
    throw 'Not in direnv environment'
  endif
  return l:root
endfunction

" }}}

" completion utils {{{ 

" TODO transfer

function extras#complete_list(list, lead, cmdline, curpos)
  let completions = []
  for e in a:list
    if e =~ '^'.a:lead
      let completions = add(completions, e)
    endif
  endfor
  return completions
endfunction

function extras#get_list_compl(list)
  return {lead, cmdline, curpos ->
        \ CompleteList(a:list, lead, cmdline, curpos)
        \ }
endfunction

" }}} 

" command helpers {{{

" TODO how to properly have closures
function extras#count_on_function(fn, arg, name="count1")
  let l:fn = a:fn
  let l:arg = a:arg
  let l:name = a:name
  function! s:helper() closure abort
    for _ in range(v:[l:name])
      call call(l:fn, [l:arg])
    endfor
  endfunction
  return { -> s:helper() }
endfunction

function extras#get_netrw_fp() abort
  return b:netrw_curdir."/".netrw#Call("NetrwGetWord")
endfunction

function B(n=1)
  return ".." .. repeat("/..", (a:n)-1)
endfunction

" }}}

" TODO

" }}}

" commands {{{

" TODO

" }}}
