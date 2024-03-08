let s:latest_id = -1
let s:objects = {}
let s:scripter = {
  \ '_object_id': -1,
  \ '_script': [],
  \ '_fn_stack': [],
  \ '_auto_replace_termcodes': 0,
  \}

function s:get_sid() abort
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeget_sid')
endfunction

function s:get_new_id() abort
  let s:latest_id += 1
  return s:latest_id
endfunction

function s:internal_error_message(msg) abort
  return 'themis: report: internal error: ' . a:msg
endfunction

function s:replace_termcodes(from) abort
  return substitute(a:from, '<[^<>]\+>',
   \ '\=eval(printf(''"\%s"'', submatch(0)))', 'g')
endfunction

function s:call_top_of_fn_stack(object_id) abort
  if !has_key(s:objects, a:object_id)
    throw s:internal_error_message('cannot find scripter object by object-id:' . a:object_id)
  endif
  let obj = s:objects[a:object_id]
  if empty(obj._fn_stack)
    throw s:internal_error_message('function stack is empty.')
  endif

  call call(remove(obj._fn_stack, 0), [])
endfunction

function s:scripter.call(Fn) abort
  call add(self._fn_stack, a:Fn)
  let script =
    \ printf("\<Cmd>call %scall_top_of_fn_stack(%s)\<CR>", s:get_sid(), self._object_id)
  call add(self._script, [script, 0])
  return self
endfunction

function s:scripter.feedkeys(keys) abort
  let keys = a:keys
  if self._auto_replace_termcodes
    let keys = s:replace_termcodes(keys)
  endif
  call add(self._script, [keys, 0])
  return self
endfunction

function s:scripter.feedkeys_remap(keys) abort
  let keys = a:keys
  if self._auto_replace_termcodes
    let keys = s:replace_termcodes(keys)
  endif
  call add(self._script, [keys, 1])
  return self
endfunction

function s:scripter.run() abort
  for [keys, remap] in self._script
    if remap
      call feedkeys(keys, 'm!')
    else
      call feedkeys(keys, 'n!')
    endif
  endfor
  call feedkeys('', 'x')

  if !has_key(s:objects, self._object_id)
    throw s:internal_error_message('cannot find self by object-id: ' . self._object_id)
  endif
  call remove(s:objects, self._object_id)
  if !empty(self._fn_stack)
    throw s:internal_error_message(
      \ '_fn_stack still have entries: ' . string(self._fn_stack))
  endif
  return self
endfunction

function s:scripter.set_auto_replace_termcodes(value) abort
  let self._auto_replace_termcodes = a:value
  return self
endfunction

function s:new_scripter() abort
  let obj = deepcopy(s:scripter)
  let obj._object_id = s:get_new_id()
  let s:objects[obj._object_id] = obj
  return obj
endfunction

function themis#helper#scripter#new(_) abort
  return {'new': function('s:new_scripter')}
endfunction
