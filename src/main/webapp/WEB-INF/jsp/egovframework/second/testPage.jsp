<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>테스트 페이지</title>
<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>

<!-- 사용자 리스트 json 가져오는 api 호출 url -->
<c:url value="/userList.do" var="userListUrl"/>
</head>
<body>
    <h2>Test List</h2>
    <table id="userListTbl" border="1">
    	<thead>
	        <tr>
	            <th>Idx</th>
	            <th>아이디</th>
	            <th>비밀번호</th>
	            <th>이름</th>
	            <th>등록일</th>
	        </tr>
    	</thead>
    	<tbody></tbody>
    </table>
    
    <script>
	    $(document).ready(function() {
	    	console.log('AJAX 호출 URL=', '${userListUrl}');
	        $.ajax({
	            url: '${userListUrl}',
	            type: 'GET',
	            dataType: 'json',
	            success: function(data) {
	            	console.log('받아온 데이터=', data);
	                var $tbody = $('#userListTbl').find('tbody');
	                $tbody.empty();
	                $.each(data, function(i, item) {
	                    var row = '<tr>' +
	                              '<td>' + item.idx + '</td>' +
	                              '<td>' + item.user_id + '</td>' +
	                              '<td>' + item.password + '</td>' +
	                              '<td>' + item.user_name + '</td>' +
	                              '<td>' + item.created_at + '</td>' +
	                              '</tr>';
	                    $tbody.append(row);  
	                });
	            },
	            error: function(xhr, status, error) {
	                console.error('AJAX 에러:', error);
	            }
	        });
	    });
    </script>
</body>
</html>