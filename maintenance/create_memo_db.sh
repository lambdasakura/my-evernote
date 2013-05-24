#!/bin/sh
SCRIPT_DIR=`dirname $0`
option=$1
# sqlite3 my_evernote_memo.db < create_memo_db.sql

checkError( ) {
    if [ $? -gt 0 ]; then
	echo "Failed"
	exit 1
    else
	echo "OK!"
    fi

}

case $option in
    create_test_db)
	if [ -f $TEST_DB ]; then
	    echo -n "remove old db..."
	    rm $TEST_DB
	    checkError
	fi
	echo -n "generate test db..."
	sqlite3 $TEST_DB < $SCRIPT_DIR"/create_memo_db.sql"
	checkError
 
	;;
    create_db)
	echo "---------------- generate db ---------------------------"
	if [ -f $DB ]; then
	    filetype=`file $DB`
	    if expr "$filetype"  : "SQLite" > /dev/null; then
		echo "file is Exist"
		sqlite3 $TEST_DB < $SCRIPT_DIR"/create_memo_db.sql"
		checkError
	    else
		echo "file is Exist and Not SQLite Database"
		return 2;
	    fi
	else
	    sqlite3 $DB < $SCRIPT_DIR"/create_memo_db.sql"
	fi
	;;
    backup_db)
	echo "---------------- backup db -----------------------------"
	cp $DB $DB_`date`
	;;
esac    
	
