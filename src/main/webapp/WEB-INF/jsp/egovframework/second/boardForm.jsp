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
    $(function(){
    	// 작성자 input에 세션의 사용자 이름 넣기
    	$('#userName').val(sessionUserName);
    	
        $('#btnSubmit').click(function(){
        	// 폼 검증(하나라도 인풋이 비어있으면 알림)
    		var titleVal = $('#title')[0];
    		var contentVal = $('#content')[0];
    		
    		if (!titleVal.reportValidity()) return;
    		if (!contentVal.reportValidity()) return;
        	
    		// 검증 통과 시 게시글 등록 api 실행
    		var data={userIdx: sessionUserIdx, title: $('#title').val(), content:$('#content').val()};
    		$.ajax({
    			url:'${createUrl}',
    			type:'POST',
    			contentType:'application/json',
    			data:JSON.stringify(data),
    			success:function(res){
					if (res.error) {
						alert(res.error);
					} else {
						alert('글 등록 완료');
						window.location.href = '${listUrl}';
		            }
    			},
				error: function(xhr){
					alert('글 등록 중 에러 발생');
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