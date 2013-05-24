create table note_kind(note_id integer primary key,
                       note_name text);

create table memo(
       	     memo_id integer primary key autoincrement,
       	     memo_author text, 
	     memo_last_saved_by text, 
	     memo_create_date text,
	     memo_update_date text,
	     note_id integer,
	     memo_title text,
	     memo_content text);
