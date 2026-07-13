<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>评委登录 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .app-auth-glass .back-link {
            display: inline-block;
            margin-top: 10px;
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            font-size: 14px;
            border: 1px solid rgba(255,255,255,0.3);
            border-radius: 999px;
            padding: 6px 14px;
            background: rgba(255,255,255,0.1);
            transition: background 180ms ease;
        }
        .app-auth-glass .back-link:hover {
            color: #fff;
            background: rgba(255,255,255,0.18);
        }
    </style>
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-auth">
<div class="container">
    <div class="app-auth-glass">
        <div class="app-auth-brand">
            <h1>⭐ 评委登录</h1>
            <p>评审工作台。查看作品、评分打分、撰写评语——专业评审入口。</p>
            <div><a href="${pageContext.request.contextPath}/login" class="back-link">返回普通用户登录</a></div>
        </div>
        <div class="app-auth-form">
            <h2>评委登录</h2>

            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/login" method="post">
                <div class="mb-3">
                    <label for="username" class="form-label">评委账号</label>
                    <input type="text" class="form-control" id="username" name="username"
                           value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                           placeholder="请输入评委账号" required>
                </div>
                <div class="mb-3">
                    <label for="password" class="form-label">密码</label>
                    <input type="password" class="form-control" id="password" name="password"
                           placeholder="请输入密码" required>
                </div>
                <button type="submit" class="btn btn-primary">评委登录</button>
            </form>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
