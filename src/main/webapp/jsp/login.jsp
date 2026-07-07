<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .login-card { max-width: 420px; margin: 80px auto; border-radius: 15px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); }
        .login-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 15px 15px 0 0; padding: 30px; text-align: center; }
        .login-body { padding: 30px; }
        .btn-login { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; width: 100%; padding: 10px; font-size: 16px; }
        .btn-login:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <% request.setAttribute("activePage", ""); %>
    <%@ include file="navbar.jsp" %>

    <div class="container">
        <div class="card login-card">
            <div class="login-header">
                <h3>大学生海报设计竞赛系统</h3>
                <p class="mb-0">用户登录</p>
            </div>
            <div class="login-body">
                <%-- 错误提示 --%>
                <% String error = (String) request.getAttribute("error"); %>
                <% if (error != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <%= error %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <%-- 成功提示 --%>
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
                    <button type="submit" class="btn btn-primary btn-login">登 录</button>
                </form>
                <div class="text-center mt-3">
                    <p>还没有账号？<a href="${pageContext.request.contextPath}/register">立即注册</a></p>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
