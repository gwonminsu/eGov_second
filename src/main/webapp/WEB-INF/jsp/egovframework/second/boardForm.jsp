<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>게시글 작성</title>
	<style>
		#content {
			width: 100%;
			height: 300px;
			border: 1px solid #ccc;
			padding: 5px;
			overflow-y: auto; /* 세로 스크롤 활성화 */
			overflow-x: hidden;
		}
		#content img {
			max-width: 30%;
			height: auto;
			display: block;
			margin: 5px 0;
		}
		
		#dropZone {
			width:100%;
			padding:1em;
			border:2px dashed #ccc;
			text-align:center; color:#888;
			margin-bottom:1em;
		}
		#dropZone.dragover {
			border-color: #66afe9;
			background: #f0f8ff;
			color: #333;
		}

	</style>
	
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
		
	    // 검색 변수(파라미터에서 값 받아와서 검색 상태 유지)
		var currentSearchType = '<c:out value="${param.searchType}" default="title"/>';
		var currentSearchKeyword = '<c:out value="${param.searchKeyword}" default=""/>';
		var currentPageIndex = parseInt('<c:out value="${param.pageIndex}" default="1"/>');
		
        // 동적 POST 폼 생성 함수
        function postTo(url, params) {
            var form = $('<form>').attr({ method: 'POST', action: url });
            $.each(params, function(name, value){
                $('<input>').attr({ type: 'hidden', name: name, value: value }).appendTo(form);
            });
            form.appendTo('body').submit();
        }
        
		// 바이트 수를 읽기 편한 문자열로 변환
		function formatBytes(bytes) {
			if (bytes === 0) return '0 Bytes';
			const k = 1024;
			const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
			// 지수 계산
			const i = Math.floor(Math.log(bytes) / Math.log(k));
			// 해당 단위로 나눈 값
			const value = bytes / Math.pow(k, i);
			return value.toFixed(2) + ' ' + sizes[i];
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
		<div id="content" contenteditable="true" ></div>
	</label><br/>
	
	<label>첨부파일:
		<input type="file" id="fileInput" multiple accept="image/*" />
	</label><br/>
	<div id="dropZone">여기에 파일을 드래그 앤 드롭 해 주세요</div>
	<ul id="fileList"></ul>
	
	<button id="btnSubmit">저장</button>
	<button id="btnCancel">취소</button>
	
	<script>
	// JSP EL로 POST 폼 파라미터 idx 바로 읽기
	var idx = '${param.idx}';  
	var mode   = idx ? 'edit' : 'create';
	// 모드에 따라 apiUrl 주소 변경
	var apiUrl = mode === 'edit' ? '${editApi}' : '${createApi}';
	
    // 삭제할 기존 파일 idx 모아둘 배열
	var removeFileIdxs = [];
	
    $(function(){
    	if (mode === 'edit') {
    		$('#formTitle').text('게시글 수정');
    		$('#idxShow').text(idx);
    		// 게시글 상세 정보 가져와서 input에 채워넣기
    		$.getJSON('${detailApi}', { idx: idx }, function(item) {
	   	        $('#title').val(item.title);
	   	        $('#content').html(item.content);
	   	        
			(item.photoFiles||[]).forEach(function(f){
				// li 에 data-existing-idx 속성 붙여서 구분
				var li = $('<li>').attr('data-existing-idx', f.idx)
					.append('<input type="radio" name="thumbnail" data-type="existing" data-index="'+f.idx+'" '+(f.isThumbnail?'checked':'')+'/>&nbsp;')
					.append(f.fileName + ' [' + formatBytes(f.fileSize) + '] ')
					.append('<button type="button" class="remove-existing">X</button>');
				$('#fileList').append(li);
				
				// 삭제 버튼
				li.find('.remove-existing').click(function(){
					removeFileIdxs.push(f.idx); // 삭제할 idx 기록
					console.log('[삭제예약] removeFileIdxs:', removeFileIdxs);
					li.remove(); // 리스트에서 제거
					$('#content img[data-existing-idx="'+f.idx+'"]').remove();
					if(!$('input[name=thumbnail]:checked').length){
						$('input[name=thumbnail]').first().prop('checked',true);
					}
				});
				
				// 내용 영역에도 미리보기
				var ts = new Date().getTime(); // 캐시 버스트
				var src = '<c:url value="/uploads/"/>' + f.fileUuid + f.ext + '?t=' + ts;
				$('#content').append($('<img>').attr({src: src, 'data-existing-idx': f.idx})
				);
			});
	   	        
    		}).fail(function(){
                alert('수정할 게시글 정보 불러오기 실패');
                postTo('${listUrl}', { searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
            });
    	}
    	
    	// 작성자 input에 세션의 사용자 이름 넣기
    	$('#userName').val(sessionUserName);
    	
        // 첨부파일 배열
        var filesArr = [];
        // 파일 선택 시 리스트에 추가하는 함수
        // $('#fileInput').on('change', function(e){
       	function handleFiles(fileList){
            Array.from(fileList).forEach(function(file){
                // 배열에 저장하고, 그 위치를 fileIdx 에 담는다
                var fileIdx = filesArr.push(file) - 1;
                console.log('[추가] filesArr after push:', filesArr);
                var li = $('<li>')
	                .attr('data-file-idx', fileIdx)
	                .append('<input type="radio" name="thumbnail" data-type="new" class="thumbnail-radio" data-index="'+fileIdx+'"/> ')
	                .append(file.name + ' [' + formatBytes(file.size) + '] ')
	                .append('<button type="button" class="remove-file">X</button>');
                // 삭제 버튼 클릭 시 배열에서 제거
                li.find('.remove-file').click(function(){
                    // 삭제할 파일의 인덱스 읽어오기
                    var idxToRemove = li.data('file-idx');
                	filesArr.splice(idxToRemove, 1); // 배열에서 제거
                	console.log('[삭제] filesArr after splice:', filesArr);
                    li.remove(); // 리스트에서도 제거
                 	// contenteditable div 내에서 해당 이미지 제거
                    $('#content img[data-file-idx="' + idxToRemove + '"]').remove();
                    
                    // 남아있는 나머지 요소들의 인덱스를 재정렬
                    $('#fileList li').each(function(newIdx){
                        $(this).attr('data-file-idx', newIdx);
                        $(this).find('.thumbnail-radio').attr('data-file-idx', newIdx);
                    });
                    $('#content img').each(function(newIdx){
                        $(this).attr('data-file-idx', newIdx);
                    });
                    
                    // 삭제 후에도 라디오 없으면 첫 번째 자동 체크
                    if (!$('.thumbnail-radio:checked').length) {
                      $('.thumbnail-radio').first().prop('checked', true);
                    }
                });
                $('#fileList').append(li);
                
                // 내용 인풋에 이미지 미리보기
                var reader = new FileReader();
                reader.onload = function(ev){
                	var img = $('<img>').attr('src', ev.target.result).attr('data-file-idx', fileIdx);
                    $('#content').append(img);
                };
                reader.readAsDataURL(file);
            });
            // 라디오가 하나도 체크 안 돼 있으면 첫 번째 항목 자동 체크
            if (!$('.thumbnail-radio:checked').length) {
              $('#fileList .thumbnail-radio').first().prop('checked', true);
            }
            
            $(this).val(null);
        };
        
        // 파일 선택 버튼으로 파일 추가
		$('#fileInput').on('change', function(e){
			handleFiles(e.target.files);
			$(this).val(null);
		});
		// 드래그 앤 드롭으로 파일 추가
		var $dz = $('#dropZone');
		$dz.on('dragover', function(e){
			e.preventDefault();
			e.originalEvent.dataTransfer.dropEffect = 'copy';
			$dz.addClass('dragover'); // 스타일 변경하는 클래스 추가
		});
		$dz.on('dragleave dragend', function(e){
			e.preventDefault();
			$dz.removeClass('dragover'); // 스타일 변경하는 클래스 제거
		});
		$dz.on('drop', function(e){
			e.preventDefault();
			$dz.removeClass('dragover');
			handleFiles(e.originalEvent.dataTransfer.files);
		});
    	
        $('#btnSubmit').click(function(){
        	// 폼 검증(하나라도 인풋이 비어있으면 알림)
    		if (!$('#title')[0].reportValidity()) return;
    		if ($('#content').text().trim()==='') { alert('내용을 입력하세요'); return; }
    		
			// 에디터의 HTML 가져오기
			var rawHtml = $('#content').html();
			// 모든 <img> 태그 제거
			var cleanedHtml = rawHtml.replace(/<img[^>]*>/g, '');
			
			const $sel = $('input[name=thumbnail]:checked');
			const thumbType = $sel.data('type'); // "existing" or "new"
			const thumbIndex  = $sel.data('index'); // 숫자(=file idx)
        	
    		// 검증 통과 시 게시글 등록 api 실행
    		var data = {
    				userIdx: sessionUserIdx,
    				title: $('#title').val(),
    				content: cleanedHtml,
    			    newThumbnailIndex: thumbType==='new' ? thumbIndex : null,
    			    existingThumbnailIdx: thumbType==='existing' ? thumbIndex : null
    				}; // 보낼 데이터
    		if (mode==='edit') data.idx = idx; // 수정 모드면 idx 추가
    		
        	// FormData 생성
        	var formData = new FormData();
        	formData.append('board', new Blob([JSON.stringify(data)], { type: 'application/json' }));
        	
        	console.log('최종 filesArr:', filesArr);
        	console.log('최종 removeFileIdxs:', removeFileIdxs);
        	
			// 삭제 예약된 기존 파일 idx 들
			removeFileIdxs.forEach(function(fid){
				formData.append('removeFileIdxs', fid);
			});
        	
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
						postTo('${listUrl}', { searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
		            }
    			},
				error: function(xhr){
					alert('게시글 ' + (mode==='edit'?'수정':'등록') + ' 중 에러 발생');
				}
    		});
        });
    	
    	$('#btnCancel').click(function() {
    		// 게시글 목록 페이지 이동
    		postTo('${listUrl}', { searchType: currentSearchType, searchKeyword: currentSearchKeyword, pageIndex: currentPageIndex });
    	});
    });
	</script>
</body>
</html>