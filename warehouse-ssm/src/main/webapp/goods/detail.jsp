<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"/><title>商品详情</title>
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/reset.css">
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/main.css"></head>
<body>
<div class="formCard">
    <h2>商品详情</h2>
    <div class="formRow"><label>ID</label><span>${goods.id}</span></div>
    <div class="formRow"><label>商品名</label><span>${goods.name}</span></div>
    <div class="formRow"><label>所属仓库</label><span>${goods.storageName}</span></div>
    <div class="formRow"><label>分类</label><span>${goods.goodsTypeName}</span></div>
    <div class="formRow"><label>库存</label><span>${goods.count}</span></div>
    <div class="formRow"><label>备注</label><span>${goods.remark}</span></div>
    <div class="formBtns"><button class="btn btn-plain" onclick="history.back()">返回</button></div>
</div>
</body>
</html>
