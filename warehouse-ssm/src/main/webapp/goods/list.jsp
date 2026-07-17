<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"/>
    <title>商品档案</title>
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/reset.css">
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/main.css">
    <script>
        function del(id){ if(confirm("确认删除该商品吗?")){ window.location.href='/goods/deleteById.do?id='+id; } }
    </script>
</head>
<body>
<h1 class="title">首页 &gt;&gt; 商品档案</h1>
<div class="add"><a href="/goods/gotoAdd.do">＋ 新增商品</a></div>
<table class="deptInfo">
    <tr class="titleRow">
        <td>ID</td><td>商品名</td><td>所属仓库</td><td>分类</td><td>库存</td><td>备注</td><td>操作</td>
    </tr>
    <c:forEach items="${page.list}" var="g">
        <tr>
            <td>${g.id}</td>
            <td>${g.name}</td>
            <td>${g.storageName}</td>
            <td>${g.goodsTypeName}</td>
            <td>${g.count}</td>
            <td>${g.remark}</td>
            <td>
                <a class="op" href="/goods/gotoModify.do?id=${g.id}">编辑</a>
                <a class="op" href="/goods/detail.do?id=${g.id}">详情</a>
                <span class="op del" onclick="del(${g.id})">删除</span>
            </td>
        </tr>
    </c:forEach>
</table>
${str}
</body>
</html>
