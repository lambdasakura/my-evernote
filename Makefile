# DB path
TEST_DB="./my_evernote_memo_test.db"
DB="./my_evernote_memo.db"

build: clean my-evernote-server 
build-release: clean my-evernote-server make_release_db
build-test: clean my-evernote-server make_test_db

my-evernote-server:
	sbcl --load "./start-server.lisp"
clean:
	if [ -f my-evernote-server ]; then (rm my-evernote-server); fi

make_release_db:
	DB=$(DB) sh ./maintenance/create_memo_db.sh create_db

make_test_db:
	TEST_DB=$(TEST_DB) sh ./maintenance/create_memo_db.sh create_test_db

