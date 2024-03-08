# themis-helper-scripter

- .themisrc

```vim
call themis#helper('deps').git('mityu/vim-themis-helper-scripter')
```

- tests

```vim
let g:assert = themis#helper('assert')
let g:scripter = themis#helper('scripter')

call g:scripter.new()
  \.call({-> g:assert.equals(mode(), 'n')})
  \.feedkeys('ifoobar')
  \.call({-> g:assert.equals(mode(), 'i')})
  \.call({-> g:assert.equals(getline('.'), 'foobar')})
  \.feedkeys("\<ESC>")
  \.call({-> g:assert.equals(mode(), 'n')})
  \.run()

inoremap <Plug>(test-mapping) (rhs-test-mapping)
call g:scripter.new()
  \.feedkeys('i')
  \.feedkeys_remap("\<Plug>(test-mapping)")
  \.call({-> g:assert.equals(getline('.'), '(rhs-test-mapping)')})
  \.set_auto_replace_termcodes(1)
  \.feedkeys_remap('<Plug>(test-mapping)')
  \.call({-> g:assert.equals(getline('.'), '(rhs-test-mapping)(rhs-test-mapping)')})
  \.feedkeys('<ESC>')
  \.run()
```
