<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>회원가입</title>
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	<!-- 로그인 페이지 URL -->
	<c:url value="/login.do" var="loginUrl"/>
</head>
<body>
	<h2>회원가입</h2>
	<label>아이디: <input type="text" id="userId"/></label><br/>
	<label>비밀번호: <input type="password" id="password"/></label><br/>
	<label>이름: <input type="text" id="userName"/></label><br/>
	<button id="btnRegister">가입하기</button>
	
	<script>
    $('#btnRegister').click(function(){
		var data={userId:$('#userId').val(), password:$('#password').val(), userName:$('#userName').val()};
		$.ajax({
			url:'<c:url value="/api/user/register.do"/>',
			type:'POST',
			contentType:'application/json',
			data:JSON.stringify(data),
			success:function(res){
				if(res.status=='OK') {
					alert('가입 완료!');
					// 로그인 페이지로
					window.location.href = '${loginUrl}';
				} else {
					alert('오류: ' + res.error);
				}
			},
	        error: function(xhr, status, error) {
            	alert('서버 오류 발생!');
            }
		});
    });
	</script>
</body>
</html>