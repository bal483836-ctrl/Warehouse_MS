<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"/><title>新增商品</title>
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/reset.css">
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/main.css"></head>
<body>
<div class="formCard">
    <h2>新增商品</h2>
    <form action="/goods/add.do" method="post">
        <div class="formRow"><label>商品名</label><input type="text" name="name" required></div>
        <div class="formRow"><label>所属仓库</label>
            <select name="storage">
                <c:forEach items="${storageList}" var="s"><option value="${s.id}">${s.name}</option></c:forEach>
            </select>
        </div>
        <div class="formRow"><label>分类</label>
            <select name="goodsType">
                <c:forEach items="${typeList}" var="t"><option value="${t.id}">${t.name}</option></c:forEach>
            </select>
        </div>
        <div class="formRow"><label>库存数量</label><input type="number" name="count" value="0"></div>
        <div class="formRow"><label>备注</label><textarea name="remark" rows="2"></textarea></div>
        <div class="formBtns">
            <button type="submit" class="btn btn-primary">保存</button>
            <button type="button" class="btn btn-plain" onclick="history.back()">返回</button>
        </div>
    </form>
</div>
</body>
</html>
