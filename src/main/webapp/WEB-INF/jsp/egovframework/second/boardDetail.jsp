<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>게시글 상세</title>
	<style>
	   #photoPreview img {
			max-width: 50%;
			margin: 5px;
			display: inline-block;
			vertical-align: middle;
	   }
	   
	   #detailContent {
			white-space: pre-wrap;
			margin: 1em 0;
	   }
	</style>
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- 게시글 상세 정보 가져오는 api 호출 url -->
	<c:url value="/api/board/detail.do" var="detailApi"/>
	<!-- 게시글 삭제 api 호출 url -->
	<c:url value="/api/board/delete.do" var="deleteApi"/>
	<!-- 목록 페이지 URL -->
	<c:url value="/boardList.do" var="listUrl"/>
	<!-- 게시글 작성 페이지 url(수정) -->
	<c:url value="/boardForm.do" var="boardFormUrl"/>
	
	<script>
		var sessionUserIdx  = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
		
        // 동적 POST 폼 생성 함수
        function postTo(url, params) {
            var form = $('<form>').attr({
                method: 'POST',
                action: url
            });
            $.each(params, function(name, value){
                $('<input>').attr({
                    type: 'hidden',
                    name: name,
                    value: value
                }).appendTo(form);
            });
            form.appendTo('body').submit();
        }
	</script>
</head>
<body>
	<h1 id="detailTitle"></h1>
	<div id="detailMeta">
		등록자: <span id="detailUserName"></span> |
		등록일 <span id="detailCreated"></span> |
		조회수 <span id="detailHit"></span>
	</div>
	<hr/>
	<div id="photoPreview"></div>
	<div id="detailContent"></div>
	<hr/>
	
	<button id="btnBack">목록으로</button>
	<button id="btnEdit">수정</button>
	<button id="btnDelete">삭제</button>
	
	<script>
		$(function(){
			// JSP EL로 POST form에서 넘어온 idx
			var idx = '${param.idx}';
			if (!idx) {
				alert('게시글의 idx가 없는데?');
				postTo('${listUrl}', {}); // POST로 목록 복귀
				return;
			}
			// 조회된 게시글 정보
			var current = {};
			
			// 업로드된 파일을 서빙하는 기본 URL
	        var uploadBase = '<c:url value="/uploads/"/>';
			
			// 상세 API 호출
			$.ajax({
				url: '${detailApi}',
				type: 'GET',
				data: { idx: idx },
				dataType: 'json',
				success: function(item) {
					current = item;
					console.log('받아온 데이터=', item);
					$('#detailTitle').text(item.title);
					$('#detailUserName').text(item.userName);
					$('#detailCreated').text(item.createdAt);
					$('#detailHit').text(item.hit);
					
					// 첨부파일 이미지 렌더링
	                var $preview = $('#photoPreview').empty();
	                (item.photoFiles || []).forEach(function(f){
						// fileUuid + ext 로 실제 경로 생성
						var src = uploadBase + f.fileUuid + f.ext;
						$('<img>').attr('src', src).appendTo($preview);
	                });
	                
					$('#detailContent').text(item.content);
				},
				error: function() {
					alert('상세조회 중 에러 발생');
					postTo('${listUrl}', {});
				}
			});
			
			// 뒤로가기
			$('#btnBack').click(function(){
				postTo('${listUrl}', {});
			});
			
			// 수정버튼
			$('#btnEdit').click(function(){
				var me = sessionUserIdx;
				if (me !== current.userIdx) {
					alert('수정 권한이 없습니다');
					return;
				}
				// 수정모드로 boardForm 페이지 띄우기 (idx 파라미터 전달)
				postTo('${boardFormUrl}', { idx: idx });
			});
			
			// 삭제버튼
			$('#btnDelete').click(function(){
				var me = sessionUserIdx;
 				if (me !== current.userIdx) {
					alert('삭제 권한이 없습니다');
					return;
				}
				if (!confirm('정말 삭제하시겠습니까?')) return;
				$.ajax({
					url: '${deleteApi}?idx=' + encodeURIComponent(idx),
					type: 'POST',
					contentType: 'application/json',
					data: JSON.stringify({ idx: idx }),
					success: function(res){
						if (res.error) {
							alert(res.error);
						} else {
							alert('게시글 삭제가 완료되었습니다.');
							window.location.href = '${listUrl}';
						}
					},
					error: function(){
					alert('삭제 중 오류 발생');
					}
				});
			});
		});
	</script>
</body>
</html>