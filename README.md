# GHCi.vim
interact with GHCi

## Requirements
* [GHC](http://www.haskell.org/ghc/)
* [vimproc](https://github.com/Shougo/vimproc)

## Install
~/.vim 等の 'runtimepath' の通った場所に置く．

## Usage
'filetype' が haskell のときに以下のコマンドが定義される．

### :GhciQuit
GHCi を終了させる．変なことがなければ明示的に呼び出す必要はない．

### :GhciType [{expr}]
`{expr}` が与えられたときはその型を，そうでなければカーソル位置にあるシンボルの型を表示する．
GHCi 上での `:type {expr}` に相当．

### :GhciInfo [{symbol}]
`{symbol}` が与えられたときはその情報を，そうでなければカーソル位置にあるシンボルの情報を表示する．
GHCi 上での `:info {symbol}` に相当．

### :GhciLoad
今開いているファイルをロードする．GHCi 上での `:load` に相当．

### :GhciModule {module}
`{module}` をインポートする．GHCi 上での `:module +{module}` に相当．

### :GhciSend {str}
GHCi に `{str}` を入力する．
