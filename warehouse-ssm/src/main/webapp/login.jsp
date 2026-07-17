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
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>库智 WMS · 登录</title>
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/reset.css">
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/login.css">
    <style>
        body{min-height:100vh;background:radial-gradient(120% 80% at 80% -10%,#16346f,transparent 55%),
             linear-gradient(135deg,#0a0e17,#0e1523 55%,#0a1120)}
    </style>
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/app.css">
    <script>
        function flushCode(){ document.getElementById("imgShow").src = "/login/captcha.do?t=" + new Date().getTime(); }
    </script>
</head>
<body>
<div id="login">
    <div id="title">库智 WMS · 智能仓储管理平台</div>
    <div id="message">${msg}</div>
    <form action="/login/login.do" method="post">
        <table id="loginTable">
            <tr>
                <td width="70">账号：</td>
                <td><input type="text" name="userName" id="userName" value="admin"/></td>
            </tr>
            <tr>
                <td>密码：</td>
                <td><input type="password" name="password" id="password" value=""/></td>
            </tr>
            <tr>
                <td>验证码：</td>
                <td style="display:flex;align-items:center;gap:8px">
                    <input type="text" name="code" id="code" style="width:110px;"/>
                    <img id="imgShow" src="/login/captcha.do" onclick="flushCode()" width="110" height="38"
                         style="border-radius:8px;cursor:pointer" title="看不清？点击刷新"/>
                </td>
            </tr>
            <tr>
                <td></td>
                <td><button type="submit" class="loginBtn">登 录</button></td>
            </tr>
        </table>
    </form>
    <div style="text-align:center;margin-top:14px;color:#7c8798;font-size:12px">演示账号：admin / admin123　·　test / 123456</div>
</div>
</body>
</html>
