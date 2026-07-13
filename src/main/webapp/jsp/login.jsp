<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>普通用户登录 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .login-card { max-width: 460px; margin: 70px auto; border-radius: 18px; box-shadow: 0 12px 42px rgba(0,0,0,0.22); overflow: hidden; }
        .login-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 34px 30px; text-align: center; }
        .login-title { font-size: 2.2rem; font-weight: 700; margin-bottom: 8px; }
        .login-subtitle { font-size: 1.1rem; opacity: 0.96; margin-bottom: 12px; }
        .mode-badge { display:inline-block; margin-top:6px; background: rgba(255,255,255,0.18); border:1px solid rgba(255,255,255,0.35); border-radius:999px; padding:7px 16px; font-size:14px; }
        .login-body { padding: 32px 30px; background: #fff; }
        .btn-login { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; width: 100%; padding: 12px; font-size: 17px; color: #fff; border-radius: 10px; }
        .btn-login:hover { opacity: 0.92; color: #fff; }
        .switch-card { background:#f8f9fa; border:1px solid #e9ecef; border-radius:14px; padding:18px; margin-top:22px; }
        .switch-btn { width:100%; margin-bottom:12px; text-align:left; border-radius:10px; font-size:16px; padding:10px 14px; }
        .small-tip { font-size:13px; color:#6c757d; line-height:1.6; }
    </style>
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body>
<div class="container">
    <div class="card login-card">
        <div class="login-header">
            <div class="login-title">大学生海报设计竞赛系统</div>
            <div class="login-subtitle">用户登录</div>
            <div class="mode-badge">普通用户登录入口</div>
        </div>
        <div class="login-body">
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
                <button type="submit" class="btn btn-login">登 录</button>
            </form>

            <div class="switch-card">
                <div class="fw-bold mb-2">登录入口切换</div>
                <button type="button" class="btn btn-outline-success switch-btn" onclick="location.href='${pageContext.request.contextPath}/login?role=judge'">进入评委登录页面</button>
                <button type="button" class="btn btn-outline-dark switch-btn" onclick="location.href='${pageContext.request.contextPath}/login?role=admin'">进入管理员登录页面</button>
                <div class="small-tip">普通用户使用当前页面登录；评委和管理员请进入各自独立的登录页面。</div>
            </div>

            <div class="text-center mt-3">
                <p>还没有账号？<a href="${pageContext.request.contextPath}/register">立即注册</a></p>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
