<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"/><title>出入库记录</title>
<link rel="stylesheet" href="<%=basePath %>css/reset.css"><link rel="stylesheet" href="<%=basePath %>css/main.css"></head><body>
<h1 class="title">首页 &gt;&gt; 出入库记录</h1>
<table class="deptInfo">
    <tr class="titleRow"><td>ID</td><td>货物</td><td>类型</td><td>数量</td><td>操作人</td><td>时间</td><td>备注</td></tr>
    <c:forEach items="${page.list}" var="r">
        <tr><td>${r.id}</td><td>${r.goodsName}</td>
            <td><c:choose>
                <c:when test="${r.type == 0}"><span class="pill in">入库</span></c:when>
                <c:otherwise><span class="pill out">出库</span></c:otherwise>
            </c:choose></td>
            <td>${r.count}</td><td>${r.userName}</td>
            <td><fmt:formatDate value="${r.createtime}" pattern="yyyy-MM-dd HH:mm"/></td>
            <td>${r.remark}</td></tr>
    </c:forEach>
</table>
${str}
</body></html>
