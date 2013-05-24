#|
  This file is a part of my-evernote-server project.
  Copyright (c) 2013 lambda_sakura
|#

(in-package :cl-user)
(defpackage my-evernote-server-test
  (:use :cl
        :my-evernote-server
	:drakma
        :cl-test-more))
(in-package :my-evernote-server-test)

(plan nil)

(diag "中国の動作確認")
(setf good-query1 '(:path-info "/my-evernote/api/getMemo"))
(setf good-query2 '(:path-info  "/favicon.ico"))

(setf bad-query '(:path-info  "/api/getMemo"))
(setf bad-query2 '(:path-info  "/api/getMemo/my-evernote/"))


(setf chugoku (make-instance 'my-evernote-server:chugoku))

(ok chugoku "生成はできる")

(diag "URIチェックのテスト")

(is (my-evernote-server:acceptable-query-p chugoku good-query1) t "/my-evernote始まりのURIは入門許可")
(is (my-evernote-server:acceptable-query-p chugoku good-query2) t "/favicon.icoも入門許可を出す")

(is (my-evernote-server:acceptable-query-p chugoku bad-query2) nil "my-evernoteで始まっていないとダメ")
(is (my-evernote-server:acceptable-query-p chugoku bad-query) nil "途中にmy-evernoteが入っていてもダメ")


(diag "Queryチェックのテスト")

(setf good-query '(:path-info  "/my-evernote/api/getMemo" :moge  "hogehogeghoe"))
(setf bad-query '(:path-info "/my-evernote/api/getMemo" :fuga  "mogemogemoge"))
(is (my-evernote-server:strip-unuse-parameter chugoku good-query) '(:path-info "/my-evernote/api/getMemo") "不要なものは没収する")
(is (my-evernote-server:strip-unuse-parameter chugoku bad-query) '(:path-info "/my-evernote/api/getMemo") "不要なものは没収する")

(setf add-query
      (list 
       :request-method :post
       :remote-user "sakura"
       :path-info "/my-evernote/api/addMemo"
       :raw-body-buffer (flexi-streams:string-to-octets "title=タイトル&memo" :external-format :utf-8)
       :raw-body  (kmrcl:usb8-array-to-string (flexi-streams:string-to-octets "日本語文字列どうですかー？&author" :external-format :utf-8))))


(is (my-evernote-server:strip-unuse-parameter chugoku add-query) '(:path-info "/my-evernote/api/addMemo" :query-info "title=") "不要なものは没収する")

