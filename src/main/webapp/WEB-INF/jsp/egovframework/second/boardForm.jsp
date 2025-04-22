<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>게시글 작성</title>
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- 목록 페이지 URL -->
	<c:url value="/boardList.do" var="listUrl"/>
	<!-- API URL -->
    <c:url value="/api/board/create.do" var="createApi"/>
    <c:url value="/api/board/edit.do"   var="editApi"/>
    <c:url value="/api/board/detail.do" var="detailApi"/>
	
	<script>
		var sessionUserIdx  = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
		var sessionUserName = '<c:out value="${sessionScope.loginUser.userName}" default="" />';
		
        // 동적 POST 폼 생성 함수
        function postTo(url, params) {
            var form = $('<form>').attr({ method: 'POST', action: url });
            $.each(params, function(name, value){
                $('<input>').attr({ type: 'hidden', name: name, value: value }).appendTo(form);
            });
            form.appendTo('body').submit();
        }
	</script>
</head>
<body>
	<h2 id="formTitle">게시글 작성</h2>
	<h3>현재 수정중인 게시판 idx: <span id="idxShow"></span></h3>
	<label>작성자: 
		<input type="text" id="userName" readonly />
	</label><br/>
	<label>제목: 
		<input type="text" id="title" required maxlength="100"/>
	</label><br/>
	<label>내용: 
		<textarea id="content" required maxlength="15"></textarea>
	</label><br/>
	
	<label>첨부파일:
		<input type="file" id="fileInput" multiple />
	</label><br/>
	<ul id="fileList"></ul>
	
	<button id="btnSubmit">저장</button>
	<button id="btnCancel">취소</button>
	
	<script>
	// JSP EL로 POST 폼 파라미터 idx 바로 읽기
	var idx = '${param.idx}';  
	var mode   = idx ? 'edit' : 'create';
	// 모드에 따라 apiUrl 주소 변경
	var apiUrl = mode === 'edit' ? '${editApi}' : '${createApi}';
	
    $(function(){
    	if (mode === 'edit') {
    		$('#formTitle').text('게시글 수정');
    		$('#idxShow').text(idx);
    		// 게시글 상세 정보 가져와서 input에 채워넣기
    		$.getJSON('${detailApi}', { idx: idx }, function(item) {
	   	        $('#title').val(item.title);
	   	        $('#content').val(item.content);
    		}).fail(function(){
                alert('수정할 게시글 정보 불러오기 실패');
                postTo('${listUrl}', {});
            });
    	}
    	
    	// 작성자 input에 세션의 사용자 이름 넣기
    	$('#userName').val(sessionUserName);
    	
        // 첨부파일 배열
        var filesArr = [];
        // 파일 선택 시 리스트에 추가
        $('#fileInput').on('change', function(e){
            Array.from(e.target.files).forEach(function(file){
                filesArr.push(file);
                var li = $('<li>' + file.name + '[' + file.size + 'byte]' + ' <button type="button" class="remove-file">X</button></li>');
                // 삭제 버튼 클릭 시 배열에서 제거
                li.find('.remove-file').click(function(){
                    filesArr = filesArr.filter(function(f){ return f !== file; });
                    li.remove();
                });
                $('#fileList').append(li);
            });
            $(this).val(null);
        });
    	
        $('#btnSubmit').click(function(){
        	// 폼 검증(하나라도 인풋이 비어있으면 알림)
    		var titleVal = $('#title')[0];
    		var contentVal = $('#content')[0];
    		
    		if (!titleVal.reportValidity()) return;
    		if (!contentVal.reportValidity()) return;
        	
    		// 검증 통과 시 게시글 등록 api 실행
    		var data = {userIdx: sessionUserIdx, title: $('#title').val(), content:$('#content').val()}; // 보낼 데이터
    		if (mode==='edit') data.idx = idx; // 수정 모드면 idx 추가
    		
        	// FormData 생성
        	var formData = new FormData();
        	formData.append('board', new Blob([JSON.stringify(data)], { type: 'application/json' }));
        	// 첨부파일들 추가
        	filesArr.forEach(function(file){
        		formData.append('files', file);
        	});
    		
    		$.ajax({
    			url: apiUrl + (mode==='edit' ? '?idx='+encodeURIComponent(idx) : ''),
    			type:'POST',
    			contentType:'application/json',
    			data: formData,
    			processData: false,
    			contentType: false,
    			success: function(res){
					if (res.error) {
						alert(res.error);
					} else {
						alert(mode==='edit'?'글 수정 완료':'글 등록 완료');
						postTo('${listUrl}', {});
		            }
    			},
				error: function(xhr){
					alert('게시글 ' + (mode==='edit'?'수정':'등록') + ' 중 에러 발생');
				}
    		});
        });
    	
    	$('#btnCancel').click(function() {
    		// 게시글 목록 페이지 이동
    		postTo('${listUrl}', {});
    	});
    });
	</script>
</body>
</html>