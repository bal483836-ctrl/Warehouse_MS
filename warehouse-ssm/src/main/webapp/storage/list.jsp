<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"/><title>仓库管理</title>
<link rel="stylesheet" href="<%=basePath %>css/reset.css"><link rel="stylesheet" href="<%=basePath %>css/main.css">
<script>function del(id){ if(confirm("确认删除该仓库吗?")){ window.location.href='/storage/deleteById.do?id='+id; } }</script>
</head><body>
<h1 class="title">首页 &gt;&gt; 仓库管理</h1>
<div class="add"><a href="/storage/gotoAdd.do">＋ 新增仓库</a></div>
<table class="deptInfo">
    <tr class="titleRow"><td>ID</td><td>仓库名</td><td>备注</td><td>操作</td></tr>
    <c:forEach items="${page.list}" var="s">
        <tr><td>${s.id}</td><td>${s.name}</td><td>${s.remark}</td>
        <td><a class="op" href="/storage/gotoModify.do?id=${s.id}">编辑</a>
            <span class="op del" onclick="del(${s.id})">删除</span></td></tr>
    </c:forEach>
</table>
${str}
</body></html>
