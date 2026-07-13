<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>找回密码 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { min-height: 100vh; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); display: flex; align-items: center; }
        .reset-card { border: 0; border-radius: 18px; box-shadow: 0 20px 45px rgba(0,0,0,.18); overflow: hidden; }
        .brand-panel { background: linear-gradient(135deg, #6C5CE7, #A29BFE); color: #fff; padding: 36px; }
        .form-panel { padding: 36px; }
    </style>
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body>
<div class="container">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-xl-7">
            <div class="card reset-card">
                <div class="row g-0">
                    <div class="col-md-5 brand-panel d-flex flex-column justify-content-center">
                        <h3 class="fw-bold mb-3">找回密码</h3>
                        <p class="mb-0">输入用户名和注册邮箱，验证通过后即可设置新密码。</p>
                    </div>
                    <div class="col-md-7 form-panel">
                        <c:if test="${not empty success}"><div class="alert alert-success">${success}</div></c:if>
                        <c:if test="${not empty error}"><div class="alert alert-danger">${error}</div></c:if>
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
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-secondary w-100">返回登录</a>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
