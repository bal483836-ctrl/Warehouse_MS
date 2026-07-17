<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"/><title>商品分类</title>
<link rel="stylesheet" href="<%=basePath %>css/reset.css"><link rel="stylesheet" href="<%=basePath %>css/main.css">
<script>function del(id){ if(confirm("确认删除该分类吗?")){ window.location.href='/goodstype/deleteById.do?id='+id; } }</script>
</head><body>
<h1 class="title">首页 &gt;&gt; 商品分类</h1>
<div class="add"><a href="/goodstype/gotoAdd.do">＋ 新增分类</a></div>
<table class="deptInfo">
    <tr class="titleRow"><td>ID</td><td>分类名</td><td>备注</td><td>操作</td></tr>
    <c:forEach items="${page.list}" var="t">
        <tr><td>${t.id}</td><td>${t.name}</td><td>${t.remark}</td>
        <td><a class="op" href="/goodstype/gotoModify.do?id=${t.id}">编辑</a>
            <span class="op del" onclick="del(${t.id})">删除</span></td></tr>
    </c:forEach>
</table>
${str}
</body></html>
