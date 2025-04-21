<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>게시글 상세</title>
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- 게시글 상세 정보 가져오는 api 호출 url -->
	<c:url value="/api/board/detail.do" var="detailApi"/>
	<!-- 목록 페이지 URL -->
	<c:url value="/boardList.do" var="listUrl"/>
</head>
<body>
	<h1 id="detailTitle"></h1>
	<div id="detailMeta">
		등록자: <span id="detailUserName"></span> |
		등록일 <span id="detailCreated"></span> |
		조회수 <span id="detailHit"></span>
	</div>
	<hr/>
	<div id="detailContent" style="white-space: pre-wrap; margin: 1em 0;"></div>
	<hr/>
	
	<button id="btnBack">목록으로</button>
	<button id="btnEdit">수정</button>
	<button id="btnDelete">삭제</button>
	
	<script>
		$(function(){
			// URL 파라미터에서 idx 꺼내기
			var params = new URLSearchParams(window.location.search);
			var idx = params.get('idx');
			if (!idx) {
				alert('게시글의 idx가 없는데?');
				window.location.href = '${listUrl}';
				return;
			}
			// 상세 API 호출
			$.ajax({
				url: '${detailApi}',
				type: 'GET',
				data: { idx: idx },
				dataType: 'json',
				success: function(item) {
					console.log('받아온 데이터=', item);
					$('#detailTitle').text(item.title);
					$('#detailUserName').text(item.userName);
					$('#detailCreated').text(item.createdAt);
					$('#detailHit').text(item.hit);
					$('#detailContent').text(item.content);
				},
				error: function() {
					alert('상세조회 중 에러 발생');
					window.location.href = '${listUrl}';
				}
			});
			
			// 뒤로가기
			$('#btnBack').click(function(){
				window.location.href = '${listUrl}';
			});
		});
	</script>
</body>
</html>