Operator to Surround a Text Object [![Build Status](https://travis-ci.org/rhysd/vim-operator-surround.png?branch=master)](https://travis-ci.org/rhysd/vim-operator-surround)
==================================

This plugin provides operator mappings to surround a text object with `()`, `""` and so on.

- `<Plug>(operator-surround-append)`

![Screen shot](http://gifzo.net/BV5L18BxT86.gif)

- `<Plug>(operator-surround-replace)`

Not implemented yet.

- `<Plug>(operator-surround-delete)`

Not implemented yet.


### Why don't you use vim-surround?

[vim-surround]() is very useful and used by many vimmers.  However, I think its behavior is too complex for me.  Mappings which vim-surround provides are not arranged and hard to customize.
I think all process should be done by operator mappings and surrounds should be highly customizable with each motionwise objects.


### Policy of This Plugin

- **Simplicity** : All should be done with operator mappings.
- **Extensibility** : The behavior should be highly customizable with `g:operator#surround#blocks` and text objects like [vim-textobj-multiblock](https://github.com/osyo-manga/vim-textobj-multiblock) or [vim-textobj-anyblock](https://github.com/rhysd/vim-textobj-anyblock).

### Customize

Set your favorite blocks to `g:operator#surround#blocks`.

(More explanation about this is todo)


### License

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
