if has("nvim")
  " Because extras.lua is for nvim
  finish
endif
if exists("g:loaded_vim_extras")
  finish
endif
let g:loaded_vim_extras = 1

" vimscript specific utilities {{{

function s:escape_qargs(arg) abort
  return escape(a:arg, '<%#')
endfunction

function extras#split_qargs(arg) abort
  return split(s:escape_qargs(a:arg), '[^\\]\zs ')
endfunction

" }}}

" general utils {{{

" }}}

" roots {{{

function extras#get_root(cmd, dir='') abort
  if a:dir == ''
    return systemlist(a:cmd)[0]
  endif
  return systemlist('cd '.a:dir.' && '.a:cmd)[0]
endfunction

function extras#git_root(dir='') abort
  return extras#get_root('git rev-parse --show-toplevel', a:dir)
endfunction

function extras#hg_root(dir='') abort
  return extras#get_root('hg root', a:dir)
endfunction

function extras#part_root(dir='') abort
  return extras#get_root("df -P . | awk '/^\\// {print $6}'", a:dir)
endfunction

function extras#envrc_root(dir='') abort
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

function extras#list_completion_builder(list, lead, cmdline, curpos) abort
  if &completeopt =~ "fuzzy"
    return matchfuzzy(a:list, a:lead)
  endif
  " TODO more native solution
  let l:completions = []
  for e in a:list
    if e =~ '^'.a:lead
      call add(l:completions, e)
    endif
  endfor
  return l:completions
endfunction

function extras#list_completion(list) abort
  return {lead, cmdline, curpos ->
        \ extras#list_completion_builder(a:list, lead, cmdline, curpos)
        \ }
endfunction

function extras#args_complete(lead, cmdline, cursorpos) abort
  " Completes files from arglist
  let l:comps = deepcopy(getcompletion(a:lead, "arglist"))
  call map(l:comps, "fnameescape(v:val)")
  return l:comps
endfunction

" }}} 

" command helpers {{{

" TODO how to properly have closures
function extras#count_on_function(fn, arg, name="count1") abort
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

function B(n=1) abort
  return ".." .. repeat("/..", (a:n)-1)
endfunction

function extras#command_on_expanded(command, args) abort
  let l:visited = {}
  for arg in a:args
    for file in split(expand(arg), "\n")
      if !has_key(l:visited, file)
        exe a:command." ".fnameescape(file)
        let l:visited[file] = 1
      endif
    endfor
  endfor
  return l:visited
endfunction

" }}}

" commands {{{

" helpers {{{

function s:tabopen_helper(count, args) abort
  exe a:count."tabnew"
  exe "arglocal! ".a:args
endfunction

" }}}

" multi arg wrappers {{{

command! -nargs=* -range=1 -addr=tabs -complete=file TabOpen
      \ call <SID>tabopen_helper(<count>, <SID>escape_qargs(<q-args>))

command! -nargs=* -range=1 -addr=tabs -complete=buffer TabOpenBuf
      \ call <SID>tabopen_helper(<count>, <SID>escape_qargs(<q-args>))

command! -nargs=* -range=1 -addr=tabs -complete=customlist,extras#args_complete TabOpenArg
      \ call <SID>tabopen_helper(<count>, <SID>escape_qargs(<q-args>))

command! -complete=buffer -nargs=* BDelete
      \ call extras#command_on_expanded("bdelete", extras#split_qargs(<q-args>))

command! -complete=buffer -nargs=* BWipeout
      \ call extras#command_on_expanded("bwipeout", extras#split_qargs(<q-args>))

command! -complete=file -nargs=* BAdd
      \ call extras#command_on_expanded("badd", extras#split_qargs(<q-args>))

" }}}

" different completion versions {{{

" }}}

" other {{{

command! -count=1 -nargs=1 -complete=option SetOptionCount
      \ execute "set <args>=".((!v:count)?<count>:(v:count))

" }}}

" }}}
