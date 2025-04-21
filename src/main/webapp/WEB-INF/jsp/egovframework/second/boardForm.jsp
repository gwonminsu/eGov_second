<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>게시글 작성</title>
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	<!-- 게시글 등록 API URL -->
	<c:url value="/api/board/create.do" var="createUrl"/>
	<!-- 목록 페이지 URL -->
	<c:url value="/boardList.do" var="listUrl"/>
	
	<script>
		var sessionUserIdx  = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
		var sessionUserName = '<c:out value="${sessionScope.loginUser.userName}" default="" />';
	</script>
</head>
<body>
	<h2>게시글 작성</h2>
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
	<button id="btnSubmit">저장</button>
	<button id="btnCancel">취소</button>
	
	<script>
	var params = new URLSearchParams(window.location.search); // 파라미터 가져오기
	var idx    = params.get('idx');
	var mode   = idx ? 'edit' : 'create';
	var apiUrl = mode === 'edit' ? '<c:url value="/api/board/edit.do"/>' : '<c:url value="/api/board/create.do"/>';
	
    $(function(){
    	if (mode === 'edit') {
    		$('h2').text('게시글 수정');
    		$('#idxShow').text(idx);
    		// 게시글 상세 정보 가져와서 input에 채워넣기
    		$.getJSON('<c:url value="/api/board/detail.do"/>', { idx: idx }, function(item) {
	   	        $('#title').val(item.title);
	   	        $('#content').val(item.content);
    		});
    	}
    	// 작성자 input에 세션의 사용자 이름 넣기
    	$('#userName').val(sessionUserName);
    	
        $('#btnSubmit').click(function(){
        	// 폼 검증(하나라도 인풋이 비어있으면 알림)
    		var titleVal = $('#title')[0];
    		var contentVal = $('#content')[0];
    		
    		if (!titleVal.reportValidity()) return;
    		if (!contentVal.reportValidity()) return;
        	
    		// 검증 통과 시 게시글 등록 api 실행
    		var data1={userIdx: sessionUserIdx, title: $('#title').val(), content:$('#content').val()}; // 등록 모드 시 데이터
    		var data2={idx: idx, userIdx: sessionUserIdx, title: $('#title').val(), content:$('#content').val()}; // 수정 모드 시 데이터
    		$.ajax({
    			url: apiUrl + '?idx=' + encodeURIComponent(idx),
    			type:'POST',
    			contentType:'application/json',
    			data: mode==='edit' ? JSON.stringify(data2) : JSON.stringify(data1),
    			success: function(res){
					if (res.error) {
						alert(res.error);
					} else {
						alert(mode==='edit'?'글 수정 완료':'글 등록 완료');
						window.location.href = '${listUrl}';
		            }
    			},
				error: function(xhr){
					alert('게시글 ' + (mode==='edit'?'수정':'등록') + ' 중 에러 발생');
				}
    		});
        });
    	
    	$('#btnCancel').click(function() {
    		// 게시글 목록 페이지 이동
    		window.location.href = '${listUrl}';
    	});
    });
	</script>
</body>
</html>