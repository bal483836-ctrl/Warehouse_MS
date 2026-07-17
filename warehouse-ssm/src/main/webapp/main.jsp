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
    <title>库智 WMS · 主页</title>
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/reset.css">
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/main.css">
    <script src="https://cdn.staticfile.org/jquery/1.10.2/jquery.min.js"></script>
    <style>.hide{display:none}</style>
    <script>
        $(function(){
            $("li[class='menu'] span").each(function(){
                $(this).click(function(){ $(this).siblings(".hide").slideToggle(); });
            });
        });
        function myExit(){ if(confirm("是否退出本系统?")){ window.location.href="/login/logOut.do"; } }
    </script>
    <link rel="stylesheet" type="text/css" href="<%=basePath %>css/app.css">
</head>
<body>
<div id="mainDiv">
    <div id="header">
        <div id="logoDiv">库智 WMS · 智能仓储管理平台</div>
        <div id="userDiv">👤 ${loginUser.name}（${loginUser.number}）</div>
    </div>
    <div id="welcomeDiv">欢迎使用库智仓库管理系统，${loginUser.name}！</div>
    <div id="contentDiv">
        <div id="content-left">
            <ul>
                <li class="menu">
                    <span>▸ 基础资料</span>
                    <ul class="hide">
                        <li><a href="/goods/list.do" target="contentPage">商品档案</a></li>
                        <li><a href="/goodstype/list.do" target="contentPage">商品分类</a></li>
                        <li><a href="/storage/list.do" target="contentPage">仓库管理</a></li>
                    </ul>
                </li>
                <li class="menu">
                    <span>▸ 出入库管理</span>
                    <ul class="hide">
                        <li><a href="/record/gotoInout.do" target="contentPage">出入库操作</a></li>
                        <li><a href="/record/list.do" target="contentPage">出入库记录</a></li>
                    </ul>
                </li>
                <li class="menu">
                    <span>▸ 系统</span>
                    <ul class="hide">
                        <li><a href="javascript:myExit();">系统退出</a></li>
                    </ul>
                </li>
            </ul>
        </div>
        <div id="content-right">
            <iframe src="/goods/list.do" name="contentPage" scrolling="yes" frameborder="0"></iframe>
        </div>
    </div>
    <div id="footer"><span>&copy; 库智 WMS · 安徽工业大学 侯皖婷</span></div>
</div>
</body>
</html>
