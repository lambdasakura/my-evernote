(in-package :my-evernote-server)
(import '(clack:wrap
	  clack.middleware.auth.basic:<clack-middleware-auth-basic>
          clack.middleware.static:<clack-middleware-static>))
(annot:enable-annot-syntax)

(defun add-test-data ()
  ;;(init-db)
  (memo-manager:connect-db *db-manager*)
  (memo-manager:add-new-memo *db-manager* :author "sakura" :note-id "1" :title  "メモテスト" 
:text 
"
#見出し

- リスト
- リスト

## 見出し2

-------------------------------

- リスト
- リスト

-------------------------------

1. 番号付きリスト
2. 番号付きリスト

ここから文書。

こんな感じにメモが書けます


I get 10 times more traffic from [Google] [1] than from
[Yahoo] [2] or [MSN] [3].

  [1]: http://google.com/        \"Google\"
  [2]: http://search.yahoo.com/  \"Yahoo Search\"
  [3]: http://search.msn.com/    \"MSN Search\"


")

;; (add-memo
;;  "料理のなにか"
;;  "
;; # 鍋会

;; * 場所: 自宅
;; * 時間: 13:00


;; ## 買出し(ピェンロー鍋)

;; [ピェンロー鍋参考](http://localhost)

;; * 豚バラ肉
;; * 白菜
;; * 鶏肉
;; * 春雨
;; * 昆布
;; * しいたけ
;; * その他
;;   - 割り箸
;;   - 皿
;;   - 紙コップ


;; ## 手順

;; 1. 鍋に昆布としいたけで出しをとる
;; 2. 白菜を切る
;;   * 葉は大きめに切る
;;   * 芯の方は細かく切る
;; 3. 作る
;; 4. 食べる
;; ")

;; (add-memo "test3" "#日本語はどうなの？")
;; (add-memo "test4" "#日本語はどうなの？")
;; (add-memo "test5" "#日本語はどうなの？")
;; (add-memo "test6" "#日本語はどうなの？")
;; (add-memo "test7" "#日本語はどうなの？")
;; (add-memo "メモテスト" 
;; "
;; #見出し

;; - リスト
;; - リスト

;; ## 見出し2

;; -------------------------------

;; - リスト
;; - リスト

;; -------------------------------

;; 1. 番号付きリスト
;; 2. 番号付きリスト

;; ここから文書。

;; こんな感じにメモが書けます


;; I get 10 times more traffic from [Google] [1] than from
;; [Yahoo] [2] or [MSN] [3].

;;   [1]: http://google.com/        \"Google\"
;;   [2]: http://search.yahoo.com/  \"Yahoo Search\"
;;   [3]: http://search.msn.com/    \"MSN Search\"


;; ")
  (memo-manager:disconnect-db *db-manager*)
)
