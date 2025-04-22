<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%> 
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
	
	<!-- 페이지네이션 버튼 이미지 url -->
	<c:url value="/images/egovframework/cmmn/btn_page_pre10.gif" var="firstImgUrl"/>
	<c:url value="/images/egovframework/cmmn/btn_page_pre1.gif"  var="prevImgUrl"/>
	<c:url value="/images/egovframework/cmmn/btn_page_next1.gif" var="nextImgUrl"/>
	<c:url value="/images/egovframework/cmmn/btn_page_next10.gif" var="lastImgUrl"/>

	
	<!-- 세션에 담긴 사용자 이름을 JS 변수로 -->
	<script>
		// 서버에서 렌더링 시점에 loginUser.userName 이 없으면 빈 문자열로
		var loginUserName = '<c:out value="${sessionScope.loginUser.userName}" default="" />';
	
	    const PAGE_SIZE = ${pageSize}; // 한 그룹당 페이지 버튼 개수
	    const PAGE_UNIT = ${pageUnit}; // 한 페이지당 레코드 수
	    console.log("pageSize: " + PAGE_SIZE + ", pageUnit: " + PAGE_UNIT);
	    const FIRST_IMG_URL = '${firstImgUrl}';
	    const PREV_IMG_URL  = '${prevImgUrl}';
	    const NEXT_IMG_URL  = '${nextImgUrl}';
	    const LAST_IMG_URL  = '${lastImgUrl}';
		
		// AJAX 로 페이징/리스트를 불러오는 함수
		function loadBoardList(pageIndex) {
		    $.ajax({
		        url: '${boardListUrl}',
		        method: 'POST',
		        contentType: 'application/json',
		        data: JSON.stringify({
		            pageIndex: pageIndex,
		            recordCountPerPage: PAGE_UNIT
		        }),
		        dataType: 'json',
		        success: function(res) {
		            var data = res.list;
		            var totalCount = res.totalCount;
		            console.log('받아온 데이터=', data, '총건수=', totalCount);
		            
		            var $tbody = $('#boardListTbl tbody');
		            $tbody.empty();
		            $.each(data, function(i, item) {
		                var titleLink = '<a href="javascript:void(0);" class="link-view" data-idx="' + item.idx + '">' + item.title + '</a>';
		                var row = '<tr>' +
		                          '<td>' + item.idx + '</td>' +
		                          '<td>' + item.userIdx + '</td>' +
		                          '<td>' + item.userName + '</td>' +
		                          '<td>' + titleLink + '</td>' +
		                          '<td>' + item.hit + '</td>' +
		                          '<td>' + item.createdAt + '</td>' +
		                          '<td>' + item.updatedAt + '</td>' +
		                          '</tr>';
		                $tbody.append(row);
		            });
		            renderPagination(totalCount, pageIndex);
		        },
		        error: function(xhr, status, error) {
		            console.error('AJAX 에러:', error);
		        }
		    });
		}
		
		// 페이지네이션 UI
		function renderPagination(totalCount, currentPage) {
			var $pg = $('#paginationArea').empty();
			var totalPages = Math.ceil(totalCount / PAGE_UNIT);
			console.log("totalPages: " + totalPages);
			
			// 현재 묶음 인덱스, 시작/끝 페이지 계산
			var groupIndex = Math.floor((currentPage - 1) / PAGE_SIZE);
			console.log("groupIndex: " + groupIndex);
			var startPage  = groupIndex * PAGE_SIZE + 1;
			console.log("startPage: " + startPage);
			var endPage = Math.min(startPage + PAGE_SIZE - 1, totalPages);
			console.log("endPage: " + endPage);
			
			// '처음으로' 버튼
			if (currentPage > 1) {
				$pg.append('<a href="#" onclick="loadBoardList(1);return false;">' + '<img src="' + FIRST_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + FIRST_IMG_URL + '" border="0" style="opacity:0.3;cursor:default;pointer-events:none;"/></a>&#160;');
			}
			
			// '이전 10페이지' 버튼
			if (startPage > 1) {
			    $pg.append('<a href="#" onclick="loadBoardList(' + (startPage - 1) + ');return false;">' + '<img src="' + PREV_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + PREV_IMG_URL + '" border="0" style="opacity:0.3;cursor:default;pointer-events:none;"/></a>&#160;');
			}
			
			// 개별 페이지 번호 링크
			for (var i = startPage; i <= endPage; i++) {
			    if (i === currentPage) {
			        $pg.append('<strong>' + i + '</strong>&#160;'); // 선택된 페이지만 굵게
			    } else {
			        $pg.append(
			          '<a href="#" onclick="loadBoardList(' + i + ');return false;">' +
			           i +
			          '</a>&#160;'
			        );
			    }
			}
			
			// '다음 10페이지' 버튼
			if (endPage < totalPages) {
			    $pg.append('<a href="#" onclick="loadBoardList(' + (endPage + 1) + ');return false;">' + '<img src="' + NEXT_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + NEXT_IMG_URL + '" border="0" style="opacity:0.3;cursor:default;pointer-events:none;"/></a>&#160;');
			}
			
			// '마지막으로' 버튼
			if (currentPage < totalPages) {
			    $pg.append('<a href="#" onclick="loadBoardList(' + totalPages + ');return false;">' + '<img src="' + LAST_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + LAST_IMG_URL + '" border="0" style="opacity:0.3;cursor:default;pointer-events:none;"/></a>&#160;');
			}
		}
		
		// 게시글 상세 GET아닌 POST로 진입하기
		function postTo(url, params) {
		    // 폼 요소 생성
		    var form = $('<form>').attr({ method: 'POST', action: url });
		    // hidden input으로 파라미터 삽입
		    $.each(params, function(name, value) {
		        $('<input>').attr({ type: 'hidden', name: name, value: value }).appendTo(form);
		    });
		    // body에 붙이고 제출
		    form.appendTo('body').submit();
		}
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
    
    <div id="paginationArea"></div>
    
    <script>
	    $(function() {
	    	loadBoardList(1);
	        
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
	    	
	    	// 글쓰기 버튼 핸들러
	    	$('#btnGoBoardForm').click(function() {
	    		if (loginUserName) {
	    			// 세션에 사용자가 있으면 게시글 작성 폼으로
	    			postTo('${boardFormUrl}', {});
	    		} else {
	    			// 없으면 로그인 페이지로
	    			alert('글 작성하려면 로그인 하셔야 합니다');
	    			window.location.href = '${loginUrl}';
	    		}
	    	});
	    	
	        // 재목 클릭 -> 상세 페이지로 POST
	        $('#boardListTbl').on('click', '.link-view', function(){
	            var idx = $(this).data('idx');
	            postTo('${boardDetailUrl}', { idx: idx });
	        });
	    });
    </script>
</body>
</html>