(ql:quickload :my-evernote-server)
(ql:quickload :swank)



(defun main ()
  (my-evernote-server:server-start
   :base-url "/my-evernote" 
   :static-dir "./statics/"
   :template-dir "./template/"
   :port 5000
   :db-name "./my_evernote_memo.db")
  (swank:create-server :port (or (parse-integer (string (sb-ext:posix-getenv "SWANK_PORT"))
						:junk-allowed t)
				 4005)
		       :style :spawn 
		       :dont-close t)
  (loop (sleep 60)))

(sb-ext:save-lisp-and-die "my-evernote-server"
			  :executable t 
			  :toplevel (quote main))'
