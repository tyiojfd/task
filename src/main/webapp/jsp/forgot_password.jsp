<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>找回密码 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-auth">
<div class="container">
    <div class="app-auth-glass">
        <div class="app-auth-brand">
            <h1>找回密码</h1>
            <p>输入用户名和注册邮箱，验证通过后即可设置新密码。重置后请使用新密码登录。</p>
        </div>
        <div class="app-auth-form">
            <h2>重置密码</h2>

            <c:if test="${not empty success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    ${success}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/forgot-password" method="post">
                <div class="mb-3">
                    <label class="form-label">用户名</label>
                    <input type="text" name="username" class="form-control" value="<c:out value='${username}' default=''/>" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">注册邮箱</label>
                    <input type="email" name="email" class="form-control" value="<c:out value='${email}' default=''/>" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">新密码（至少6位）</label>
                    <input type="password" name="newPassword" class="form-control" minlength="6" required>
                </div>
                <div class="mb-4">
                    <label class="form-label">确认新密码</label>
                    <input type="password" name="confirmPassword" class="form-control" minlength="6" required>
                </div>
                <button type="submit" class="btn btn-primary w-100 mb-3">重置密码</button>
            </form>

            <div class="app-auth-links">
                <span></span>
                <a href="${pageContext.request.contextPath}/login">返回登录</a>
            </div>
        </div>
    </div>
</div>
</body>
</html>
