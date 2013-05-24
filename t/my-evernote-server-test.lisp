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

(diag "Server Test Start")
(unwind-protect 
     (progn (my-evernote-server:server-start :port 5050 :db-name "./test.db")

	    (is (drakma:http-request "http://localhost:5050/my-evernote/api/addMemo"
					    :method :post
					    :parameters 
					    '(("author" . "sakura")
					      ("title"  . "test")
					      ("text" . "mogemogemoge"))) "OK")
	    (isnt (drakma:http-request "http://localhost:5050/my-evernote/api/getMemo?callback=hogehoge") "hogehoge(null)")
	    (is  (drakma:http-request "http://localhost:5050/my-evernote/api/deleteMemo"
				      :method :post
				      :parameters '(("memo_id". "1"))) "OK")
	    (is (drakma:http-request "http://localhost:5050/my-evernote/api/getMemo?callback=hogehoge")
		"hogehoge(null)")
	    
	    (is (drakma:http-request "http://localhost:5050/my-evernote/api/addMemo"
					    :method :post
					    :parameters 
					    '(("author" . "sakura")
					      ("title"  . "test")
					      ("text" . "mogemogemoge"))) "OK")
	    (is (drakma:http-request "http://localhost:5050/my-evernote/api/addMemo"
				     :method :post
				     :parameters 
				     '(("author" . "sakura")
				       ("title"  . "test")
				       ("text" . "mogemogemoge"))) "OK")
	    (isnt (drakma:http-request "http://localhost:5050/my-evernote/api/getMemo?callback=hogehoge") "hogehoge(null)")
	    (is  (drakma:http-request "http://localhost:5050/my-evernote/api/deleteMemo"
				      :method :post
				      :parameters '(("memo_id". "2"))) "OK")
	    (is  (drakma:http-request "http://localhost:5050/my-evernote/api/deleteMemo"
				      :method :post
				      :parameters '(("memo_id". "3"))) "OK")
	    (is (drakma:http-request "http://localhost:5050/my-evernote/api/getMemo?callback=hogehoge") "hogehoge(null)")
	    ;; (print (drakma:http-request "http://localhost:5050/my-evernote/api/addMemo"
	    ;; 			    :method :post 
	    ;; 			     :parameters '(("memo_id" . "1"))))
	    ;; (print (drakma:http-request "http://localhost:5050/my-evernote/api/addMemo"
	    ;; 			    :method :post 
	    ;; 			     :parameters '(("memo_id" . "2"))))
	    ;; (print (drakma:http-request "http://localhost:5050/my-evernote/api/addMemo"
	    ;; 			    :method :post 
	    ;; 			     :parameters '(("memo_id" . "3"))))
	    ;; (print (drakma:http-request "http://localhost:5050/my-evernote/api/getMemo?callback=hogehoge"))
	    )
  (my-evernote-server:server-stop))
(finalize)
