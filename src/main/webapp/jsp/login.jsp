<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .app-auth-glass .switch-card {
            border: 1px solid var(--app-rule);
            border-radius: 10px;
            padding: 18px;
            margin-top: 22px;
            background: var(--app-surface-soft);
        }
        .app-auth-glass .switch-btn {
            width: 100%;
            margin-bottom: 10px;
            text-align: left;
            border-radius: 10px;
            font-size: 15px;
            padding: 10px 14px;
        }
        .app-auth-glass .small-tip {
            font-size: 12px;
            color: var(--app-muted);
            line-height: 1.6;
        }
    </style>
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-auth">
<div class="container">
    <div class="app-auth-glass">
        <div class="app-auth-brand">
            <h1>海报竞赛</h1>
            <p>大学生海报设计竞赛平台 &mdash; 发布赛事、组建团队、提交作品、专业评审。</p>
        </div>
        <div class="app-auth-form">
            <h2>登录</h2>

            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% String success = (String) request.getAttribute("success"); %>
            <% if (success != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <%= success %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/login" method="post">
                <div class="mb-3">
                    <label for="username" class="form-label">用户名</label>
                    <input type="text" class="form-control" id="username" name="username"
                           value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                           placeholder="请输入用户名" required>
                </div>
                <div class="mb-3">
                    <label for="password" class="form-label">密码</label>
                    <input type="password" class="form-control" id="password" name="password"
                           placeholder="请输入密码" required>
                </div>
                <button type="submit" class="btn btn-primary">登录</button>
            </form>

            <div class="app-auth-links">
                <a href="${pageContext.request.contextPath}/register">注册账号</a>
                <a href="${pageContext.request.contextPath}/forgot-password">忘记密码？</a>
            </div>

            <div class="switch-card">
                <div class="fw-bold mb-2">登录入口切换</div>
                <button type="button" class="btn btn-outline-success switch-btn" onclick="location.href='${pageContext.request.contextPath}/login?role=judge'">进入评委登录页面</button>
                <button type="button" class="btn btn-outline-dark switch-btn" onclick="location.href='${pageContext.request.contextPath}/login?role=admin'">进入管理员登录页面</button>
                <div class="small-tip">普通用户使用当前页面登录；评委和管理员请进入各自独立的登录页面。</div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
