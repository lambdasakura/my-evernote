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
(annot:enable-annot-syntax)

(import '(clack:wrap
	  clack.middleware.auth.basic:<clack-middleware-auth-basic>
          clack.middleware.static:<clack-middleware-static>))
(import '(clack:call clack:<component>))


(defclass <my-evernote-app> (<component>) 
  ((template-dir :accessor template-dir :initarg :template-dir)
   (static-dir :accessor static-dir :initarg :static-dir)
   (base-url :accessor base-url :initarg :base-url)
   (db-name :accessor db-name :initarg :db-name)))

(defmethod call ((this <my-evernote-app>) env)
  (app-main this env))

(defmethod app-main ((this <my-evernote-app>) env) 
  (let ((chugoku (make-instance 'Chugoku))
	(sakuya (make-instance 'Sakuya
			       :template-dir (template-dir this)
			       :base-url (base-url this)))
	(patchouli (make-instance 'memo-manager:<Patchouli> :db-name (db-name this))))
    (setf (db-admin sakuya) patchouli)
    (setf (server chugoku) sakuya)
    (memo-manager:connect-db patchouli)
    (prog1 
	(entrance-check chugoku env)
      (memo-manager:disconnect-db patchouli))))

(defparameter session-manager
  (make-instance 'clack.middleware.session:<clack-middleware-session>
		 :state  (make-instance  'clack.session.state.cookie:<clack-session-state-cookie>)))

(defun generate-auth-manager ()
  (make-instance '<clack-middleware-auth-basic>  
		 :authenticator  
		 #'(lambda (user pass)  
		     (or (and (string= user "user1") (string= pass "password"))
			 (and (string= user "user2") (string= pass "password"))))))
    
(defun generate-static-mw (static-dir)
  (make-instance 'clack.middleware.static:<clack-middleware-static>
		 :path "/my-evernote/public/"
		 :root static-dir))

(let ((server nil))
  @export
  (defun server-start (&key basic-auth base-url static-dir template-dir (port 5000) db-name)
    (kmrcl:set-signal-handler :INT 
                          (lambda (&rest args)
                            (declare (ignore args))
                            (format t "~&* Exiting...~%")
			    (sb-ext:quit)))
    (let ((my-evernote-server (make-instance '<my-evernote-app>
					     :template-dir template-dir
					     :base-url base-url
					     :db-name db-name))
	  (static-mw (generate-static-mw static-dir))
	  (auth-manager (if basic-auth
			    (generate-auth-manager)
			    nil)))
      (setf server 
	    (if auth-manager
		(clack:clackup (wrap session-manager
				     (wrap auth-manager
					   (wrap static-mw my-evernote-server)))
			       :port port)
		(clack:clackup (wrap session-manager
				     (wrap static-mw my-evernote-server))
			       :port port)))))
  @export
  (defun server-stop ()
    (clack:stop server)
    (setf server nil)))


@export
(defun start()
  (server-start :basic-auth nil
		:base-url "/my-evernote" 
		:static-dir "./statics/"
		:template-dir "./template/"
		:port 5000
		:db-name "./my_evernote_memo.db"))

@export
(defun stop()
  (server-stop)) 
