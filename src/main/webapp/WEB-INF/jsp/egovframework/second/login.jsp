<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>로그인</title>
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	<!-- 회원가입 페이지 url -->
	<c:url value="/register.do" var="registerUrl"/>
</head>
<body>
	<h2>로그인</h2>
	<label>아이디: 
		<input type="text" id="userId" required maxlength="15"/>
	</label><br/>
	<label>비밀번호: 
		<input type="password" id="password" required maxlength="15"/>
	</label><br/>
	<button id="btnLogin">로그인</button>
	<button type="button" id="btnGoRegister">회원가입</button>
	<script>
    $('#btnLogin').click(function(){
    	// 폼 검증(하나라도 인풋이 비어있으면 알림)
		var idVal = $('#userId')[0];
		var passwordVal = $('#password')[0];
		
		if (!idVal.reportValidity()) return;
		if (!passwordVal.reportValidity()) return;
    	
		// 검증 통과 시 로그인 api 실행
		var data={userId:$('#userId').val(), password:$('#password').val()};
		$.ajax({
			url:'<c:url value="/api/user/login.do"/>',
			type:'POST',
			contentType:'application/json',
			data:JSON.stringify(data),
			success:function(res){
		        if(res.user) window.location='<c:url value="/boardList.do"/>';
		        else alert(res.error);
			}
		});
    });
    
    $(function(){
    	$('#btnGoRegister').click(function() {
    		// 회원가입 페이지 이동
    		window.location.href = '${registerUrl}';
    	});
    });
	</script>
</body>
</html>