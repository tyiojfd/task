<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>注册 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .register-card { max-width: 480px; margin: 40px auto; border-radius: 15px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); }
        .register-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 15px 15px 0 0; padding: 30px; text-align: center; }
        .register-body { padding: 30px; }
        .btn-register { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; width: 100%; padding: 10px; font-size: 16px; }
        .btn-register:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <div class="container">
        <div class="card register-card">
            <div class="register-header">
                <h3>大学生海报设计竞赛系统</h3>
                <p class="mb-0">用户注册</p>
            </div>
            <div class="register-body">
                <%-- 错误提示 --%>
                <% String error = (String) request.getAttribute("error"); %>
                <% if (error != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <%= error %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/register" method="post">
                    <div class="mb-3">
                        <label for="username" class="form-label">用户名 <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="username" name="username"
                               placeholder="请输入用户名（3-20位）" required>
                    </div>
                    <div class="mb-3">
                        <label for="realName" class="form-label">真实姓名 <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="realName" name="realName"
                               placeholder="请输入真实姓名" required>
                    </div>
                    <div class="mb-3">
                        <label for="email" class="form-label">邮箱 <span class="text-danger">*</span></label>
                        <input type="email" class="form-control" id="email" name="email"
                               placeholder="请输入邮箱地址" required>
                    </div>
                    <div class="mb-3">
                        <label for="password" class="form-label">密码 <span class="text-danger">*</span></label>
                        <input type="password" class="form-control" id="password" name="password"
                               placeholder="请输入密码（至少6位）" required minlength="6">
                    </div>
                    <div class="mb-3">
                        <label for="confirmPassword" class="form-label">确认密码 <span class="text-danger">*</span></label>
                        <input type="password" class="form-control" id="confirmPassword" name="confirmPassword"
                               placeholder="请再次输入密码" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-register">注 册</button>
                </form>
                <div class="text-center mt-3">
                    <p>已有账号？<a href="${pageContext.request.contextPath}/login">立即登录</a></p>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
