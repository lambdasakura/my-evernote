# My-Evernote-Server - 自宅用evernoteサーバ

## Install & Usage 

簡単に使い方を説明します。

### チェックアウト(git clone)

my-evernoteを適当な場所にチェックアウトし、asdfで読めるように設定してください。
quicklisp使っている人でしたら、

```
cd quicklisp/local-projects/my-evernote
git clone git@github.com:lambdasakura/my-evernote
```

とかでチェックアウトすれば良いです。

### 設定を記述

start-server.lispのなかの以下の設定を変更してください。

```lisp
;; 設置する際のURL。http://example.com/my-evernoteで公開するならこの設定
;; トップで公開する場合は、""とかを指定。
:base-url "/my-evernote"    
;; サーバを動作させるポート
;; 出来れば80番では動作させないでください。
;; 外部に晒されても大丈夫な作りにはしてありません。
:port 5000
;; データベースファイルのある位置
;; デフォルトのままでOKです。
:db-name "./my_evernote_memo.db"
```

次に、javascriptも修正が必要です、
```
statics/js/my-evernote-main.js
```
を開いて、

```js
var baseURL = "http://example.com/my-evernote/";
```

を環境に合わせて変更してください。

### サーバ起動

```
# DBを作成する
make make_release_db
# サーバのバイナリを作成する
make
# サーバの動作開始
./my-evernote-server
```

以上です。

## Author

* lambda_sakura

## Copyright

Copyright (c) 2013 lambda_sakura

# License

Licensed under the MIT License.

