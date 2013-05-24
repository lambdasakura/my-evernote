#|
  This file is a part of my-evernote-server project.
  Copyright (c) 2013 lambda_sakura
|#

(in-package :cl-user)
(defpackage memo-manager-test
  (:use :cl
	:dbi
        :memo-manager
        :cl-test-more))
(in-package :memo-manager-test)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; メンテナンス用の関数
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(plan nil)

(setf manager (make-instance 'memo-manager:<Patchouli> :db-name "./test.db"))

(diag "Connect & Initialize DB")
(ok (connect-db manager) "Connect DB")
(isnt (db manager) nil "DB is not nil")

;; テスト準備
(memo-manager:init-table manager)

(diag "Manipulate Memos")
(setf id_1 (memo-manager:add-new-memo manager :title "test" :text "mogemoge" :author "sakura"))
(setf id_2 (memo-manager:add-new-memo manager :title "test" :text "mogemoge" :author "sakura"))
(isnt id_1 nil "Add Memos")
(isnt id_2 nil "Add Memos")
(isnt (memo-manager:get-memo manager id_1) nil "Get Memos")
(isnt (memo-manager:get-memo manager id_1) nil "Get Memos")

(memo-manager:update-memo manager id_1 :title "ばか" :text "mogemoge" :author "あほ")
(is (getf (memo-manager:get-memo manager id_1) :|memo_title|) "ばか" "Update Memos")

(is (memo-manager:delete-memo manager id_1) nil  "Delete Memo")
(is (memo-manager:delete-memo manager id_2) nil  "Delete Memo")
(is (memo-manager:get-memo manager id_1) nil "confirm deleted")
(is (memo-manager:get-memo manager id_2) nil "confirm deleted")

(diag "Manipulate Notes")
(setf id_1 (memo-manager:add-new-note manager :name "test" ))
(setf id_2 (memo-manager:add-new-note manager :name "test2"))
(isnt id_1 nil "Add Notes")
(isnt id_2 nil "Add Notes")
(isnt (memo-manager:get-note manager id_1) nil "Get Notes")
(isnt (memo-manager:get-note manager id_1) nil "Get Notes")
(memo-manager:update-note manager id_1 :name "ばか")
(is (getf (memo-manager:get-note manager id_1) :|note_name|)
    "ばか" "Update Notes")
(is (memo-manager:delete-note manager id_1) nil  "Delete Note")
(is (memo-manager:delete-note manager id_2) nil  "Delete Note")
(is (memo-manager:get-note manager id_1) nil "confirm deleted")
(is (memo-manager:get-note manager id_2) nil "confirm deleted")

(diag "Note & Memo Relation")

(loop for i from 1 to 100
     do (memo-manager:add-new-memo manager
				:title "test"
				:note-id (floor i 10)
				:text "test_mogemoge"
				:author "sakura"))

(is (length (memo-manager:get-memo-all manager)) 100)

(loop for i from 1 to 10
     do (memo-manager:add-new-note manager
				:name "test"))

(is (length (memo-manager:get-note-all manager)) 1)

(is (length (memo-manager:get-memo-in-note manager 1)) 10)

(memo-manager:init-table manager)
(ok (disconnect-db manager) "Disconnect DB")

(finalize)

