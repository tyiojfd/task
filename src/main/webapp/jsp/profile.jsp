<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人中心 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f5f5f5; }
        .navbar-brand { font-weight: bold; }
        .profile-card { border-radius: 15px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .card-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 15px 15px 0 0 !important; }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/index">海报竞赛系统</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/profile">个人中心</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/logout">退出登录</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <%-- 提示信息 --%>
        <% String successMsg = (String) request.getAttribute("success"); %>
        <% if (successMsg != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <%= successMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        <% String errorMsg = (String) request.getAttribute("error"); %>
        <% if (errorMsg != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= errorMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="row">
            <!-- 个人信息卡片 -->
            <div class="col-md-4">
                <div class="card profile-card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">个人信息</h5>
                    </div>
                    <div class="card-body text-center">
                        <div class="mb-3">
                            <img src="https://via.placeholder.com/100" class="rounded-circle" alt="头像">
                        </div>
                        <h5><%= sessionUser.getRealName() %></h5>
                        <p class="text-muted">@<%= sessionUser.getUsername() %></p>
                        <p>
                            <span class="badge bg-<%= sessionUser.getStatus() == 1 ? "success" : "danger" %>">
                                <%= sessionUser.getStatus() == 1 ? "正常" : "已禁用" %>
                            </span>
                        </p>
                    </div>
                </div>
            </div>

            <!-- 信息编辑/密码修改 -->
            <div class="col-md-8">
                <!-- 编辑个人信息 -->
                <div class="card profile-card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">编辑个人信息</h5>
                    </div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/profile" method="post">
                            <input type="hidden" name="action" value="updateProfile">
                            <div class="mb-3">
                                <label class="form-label">用户名</label>
                                <input type="text" class="form-control" value="<%= sessionUser.getUsername() %>" disabled>
                            </div>
                            <div class="mb-3">
                                <label for="realName" class="form-label">真实姓名</label>
                                <input type="text" class="form-control" id="realName" name="realName"
                                       value="<%= sessionUser.getRealName() %>" required>
                            </div>
                            <div class="mb-3">
                                <label for="email" class="form-label">邮箱</label>
                                <input type="email" class="form-control" id="email" name="email"
                                       value="<%= sessionUser.getEmail() != null ? sessionUser.getEmail() : "" %>" required>
                            </div>
                            <div class="mb-3">
                                <label for="phone" class="form-label">手机号</label>
                                <input type="text" class="form-control" id="phone" name="phone"
                                       value="<%= sessionUser.getPhone() != null ? sessionUser.getPhone() : "" %>">
                            </div>
                            <button type="submit" class="btn btn-primary">保存修改</button>
                        </form>
                    </div>
                </div>

                <!-- 修改密码 -->
                <div class="card profile-card">
                    <div class="card-header">
                        <h5 class="mb-0">修改密码</h5>
                    </div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/profile" method="post">
                            <input type="hidden" name="action" value="changePassword">
                            <div class="mb-3">
                                <label for="oldPassword" class="form-label">当前密码</label>
                                <input type="password" class="form-control" id="oldPassword" name="oldPassword"
                                       placeholder="请输入当前密码" required>
                            </div>
                            <div class="mb-3">
                                <label for="newPassword" class="form-label">新密码</label>
                                <input type="password" class="form-control" id="newPassword" name="newPassword"
                                       placeholder="请输入新密码（至少6位）" required minlength="6">
                            </div>
                            <div class="mb-3">
                                <label for="confirmNewPassword" class="form-label">确认新密码</label>
                                <input type="password" class="form-control" id="confirmNewPassword" name="confirmNewPassword"
                                       placeholder="请再次输入新密码" required>
                            </div>
                            <button type="submit" class="btn btn-warning">修改密码</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
