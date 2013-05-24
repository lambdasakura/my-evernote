#|
  This file is a part of my-evernote-server project.
  Copyright (c) 2013 lambda_sakura
|#

(in-package :cl-user)
(defpackage memo-manager
  (:use :cl 
	:dbi
	:cl-annot
	:cl-annot.class
	:util))
(in-package :memo-manager)
(cl-annot:enable-annot-syntax)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 名前:パチュリー・ノーレッジ
;; 
;; 能力:DBとの通信を管理する
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@export-accessors
@export
(defclass <Patchouli> ()
  ((db :accessor db :initform nil )
   (db-name :accessor db-name :initform nil :initarg :db-name)))

@export
(defmethod connect-db ((this <Patchouli>))
  "DBとの通信を開始する"
  (setf (db this)
	(dbi:connect :sqlite3
		     :busy-timeout 1000
		     :database-name (db-name this))))
@export
(defmethod disconnect-db ((this <Patchouli>))
  "DBとの通信を終了する"
  (dbi:disconnect (db this)))

(defmethod execute-sql ((this <Patchouli>) sql &rest arg)
  "DBとの通信を行なってSQLを実行する"
  (with-transaction (db this)
    (let* ((query (dbi:prepare (db this) sql)))
      (unwind-protect 
	   (dbi:fetch-all (apply #'dbi:execute (append (list query) arg)))
	(sqlite:finalize-statement (dbi.driver:query-prepared query))))))

@export
(defmethod add-new-memo ((this <Patchouli>) &key author title text note-id)
  "メモを追加して、追加したメモのIDを返す"
    (let ((result))
    (execute-sql this "INSERT INTO memo (memo_author, memo_last_saved_by, memo_create_date, memo_update_date, note_id, memo_title, memo_content) VALUES(?,?,?,?,?,?,?);"
		 author author
		 (util:current-time-for-sqlite3)
		 (util:current-time-for-sqlite3) note-id title text)
    (setf result (execute-sql this "select * from memo order by memo_id desc limit 1;"))
    (getf (first result) :|memo_id|)))

@export
(defmethod get-memo ((this <Patchouli>) id)
  "指定されたIDのメモを取得する"
  (first (execute-sql this "SELECT * FROM memo WHERE memo_id = ?;" id)))

@export
(defmethod get-memo-all ((this <Patchouli>) &key (note-id 0))
  "すべてのメモを取得する"
  (let ((list '()))
    (loop for row in 
	 (if (or (null note-id) (equal note-id 0))
	     (execute-sql this "SELECT * FROM memo LEFT JOIN note_kind ON memo.note_id = note_kind.note_id;")
	     (execute-sql this "SELECT * FROM memo LEFT JOIN note_kind ON memo.note_id = note_kind.note_id WHERE memo.note_id = ?;" note-id)) do
	 (push (alexandria:plist-hash-table row) list))
    (print list)
    list))

@export
(defmethod memo-exist-p ((this <Patchouli>) id)
  "指定されたIDのメモが存在するかを返す"
  (not (null (execute-sql this "SELECT * FROM memo WHERE memo_id = ?;" id))))

@export
(defmethod delete-memo ((this <Patchouli>) id)
  "指定されたIDのメモを削除する"
  (when (memo-exist-p this id)
    (execute-sql this "DELETE FROM memo WHERE memo_id=?;" id)))

@export
(defmethod update-memo ((this <Patchouli>) id  &key author title text note-id)
  "指定されたIDのメモを引数の内容で更新する"
  (when (memo-exist-p this id)
    (execute-sql this "UPDATE memo SET memo_last_saved_by=?, memo_update_date=?, note_id=?, memo_title=?,  memo_content=? WHERE memo_id=?;"
		 author (current-time-for-sqlite3) note-id title text id)))
  
(defmethod exist-note-name-p ((this <Patchouli>) name)
  "指定された名前のノートが存在するか"
  (execute-sql this "SELECT * FROM note_kind WHERE note_name=?;" name))

@export
(defmethod add-new-note ((this <Patchouli>) &key name)
  "新しいノートを追加する"
  (unless (exist-note-name-p this name)
    (execute-sql this "INSERT INTO note_kind (note_name) VALUES(?);" name)
    (getf (first (execute-sql this "SELECT * FROM note_kind ORDER BY note_id DESC LIMIT 1;")) :|note_id|)))

@export
(defmethod get-note ((this <Patchouli>) id)
  "指定されたIDのノートを取得する"
  (first (execute-sql this "SELECT * FROM note_kind WHERE note_id = ?;" id)))

@export
(defmethod get-note-all ((this <Patchouli>))
  "全てのノートを取得する"
  (let ((list '()))
    (loop for row in (execute-sql this "SELECT * FROM note_kind;") do
	 (push (alexandria:plist-hash-table row) list))
    (print list)
    list))

@export
(defmethod note-exist-p ((this <Patchouli>) id)
  "指定されたIDのノートが存在するか"
  (execute-sql this "SELECT * FROM note_kind WHERE note_id = ?;" id))

@export
(defmethod update-note ((this <Patchouli>) id  &key name)
  "指定されたIDのノートの名前を変更する"
  (when (note-exist-p this id)
    (execute-sql this "UPDATE note_kind SET note_name=? WHERE note_id=?;" name id)))

@export
(defmethod delete-note ((this <Patchouli>) id)
  "指定したIDのノートを削除する"
  (execute-sql this "DELETE FROM note_kind WHERE note_id=?;" id))

@export
(defmethod get-memo-in-note ((this <Patchouli>) note-id)
  "指定したノートに含まれるメモを全て取得する"
  (execute-sql this "SELECT * FROM memo WHERE note_id=?;" note-id))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 初期化用関数(使わない)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmethod table-exist-p ((this <Patchouli>) table-name)
  (let ((result))
    (setf result (dbi:execute  (dbi:prepare (db this) "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=?;") table-name))
    (= 1 (getf (first (dbi:fetch-all result)) :|COUNT(*)|))))

(defmethod drop-table ((this <Patchouli>))
  (when (table-exist-p this "memo")
    (dbi:do-sql (db this) "DROP TABLE  memo;"))
  (when (table-exist-p this "note_kind")
    (dbi:do-sql (db this) "DROP TABLE  note_kind;")))

  
@export
(defmethod init-table ((this <Patchouli>))
  (with-transaction (db this)
    (drop-table this)
    (dbi:do-sql (db this) "create table if not exists note_kind(note_id integer primary key, note_name text UNIQUE);")
    (dbi:do-sql (db this) "create table if not exists memo(
       	     memo_id integer primary key autoincrement,
       	     memo_author text, 
	     memo_last_saved_by text, 
	     memo_create_date text,
	     memo_update_date text,
	     note_id integer,
	     memo_title text,
	     memo_content text);")
    (dbi:do-sql (db this) "DELETE FROM memo;")
    (dbi:do-sql (db this) "DELETE FROM note_kind;")))

