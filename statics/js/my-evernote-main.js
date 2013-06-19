
var MyEvernote;
/* Table initialisation */
var converter = new Showdown.converter();

(function(MyEvernote) {
    
    var table;
    var baseURL = "http://example.com/my-evernote/";
    var selectedNote=0;

    MyEvernote.sendNewMemo = function(title,memo,author,note_id) {
	var data = "title=" + title + "&memo=" + memo + "&author=" + author + "&note_id=" + note_id; 
	$.ajax({
	    async:false,
	    type: "POST",
	    url: baseURL+ "api/addMemo?",
	    data: data,
	    success: function(msg){}
	});
    };

    MyEvernote.deleteMemo = function(memo_id) {
	var data = "memo_id=" + memo_id;
	$.ajax({
	    async:false,
	    type: "POST",
	    url: baseURL+ "api/deleteMemo?",
	    data: data,
	    success: function(msg){}
	});
    };

    MyEvernote.updateMemo = function(memo_id,title,memo,author,note_id) {
	var data = "memo_id=" + memo_id + "&title=" + title + "&memo=" + memo + "&author=" + author + "&note_id=" + note_id; 
	$.ajax({
	    async:false,
	    type: "POST",
	    url: baseURL+ "api/updateMemo?",
	    data: data,
	    success: function(msg){
	    }
	});
    };

    MyEvernote.getAllMemo = function(table) {
	var all_json;
	$.ajaxSetup({ async: true });
	var url;
	if(selectedNote == 0) {
	    url = baseURL + 'api/getMemo?callback=?';
	} else {
	    url = baseURL + 'api/getMemo?callback=?&note_id=' + selectedNote;
	}
	console.log(url);
	$.getJSON(url,function(json){
	    all_json = json;
            for(var i in json){
		var html;
		if(json[i].memo_content != null) {
			html = converter.makeHtml(json[i].memo_content);
		}
		console.log(json);
		table.fnAddData([json[i].memo_id,
				 json[i].memo_title,
				 json[i].memo_author,
				 json[i].memo_last_saved_by,
				 json[i].memo_update_date,
				 json[i].memo_create_date,
				 json[i].note_name,
				 json[i].memo_content]);;
            }
	});
	return all_json;
    };
    
    ///////////////////////////////////////////////////////
    // Note関連のAPIを呼び出す関数
    ///////////////////////////////////////////////////////
    MyEvernote.setSelectedNote = function(id) {
	selectedNote = id;
    };

    MyEvernote.getSelectedNote = function(id) {
	return selectedNote;
    };


    // 新しいNoteを作成する
    MyEvernote.sendNewNote = function(title,memo,author) {
	var data = "title=" + title;
	$.ajax({
	    async:false,
	    type: "POST",
	    url: baseURL+ "api/addNote?",
	    data: data,
	    success: function(msg){}
	});
    };

    // 指定idのノートを削除する
    MyEvernote.deleteNote = function(note_id) {
	var data = "note_id=" + selectedNote;
	$.ajax({
	    async:false,
	    type: "POST",
	    url: baseURL+ "api/deleteNote?",
	    data: data,
	    success: function(msg){}
	});
    };

    // 指定idのノートの名前を変更する
    MyEvernote.updateNote = function(title) {
	var data = "note_id=" + selectedNote + "&title=" + title;
	$.ajax({
	    async:false,
	    type: "POST",
	    url: baseURL+ "api/updateNote?",
	    data: data,
	    success: function(msg){
	    }
	});
    };

    MyEvernote.getAllNote = function() {
	var all_json;
	$("#noteList").children().remove();
	$.ajaxSetup({ async: false });
	$.getJSON(baseURL + 'api/getNote?callback=?',function(json){
	    all_json = json;
            for(var i in json){
		$("#noteList").append('<li class="noteListItem" >'+json[i].note_name+"</li>");
		$("#noteList :last-child").val(json[i].note_id);
	    }
	});
	return all_json;
    };

    MyEvernote.createMainTable = function(dstDOM) {
	var table;
	// "sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
	table = dstDOM.dataTable( {
	    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",	
	    "sPaginationType": "bootstrap",
	    "sScrollY": "200px",
            "bPaginate": false,
	    "oLanguage": {
		"sLengthMenu": "_MENU_ records per page"
	    },
	    "aoColumns": [
		{ "bVisible": false},
		null,
		null,
		null,
		null,
		null,
		null,
		{ "bVisible":    false }
	    ]
	});

	return table;
    };

    
    MyEvernote.table = table;
})(MyEvernote || (MyEvernote = {}));



$(document).ready(function() {

    var table = MyEvernote.createMainTable($('#main-table'));

    MyEvernote.getAllMemo(table);
    MyEvernote.getAllNote();

    mainTableClickHandler = function(event) {
	$(table.fnSettings().aoData).each(function (){
	    $(this.nTr).removeClass('row_selected');
	    $(this.nTr).find("td").removeClass('row_selected');
	});
	
	// event.target.parentNode is 'tr' 
	// add class row_selected to clicked 'td's 
	$(event.target.parentNode).find("td").addClass('row_selected');
	
	var data = table.fnGetData(event.target.parentNode);
	var title = data[1];
	var html = converter.makeHtml(data[7]);
	
	$("#title").text(data[1]);
	$("#content").text("");
	$("#content").append(html);
    };
    $("#main-table").click( mainTableClickHandler);
    

    $("#deleteMemoButton").click(function(event) {
	var tr = table.find(".row_selected")[0].parentNode;
	var data = table.fnGetData(tr);
	var id = data[0];

	MyEvernote.deleteMemo(id);
	table.fnClearTable();
	MyEvernote.getAllMemo(table);
	$("#deleteMemo").modal('hide');
    });


    $("#updateMemoButton").click(function(event) {
	var tr = table.find(".row_selected")[0].parentNode;
	var data = table.fnGetData(tr);
	var id = data[0];
	var title = $("#updateMemoForm [name=title-form]").val();
	var memo = $("#updateMemoForm [name=memo-form]").val();
	var note_id = $("#updateMemoForm [name=note-id-form]").val();
	var author="hoge";
	MyEvernote.updateMemo(id,title,memo,author,note_id);
	table.fnClearTable();
	MyEvernote.getAllMemo(table);
	$("#updateMemo").modal('hide');
    });


    $("#showAllMemo").click(function(hoge) { 
	$("#noteList").children().removeClass("note_selected");
	MyEvernote.setSelectedNote(0);
	table.fnClearTable();
	MyEvernote.getAllMemo(table);
    });
	      
    $("#newMemo").on("shown",function(){
	$(".selectDstNote").children().remove();
	$.ajaxSetup({ async: true });
	all_note = MyEvernote.getAllNote();
        for(var i in all_note){
	    $(".selectDstNote").append('<option value="'+all_note[i].note_id + '">'+ all_note[i].note_name + '</option>');
	}
    });

    $("#updateMemo").on("shown",function(){
	var tr = table.find(".row_selected")[0].parentNode;
	var data = table.fnGetData(tr);
	var id = data[0];
	var title = data[1];
	var content = data[7];
	var note_name = data[6];
	var note_value = 0;
	$(".selectDstNote").children().remove();
	$.ajaxSetup({ async: true });
	all_note = MyEvernote.getAllNote();
        for(var i in all_note){
	    if(all_note[i].note_name == note_name) {
		note_value = all_note[i].note_id;
	    }
	    $(".selectDstNote").append('<option value="'+all_note[i].note_id + '">'+ all_note[i].note_name + '</option>');
	}
	$(".selectDstNote").val(note_value);
	$("#updateMemoForm [name=title-form]").val(title);
	$("#updateMemoForm [name=memo-form]").val(content);
	$("#updateMemoForm [name=note-id-form]").val();
    });


    $("#newMemoButton").click(function(event) {    
	var title = $("#newMemoForm [name=title-form]").val();
	var memo = $("#newMemoForm [name=memo-form]").val();
	var note_id = $("#newMemoForm [name=note-id-form]").val();
	MyEvernote.sendNewMemo(title,memo,"sakura",note_id);
	table.fnClearTable();
	MyEvernote.getAllMemo(table);
	$("#newMemo").modal('hide');
    });


    //
    // Noteを操作するUIのハンドラ
    // 
    $("#newNoteButton").click(function(){
	var title = $("#newNoteForm [name=title-form]").val();
	MyEvernote.sendNewNote(title);
	MyEvernote.getAllNote();
	$("#newNote").modal('hide');
    });
    
    $("#updateNote").on("shown",function(){
	var all_note = MyEvernote.getAllNote();
        for(var i in all_note){
	    if(all_note[i].note_id == MyEvernote.getSelectedNote()) {
		$("#updateNoteForm [name=title-form]").val(all_note[i].note_name);
	    }
	}
    });

    $("#updateNoteButton").click(function(event) {
	var title = $("#updateNoteForm [name=title-form]").val();
	MyEvernote.updateNote(title);
	MyEvernote.getAllNote();
	$("#updateNote").modal('hide');
    });

    $("#deleteNoteButton").click(function() {
	MyEvernote.deleteNote();
	MyEvernote.getAllNote();
	$("#deleteNote").modal('hide');
    });

    
    function notify(hoge) { 
	$("#noteList").children().removeClass("note_selected");
	$(hoge.target).addClass("note_selected");
	MyEvernote.setSelectedNote($(hoge.target).val());
	table.fnClearTable();
	MyEvernote.getAllMemo(table);
    };
    $("#noteList").on("click" ,".noteListItem", notify);

    $(window).resize( function () {
	table.fnAdjustColumnSizing();
    } );    
});
