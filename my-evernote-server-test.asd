#|
  This file is a part of my-evernote-server project.
  Copyright (c) 2013 lambda_sakura
|#

(in-package :cl-user)
(defpackage my-evernote-server-test-asd
  (:use :cl :asdf))
(in-package :my-evernote-server-test-asd)

(defsystem my-evernote-server-test
  :author "lambda_sakura"
  :license "MIT"
  :depends-on (:drakma
	       :my-evernote-server
               :cl-test-more)
  :components ((:module "t"
                :components
                ((:file "my-evernote-server-test")
		 (:file "chugoku-test")
		 (:file "memo-manager-test"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
