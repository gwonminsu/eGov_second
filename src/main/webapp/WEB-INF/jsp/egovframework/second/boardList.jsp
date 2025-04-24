<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%> 
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>게시글 목록 페이지</title>
	<style>
		.count-red {
			color: red;
			font-weight: bold;
			font-size: 1.2em;
		}
		
		#gallery {
			display: flex;
			flex-wrap: wrap;
			gap: 1em;
			justify-content: center;
			margin: 1em 0;
		}
		.gallery-item {
			flex: 0 0 calc(25% - 1em);
			box-sizing: border-box;
			text-align: center;
			display: flex;
			flex-direction: column;
			align-items: center;
		}
		.gallery-item img {
			width: 200px;
			height: 200px;
			display: block;
			border-radius: 4px;
		}
		.gallery-item .info {
			margin-top: .5em;
			font-size: .9em;
			color: #555;
		}
		.gallery-item .info .title {
			font-weight: bold;
			margin-bottom: .3em;
			display: block;
		}
	</style>
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
	    const FIRST_IMG_URL = '${firstImgUrl}';
	    const PREV_IMG_URL  = '${prevImgUrl}';
	    const NEXT_IMG_URL  = '${nextImgUrl}';
	    const LAST_IMG_URL  = '${lastImgUrl}';
	    
	    // 검색 변수(파라미터에서 값 받아와서 검색 상태 유지)
		var currentSearchType = '<c:out value="${param.searchType}" default="title"/>';
		var currentSearchKeyword = '<c:out value="${param.searchKeyword}" default=""/>';
		var currentPageIndex = parseInt('<c:out value="${param.pageIndex}" default="1"/>');
		
		// AJAX 로 페이징/리스트를 불러오는 함수
		function loadBoardList(pageIndex) {
			currentPageIndex = pageIndex;
			$('#searchType').val(currentSearchType);
			$('#searchKeyword').val(currentSearchKeyword);
		    const sType = $('#searchType').val();
		    const sKeyword = $('#searchKeyword').val().trim();
			
			var req = {
				pageIndex: currentPageIndex,
				recordCountPerPage: PAGE_UNIT,
				searchType: sType,
				searchKeyword: sKeyword
			};
			
		    $.ajax({
		        url: '${boardListUrl}',
		        method: 'POST',
		        contentType: 'application/json',
		        data: JSON.stringify(req),
		        dataType: 'json',
		        success: function(res) {
		            var data = res.list;
		            var totalCount = res.totalCount;
		            console.log('받아온 데이터=', data, '총건수=', totalCount);
		            
					// 검색 요약 표시
					if (sType && sKeyword) {
						var label = currentSearchType === 'userName' ? '작성자' : '제목';
						$('#searchInfo').text("[" + sKeyword + "]로 검색된 결과(" + label + ")");
					} else {
						$('#searchInfo').text('');
					}
		            $('.count-red').text(totalCount); // 게시물 수 표시
		            
					var uploadBase = '<c:url value="/uploads/"/>';
					var $gallery = $('#gallery').empty();
		            
					data.forEach(function(item){
						var ts = new Date().getTime(); // 캐시 버스트
						// 게시물의 썸네일 url 가져오기
					    var thumb = (item.photoFiles && item.photoFiles.length) ? uploadBase + item.photoFiles[0].fileUuid + item.photoFiles[0].ext + '?t=' + ts : '<c:url value="/uploads/images/no-img.jpg"/>';
					    
						var $card = $('<div>').addClass('gallery-item');
						$('<img>').attr('src', thumb).appendTo($card);
						var $info = $('<div>').addClass('info').appendTo($card);
						$('<span>').addClass('title').text(item.title).appendTo($info);
						$('<span>').text(item.createdAt + ' | 👁 ' + item.hit).appendTo($info);
						
						// 클릭 시 상세 페이지로 이동
						$card.css('cursor','pointer').click(function(){
							postTo('${boardDetailUrl}', { idx: item.idx, searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
						});
						
						$gallery.append($card);
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
			
			// 현재 묶음 인덱스, 시작/끝 페이지 계산
			var groupIndex = Math.floor((currentPage - 1) / PAGE_SIZE);
			var startPage  = groupIndex * PAGE_SIZE + 1;
			var endPage = Math.min(startPage + PAGE_SIZE - 1, totalPages);

			
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
	
	<!-- 검색 영역 -->
	<div id="searchArea" style="margin-bottom:1em;">
		<label for="searchType">검색조건:</label>
		<select id="searchType">
			<option value="userName">작성자</option>
			<option value="title">제목</option>
		</select>
		<label for="searchKeyword">검색어:</label>
		<input type="text" id="searchKeyword" />
		<button type="button" id="btnSearch">검색</button>
	</div>

	<div id="searchInfo"></div>
	<p>전체: <span class="count-red"></span>건</p>
    
    <div id="gallery"></div>
    
    <button type="button" id="btnGoBoardForm">글쓰기</button>
    
    <div id="paginationArea"></div>
    
    <script>
	    $(function() {
	    	loadBoardList(currentPageIndex);
	    	
			// 검색 영역 초기값 반영
			$('#searchType').val(currentSearchType);
			$('#searchKeyword').val(currentSearchKeyword);
			
			// 검색 버튼
			$('#btnSearch').click(function(){
				currentPageIndex = 1;
				currentSearchType = $('#searchType').val();
				currentSearchKeyword = $('#searchKeyword').val().trim();
				loadBoardList(1);
			});
	        
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
	    			postTo('${boardFormUrl}', { searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
	    		} else {
	    			// 없으면 로그인 페이지로
	    			alert('글 작성하려면 로그인 하셔야 합니다');
	    			window.location.href = '${loginUrl}';
	    		}
	    	});

	    });
    </script>
</body>
</html>