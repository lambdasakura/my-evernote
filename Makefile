# DBの位置
TEST_DB="./my_evernote_memo_test.db"
DB="./my_evernote_memo.db"

build: clean my-application 

build-release: clean my-application db-generate

my-application:
	sbcl --load "./start-server.lisp"
clean:
	if [ -f my-evernote-server ]; then (rm my-evernote-server); fi

make_db:
	DB=$(DB) sh ./maintenance/create_memo_db.sh create_db

test_db:
	TEST_DB=$(TEST_DB) sh ./maintenance/create_memo_db.sh create_test_db

