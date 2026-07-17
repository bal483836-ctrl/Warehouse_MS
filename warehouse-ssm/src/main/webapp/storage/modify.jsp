<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"/><title>修改仓库</title>
<link rel="stylesheet" href="<%=basePath %>css/reset.css"><link rel="stylesheet" href="<%=basePath %>css/main.css"></head><body>
<div class="formCard"><h2>修改仓库</h2>
<form action="/storage/doModify.do" method="post">
    <input type="hidden" name="id" value="${storage.id}">
    <div class="formRow"><label>仓库名</label><input type="text" name="name" value="${storage.name}" required></div>
    <div class="formRow"><label>备注</label><textarea name="remark" rows="2">${storage.remark}</textarea></div>
    <div class="formBtns"><button class="btn btn-primary">保存修改</button>
        <button type="button" class="btn btn-plain" onclick="history.back()">返回</button></div>
</form></div>
</body></html>
