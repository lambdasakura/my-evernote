(in-package :cl-user)

(defpackage util
  (:use :cl :local-time))

(in-package :util)
(annot:enable-annot-syntax)

(defparameter +sqlite3-format+
  ;; 2008-11-18T02:32:00.586931+01:00
  '((:year 4) #\- (:month 2) #\- (:day 2) #\Space
    (:hour 2) #\: (:min 2) #\: (:sec 2)))

@export
(defun current-time-for-sqlite3 ()
  ;; generate current-date.
  ;; format YYYY-MM-DD HH:MM:SS
  (local-time:format-timestring nil (local-time:now) :format +sqlite3-format+))

