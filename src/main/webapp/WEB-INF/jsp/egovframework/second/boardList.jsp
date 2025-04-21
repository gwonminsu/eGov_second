<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>테스트 페이지</title>
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- 게시글 목록 json 가져오는 api 호출 url -->
	<c:url value="/api/board/list.do" var="boardListUrl"/>
	<!-- 로그아웃 api 호출 url -->
	<c:url value="/api/user/logout.do" var="logoutUrl" />
	<!-- 로그인 페이지 url -->
	<c:url value="/login.do" var="loginUrl"/>
	<!-- 게시글 작성 페이지 url -->
	<c:url value="/boardForm.do" var="boardFormUrl"/>
	<!-- 게시글 상세 페이지 url -->
	<c:url value="/boardDetail.do" var="boardDetailUrl"/>

	
	<!-- 세션에 담긴 사용자 이름을 JS 변수로 -->
	<script>
		// 서버에서 렌더링 시점에 loginUser.userName 이 없으면 빈 문자열로
		var loginUserName = '<c:out value="${sessionScope.loginUser.userName}" default="" />';
	</script>
</head>
<body>
    <h2>사진 게시판(임시)</h2>
    
	<!-- 사용자 로그인 상태 영역 -->
	<div id="userInfo">
		<span id="loginMsg"></span>
		<button type="button" id="btnGoLogin">로그인하러가기</button>
		<button type="button" id="btnLogout">로그아웃</button>
	</div>
	
    <table id="boardListTbl" border="1">
    	<thead>
	        <tr>
	            <th>Idx</th>
	            <th>작성자 idx</th>
	            <th>작성자 이름</th>
	            <th>제목</th>
	            <th>조회수</th>
	            <th>등록일</th>
	            <th>수정일</th>
	        </tr>
    	</thead>
    	<tbody></tbody>
    </table>
    
    <button type="button" id="btnGoBoardForm">글쓰기</button>
    
    <script>
    	// 페이지 렌더링 시 사용자 리스트 가져오기
	    $(document).ready(function() {
	    	console.log('AJAX 호출 URL=', '${boardListUrl}');
	        $.ajax({
	            url: '${boardListUrl}',
	            type: 'POST',
	            dataType: 'json',
	            success: function(data) {
	            	console.log('받아온 데이터=', data);
	                var $tbody = $('#boardListTbl').find('tbody');
	                $tbody.empty();
	                $.each(data, function(i, item) {
	                	var detailLink = '${boardDetailUrl}?idx=' + encodeURIComponent(item.idx);
	                    var row = '<tr>' +
	                              '<td>' + item.idx + '</td>' +
	                              '<td>' + item.userIdx + '</td>' +
	                              '<td>' + item.userName + '</td>' +
	                              '<td><a href="' + detailLink + '">' + item.title + '</a></td>' +
	                              '<td>' + item.hit + '</td>' +
	                              '<td>' + item.createdAt + '</td>' +
	                              '<td>' + item.updatedAt + '</td>' +
	                              '</tr>';
	                    $tbody.append(row);  
	                });
	            },
	            error: function(xhr, status, error) {
	                console.error('AJAX 에러:', error);
	            }
	        });
	    });
	    
	    $(function(){
	        // 로그인 여부에 따라 버튼 토글
	        if (loginUserName) {
				$('#loginMsg').text('현재 로그인 중인 사용자: ' + loginUserName);
				$('#btnGoLogin').hide();
				$('#btnLogout').show();
	        } else {
				$('#welcomeMsg').text('');
				$('#btnGoLogin').show();
				$('#btnLogout').hide();
	        }
	    	
	    	// 로그인 버튼 핸들러
	    	$('#btnGoLogin').click(function() {
	    		// 로그인 페이지 이동
	    		window.location.href = '${loginUrl}';
	    	});
	    	
	    	// 글쓰기 버튼 핸들러
	    	$('#btnGoBoardForm').click(function() {
	    		if (loginUserName) {
	    			// 세션에 사용자가 있으면 게시글 작성 폼으로
	    			window.location.href = '${boardFormUrl}';
	    		} else {
	    			// 없으면 로그인 페이지로
	    			alert('글 작성하려면 로그인 하셔야 합니다');
	    			window.location.href = '${loginUrl}';
	    		}
	    		
	    	});
	    	
	        // 로그아웃
	        $('#btnLogout').click(function(){
				$.ajax({
					url: '${logoutUrl}',
					type: 'POST',
					success: function(){
						location.reload();
					},
					error: function(){
						alert('로그아웃 중 오류 발생');
					}
				});
	        });
	    });
    </script>
</body>
</html>