<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理员登录 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #2d3436 0%, #636e72 100%); min-height: 100vh; }
        .login-card { max-width: 460px; margin: 70px auto; border-radius: 18px; box-shadow: 0 12px 42px rgba(0,0,0,0.28); overflow: hidden; }
        .login-header { background: linear-gradient(135deg, #2d3436 0%, #636e72 100%); color: white; padding: 34px 30px; text-align: center; }
        .login-title { font-size: 2.2rem; font-weight: 700; margin-bottom: 8px; }
        .login-subtitle { font-size: 1.1rem; opacity: 0.96; margin-bottom: 12px; }
        .mode-badge { display:inline-block; margin-top:6px; background: rgba(255,255,255,0.18); border:1px solid rgba(255,255,255,0.35); border-radius:999px; padding:7px 16px; font-size:14px; }
        .back-link { display:inline-block; margin-top:10px; color:#fff; text-decoration:none; font-size:14px; border:1px solid rgba(255,255,255,0.35); border-radius:999px; padding:6px 14px; background: rgba(255,255,255,0.12); }
        .back-link:hover { color:#fff; opacity:0.9; }
        .login-body { padding: 32px 30px; background: #fff; }
        .btn-login { background: linear-gradient(135deg, #2d3436 0%, #636e72 100%); border: none; width: 100%; padding: 12px; font-size: 17px; color: #fff; border-radius: 10px; }
        .btn-login:hover { opacity: 0.92; color: #fff; }
    </style>
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body>
<div class="container">
    <div class="card login-card">
        <div class="login-header">
            <div class="login-title">大学生海报设计竞赛系统</div>
            <div class="login-subtitle">管理员登录</div>
            <div class="mode-badge">仅管理员账号可通过此入口登录</div>
            <div><a href="${pageContext.request.contextPath}/login" class="back-link">返回普通用户登录</a></div>
        </div>
        <div class="login-body">
            <% String error = (String) request.getAttribute("error"); %>
            <% if (error != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/login" method="post">
                <div class="mb-3">
                    <label for="username" class="form-label">管理员账号</label>
                    <input type="text" class="form-control" id="username" name="username"
                           value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                           placeholder="请输入管理员账号" required>
                </div>
                <div class="mb-3">
                    <label for="password" class="form-label">密码</label>
                    <input type="password" class="form-control" id="password" name="password"
                           placeholder="请输入密码" required>
                </div>
                <button type="submit" class="btn btn-login">管理员登录</button>
            </form>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
