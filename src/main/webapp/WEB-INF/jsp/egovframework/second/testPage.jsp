<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>테스트 페이지</title>
</head>
<body>
    <h2>Test List</h2>
    <table border="1">
        <tr>
            <th>Idx</th>
            <th>Name</th>
            <th>Code</th>
        </tr>
        <c:forEach var="item" items="${testList}">
            <tr>
                <td>${item.idx}</td>
                <td>${item.name}</td>
                <td>${item.code}</td>
            </tr>
        </c:forEach>
    </table>
</body>
</html>