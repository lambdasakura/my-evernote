#|
  This file is a part of my-evernote-server project.
  Copyright (c) 2013 lambda_sakura
|#

(in-package :cl-user)
(defpackage my-evernote-server
  (:use :cl 
	:cl-emb
	:dbi
	:cl-json
	:clack
	:cl-annot
	:clack.request
	:clack.middleware.static
	:clack.middleware.auth.basic
	:memo-manager
	:anaphora
	:cl-ppcre
	:flexi-streams))

(in-package :my-evernote-server)

(import '(clack:wrap
	  clack.middleware.auth.basic:<clack-middleware-auth-basic>
          clack.middleware.static:<clack-middleware-static>))
(annot:enable-annot-syntax)


;;
;; さくやさん
;;
;; 入ってきた人に応じた内容で饗す。
;;
@export
(defclass Sakuya ()
  ((template-dir :accessor template-dir :initform nil :initarg :template-dir)
   (base-url :accessor base-url :initform nil :initarg :base-url)
   (db-admin :initform nil :initarg :db-admin :accessor db-admin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; favicon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun favicon-p (path-info)
  (string= path-info "/favicon.ico"))

(defun get-favicon ()
  '(200
    (:content-type "image/x-icon")
    #p"./static/favicon.ico"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; getMemo API
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmethod get-memos-api ((this Sakuya) env)
  (let* ((callback (getf env :|callback|))
	 (json (json:encode-json-to-string  (memo-manager:get-memo-all (db-admin this) :note-id (getf env :|note_id|))))
	 (res-string (format nil "~A(~A)" callback json)))
    `(200
      (:content-type "text/javascript")
      (,res-string))))

(defmethod get-notes-api ((this Sakuya) env)
  (let* ((callback (getf env :|callback|))
	 (json (json:encode-json-to-string  (memo-manager:get-note-all (db-admin this))))
	 (res-string (format nil "~A(~A)" callback json)))
    `(200
      (:content-type "text/javascript")
      (,res-string))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; addMemo API
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmethod update-note-api ((this Sakuya) env)
  (memo-manager:update-note
   (db-admin this)
   (getf env :|note_id|)
   :name (getf env :|title|))
  `(200 (:content-type "text/plain") ("OK")))


(defmethod update-memo-api ((this Sakuya) env)
  (memo-manager:update-memo 
   (db-admin this)
   (getf env :|memo_id|)
   :note-id (getf env :|note_id|)
   :author (getf env :|username|)
   :title (getf env :|title|)
   :text  (getf env :|memo|))
  `(200 (:content-type "text/plain") ("OK")))


(defmethod add-note-api ((this Sakuya) env)
  (memo-manager:add-new-note 
   (db-admin this)
   :name (getf env :|title|))
  `(200 (:content-type "text/plain") ("OK")))

(defmethod add-memo-api ((this Sakuya) env)
  (memo-manager:add-new-memo 
   (db-admin this)
   :note-id (getf env :|note_id|)
   :author (getf env :|username|)
   :title (getf env :|title|)
   :text  (getf env :|memo|))
  `(200 (:content-type "text/plain") ("OK")))
    
(defmethod delete-memo-api ((this Sakuya) env)
  (memo-manager:delete-memo 
   (db-admin this)
   (getf env :|memo_id|))
  `(200 (:content-type "text/plain") ("OK")))

(defmethod delete-note-api ((this Sakuya) env)
  (memo-manager:delete-note
   (db-admin this)
   (getf env :|note_id|))
  `(200 (:content-type "text/plain") ("OK")))

(defmethod compare-path ((this Sakuya) env target)
  (string= (getf env :path-info) (format nil "~@{~A~}"
					 (base-url this) target)))

(defmethod render-template ((this Sakuya) path env)
  (list 
   200
   '(:content-type "text/html")
   (list (emb:execute-emb (merge-pathnames (template-dir this) path) :env env))))

(defmethod service ((this Sakuya) query)
  (let ((path (getf query :path-info))
	(query-info (getf query :query-info)))
    (prog1 
	(cond
	  ((favicon-p path) (get-favicon))
	  ((or (compare-path this query "/index.html")
	       (compare-path this query "/"))
	   (render-template this "/index.tmpl" (list :user (getf query :username))))
	  ((compare-path this query "/api/addMemo") (add-memo-api this query-info))
	  ((compare-path this query "/api/addNote") (add-note-api this query-info))
	  ((compare-path this query "/api/deleteMemo") (delete-memo-api this  query-info))
	  ((compare-path this query "/api/deleteNote") (delete-note-api this  query-info))
	  ((compare-path this query "/api/getMemo") (get-memos-api this query-info))
	  ((compare-path this query "/api/getNote") (get-notes-api this query-info))
	  ((compare-path this query "/api/updateMemo") (update-memo-api this query-info))
	  ((compare-path this query "/api/updateNote") (update-note-api this query-info))
  	(t '(404 (:content-type "text/plain") ("Not found"))))
      nil)))
