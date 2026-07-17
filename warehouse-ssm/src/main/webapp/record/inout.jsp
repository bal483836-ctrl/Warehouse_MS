<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!DOCTYPE html><html><head><meta charset="UTF-8"/><title>出入库操作</title>
<link rel="stylesheet" href="<%=basePath %>css/reset.css"><link rel="stylesheet" href="<%=basePath %>css/main.css"></head><body>
<h1 class="title">首页 &gt;&gt; 出入库操作</h1>
<div class="formCard" style="max-width:640px">
    <h2>登记出入库单据</h2>
    <form id="ioForm" method="post">
        <div class="formRow"><label>选择货物</label>
            <select name="goodsId" id="goodsId">
                <c:forEach items="${goodsList}" var="g">
                    <option value="${g.id}">${g.name}（${g.storageName}，当前库存 ${g.count}）</option>
                </c:forEach>
            </select>
        </div>
        <div class="formRow"><label>数量</label><input type="number" name="count" id="count" value="10" min="1"></div>
        <div class="formRow"><label>备注</label><input type="text" name="remark" placeholder="选填"></div>
        <div class="formBtns">
            <button type="button" class="btn btn-primary" onclick="submitIo('/record/inbound.do')">入 库</button>
            <button type="button" class="btn btn-plain" onclick="submitIo('/record/outbound.do')">出 库</button>
        </div>
    </form>
</div>
<script>
    function submitIo(url){
        var f = document.getElementById('ioForm');
        if(!document.getElementById('count').value || document.getElementById('count').value <= 0){ alert('请输入正数数量'); return; }
        f.action = url; f.submit();
    }
</script>
</body></html>
