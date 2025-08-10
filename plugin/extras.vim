if has("nvim")
  " Because extras.lua is for nvim
  return
endif
if exists("g:loaded_vim_extras")
  return
endif
let g:loaded_vim_extras = 1

" vimscript specific utilities {{{

" }}}

" general utilities {{{

" TODO

" }}}

" commands {{{

" TODO

" }}}

function B(n = 1) abort
  return repeat("../", n-1).".."
endfunction
