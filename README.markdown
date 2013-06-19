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

`start-server.lisp`の以下の設定を変更してください。

```lisp
;; start-server.lisp:7行目付近

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

次に、javascriptも修正が必要です、`statics/js/my-evernote-main.js`にURLの設定を追加します。

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

## ユーザ認証に関して

### Digest認証

これが標準で想定している使い方です。
Apacheやnginxと言ったサーバで事前に認証を行なって、その後にリバースプロクシでmy-evernoteに転送してください。

### BASIC認証

my-evernote-server自体にBASIC認証機能がとってつけたようなものがあります。
が *おすすめしない* です。どうしても使いたい場合は、

- start-server.lisp
- src/my-evernote-server.lisp

の2ファイルに以下のような修正を行なってください。

`start-server.lisp`の修正

```lisp
;;; start-server.lisp:7行目付近
  (my-evernote-server:server-start
   :base-url "/my-evernote" 
   :static-dir "./statics/"
   :template-dir "./template/"
   :port 5000
   ;; 以下の1行を追加
   :basic-auth t
   :db-name "./my_evernote_memo.db")
```

`src/my-evernote-server.lisp`の修正

```lisp
(defun generate-auth-manager ()
  (make-instance '<clack-middleware-auth-basic>  
         :authenticator  
         #'(lambda (user pass)  
             (or 
             (and (string= user "user1") (string= pass "password"))
             (and (string= user "user2") (string= pass "password"))))))
```
の中身を適宜修正してください。


## Author

* lambda_sakura

## Copyright

Copyright (c) 2013 lambda_sakura

# License

Licensed under the MIT License.

