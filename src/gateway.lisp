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

#|

中国

- 入ろうとしたものに資格があるかどうかを確認する
- 資格がある者には、必要最低限のものだけ持たせてガイドさんに後のことは依頼する

|#

@export
(defclass Chugoku ()
  ((acceptable-url :initform '("/my-evernote" "/favicon.iso") :initarg :url)
   (server :initform (make-instance 'Sakuya) :accessor server :initarg :server)))

(defmethod get-auth-username ((this Chugoku) env)
  (cond ((getf env :REMOTE-USER)
	 (getf env :REMOTE-USER))
	((getf env :HTTP-AUTHORIZATION)
	 (multiple-value-bind (username group) (ppcre:scan-to-strings 
						"username=\"([^\"]+)\""
						(getf env :HTTP-AUTHORIZATION))
	   (declare (ignore username))
	   (elt group 0)))
	(t (gethash :username (getf env :clack.session)))))


@export
(defmethod acceptable-query-p ((this Chugoku) query)
  "queryが入門可能なものかを判断する"
  (not (equal nil (ppcre:scan  "(^/my-evernote)|(^/favicon.ico)" (getf query :path-info)))))

(defmethod get-data-from-post-data ((this Chugoku) query)
  (let ((stream (getf query :RAW-BODY))
	(temp ""))
    (setf temp (concatenate 'string 
			    temp 
			    (flexi-streams:octets-to-string (getf query :RAW-BODY-BUFFER)
							    :external-format :utf-8)))
    (do ((line (read-line stream nil)
    	       (read-line stream nil)))
    	((null line))
      (setf temp (concatenate 'string
    			      temp 
    			      (flexi-streams:octets-to-string 
    			       (kmrcl:string-to-usb8-array line) 
    			       :external-format :utf-8)
    			      (list #\newline))))
    temp))

@export
(defmethod get-query-data ((this Chugoku) query)
  (if (equal (getf query :request-method) :post)
      (get-data-from-post-data this query)
      (getf query :query-string)))

(defun parameters->plist (params &key (delimiter "&"))
  "Convert parameters into plist. The `params' must be a string."
  (loop for kv in (ppcre:split delimiter params)
        for (k v) = (ppcre:split "=" kv)
        append (list (alexandria:make-keyword k)
                     ;; KLUDGE: calls `ignore-errors'.
                     (or (ignore-errors (clack.util.hunchentoot:url-decode v)) v))))

@export
(defmethod strip-unuse-parameter ((this Chugoku) query)
  "必要な情報だけのリストを作成する"
  (let ((path-info (getf query :path-info))
	(username (get-auth-username this query))
	(query-info (parameters->plist (get-query-data this query)))
	(lst '()))
    (setf lst (append lst (list :path-info path-info)))
    (setf lst (append lst (list :username username)))
    (when query-info
      (setf query-info (append query-info (list :|username| username)))
      (setf lst (append lst (list :query-info query-info))))
    lst))
    

(defmethod accept-query ((this Chugoku) query)
  "入門を許可した者をガイドさんに引き渡す"
  (service (server this) (strip-unuse-parameter this query)))


(defmethod entrance-check ((this Chugoku) query)
  (if (acceptable-query-p this query)
      (accept-query this query)
      '(404 (:content-type "text/plain") ("Not found"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; parameter utils
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun parse-parameter (env)
  "Parse GET method parameter. return plist."
  (clack.request:parameter (clack.request:make-request env)))
  
