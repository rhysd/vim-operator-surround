Operator to Surround a Text Object [![Build Status](https://travis-ci.org/rhysd/vim-operator-surround.png?branch=master)](https://travis-ci.org/rhysd/vim-operator-surround)
==================================

This plugin provides operator mappings to surround a text object with `()`, `""` and so on.

- `<Plug>(operator-surround-append)`

![Screen shot](http://gifzo.net/BV5L18BxT86.gif)

- `<Plug>(operator-surround-delete)`

No screen shot.

- `<Plug>(operator-surround-replace)`

Not implemented yet.


## Policy of this plugin (or The reason why I don't use [vim-surround](https://github.com/tpope/vim-surround))

- **Simplicity** : All should be done with operator mappings.
- **Extensibility** : The behavior should be highly customizable with `g:operator#surround#blocks` and text objects like [vim-textobj-multiblock](https://github.com/osyo-manga/vim-textobj-multiblock) or [vim-textobj-anyblock](https://github.com/rhysd/vim-textobj-anyblock).
- **Well-tested**


## Requirements

This plugin uses [vim-operator-user](https://github.com/kana/vim-operator-user). Please install it in advance.

## Customize

Set your favorite blocks to `g:operator#surround#blocks`.

(More explanation about this is todo)


## Example of vimrc

```vim
map sy <Plug>(operator-surround-append)
map sd <Plug>(operator-surround-delete)
map sc <Plug>(operator-surround-replace)
```

## License

vim-operator-surround is distributed under MIT license.

  Copyright (c) 2013 rhysd

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:
  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
