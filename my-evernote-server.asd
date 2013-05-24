#|
  This file is a part of my-evernote-server project.
  Copyright (c) 2013 lambda_sakura
|#

#|
  自宅用evernoteサーバ

  Author: lambda_sakura
|#

(in-package :cl-user)
(defpackage my-evernote-server-asd
  (:use :cl :asdf))
(in-package :my-evernote-server-asd)

(defsystem my-evernote-server
  :version "0.1"
  :author "lambda_sakura"
  :license "MIT"
  :depends-on (:clack
	       :clack-middleware-auth-basic
	       :cl-emb
	       :cl-json
	       :flexi-streams
	       :alexandria
	       :anaphora
	       :kmrcl
	       :sqlite
	       :dbi)
  :components ((:module "src"
                :components
                ((:file "util")
		 (:file "memo-manager")
		 (:file "server")
		 (:file "gateway")
		 (:file "my-evernote-server"))
		:serial t
))

  :description "自宅用evernoteサーバ"
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (load-op my-evernote-server-test))))
