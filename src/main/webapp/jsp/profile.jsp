<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="java.util.List" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    // 检查用户角色
    @SuppressWarnings("unchecked")
    List<Role> userRoles = (List<Role>) session.getAttribute("roles");
    boolean isAdmin = false;
    boolean isJudge = false;
    if (userRoles != null) {
        for (Role role : userRoles) {
            if ("管理员".equals(role.getRoleName())) isAdmin = true;
            if ("评委".equals(role.getRoleName())) isJudge = true;
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人中心 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: #f5f5f5; }
        .navbar-brand { font-weight: bold; }
        .profile-card { border-radius: 15px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .card-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 15px 15px 0 0 !important; }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
        <div class="container">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/index">🎨 海报竞赛系统</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/index">竞赛大厅</a></li>
                    <% if (!isAdmin && !isJudge) { %>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/team?action=myTeams">我的队伍</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/invitation">邀请通知</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/work?action=myWorks">我的作品</a></li>
                    <% } %>
                    <% if (isJudge) { %>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/score?action=list">评分管理</a></li>
                    <% } %>
                    <% if (isAdmin) { %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">管理中心</a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/users"><i class="fas fa-users me-1"></i>用户管理</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/competition?action=list">竞赛管理</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/award?action=manage">获奖管理</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/news?action=manage">新闻管理</a></li>
                        </ul>
                    </li>
                    <% } %>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/news?action=list">新闻公告</a></li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle active" href="#" role="button" data-bs-toggle="dropdown"><c:out value="${sessionScope.user.realName}"/></a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">个人中心</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">退出登录</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <%-- 提示信息 --%>
        <c:if test="${not empty success}"><div class="alert alert-success alert-dismissible fade show">${success}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>
        <c:if test="${not empty error}"><div class="alert alert-danger alert-dismissible fade show">${error}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>

        <div class="row">
            <!-- 个人信息卡片 -->
            <div class="col-md-4">
                <div class="card profile-card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">个人信息</h5>
                    </div>
                    <div class="card-body text-center">
                        <div class="mb-3 position-relative d-inline-block">
                            <% if (sessionUser.getAvatar() != null && !sessionUser.getAvatar().isEmpty()) { %>
                                <img src="<%= request.getContextPath() + sessionUser.getAvatar() %>"
                                     style="width:100px;height:100px;border-radius:50%;object-fit:cover;
                                            box-shadow:0 4px 16px rgba(108,92,231,0.3);" alt="头像">
                            <% } else { %>
                                <div style="width:100px;height:100px;border-radius:50%;background:linear-gradient(135deg, #6C5CE7, #FD79A8);
                                            display:inline-flex;align-items:center;justify-content:center;
                                            font-size:2.5rem;font-weight:700;color:white;
                                            box-shadow:0 4px 16px rgba(108,92,231,0.3);">
                                    <%= sessionUser.getRealName() != null && !sessionUser.getRealName().isEmpty() ? sessionUser.getRealName().substring(0,1) : "?" %>
                                </div>
                            <% } %>
                            <label for="avatarUpload" style="position:absolute;bottom:0;right:0;width:30px;height:30px;
                                        background:var(--primary-color, #6C5CE7);border-radius:50%;cursor:pointer;
                                        display:flex;align-items:center;justify-content:center;color:white;
                                        font-size:0.8rem;box-shadow:0 2px 8px rgba(0,0,0,0.2);"
                                   title="更换头像">
                                <i class="fas fa-camera"></i>
                            </label>
                        </div>
                        <h5><%= sessionUser.getRealName() %></h5>
                        <p class="text-muted">@<%= sessionUser.getUsername() %></p>
                        <p>
                            <span class="badge bg-<%= sessionUser.getStatus() == 1 ? "success" : "danger" %>">
                                <%= sessionUser.getStatus() == 1 ? "正常" : "已禁用" %>
                            </span>
                        </p>
                        <!-- 隐藏的头像上传表单 -->
                        <form id="avatarForm" action="${pageContext.request.contextPath}/profile" method="post"
                              enctype="multipart/form-data" style="display:none;">
                            <input type="hidden" name="action" value="uploadAvatar">
                            <input type="file" name="avatar" id="avatarUpload" accept="image/jpeg,image/png"
                                   onchange="document.getElementById('avatarForm').submit()">
                        </form>
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
                                <input type="text" class="form-control" value='<c:out value="${sessionScope.user.username}"/>' disabled>
                            </div>
                            <div class="mb-3">
                                <label for="realName" class="form-label">真实姓名</label>
                                <input type="text" class="form-control" id="realName" name="realName"
                                       value='<c:out value="${sessionScope.user.realName}"/>' required>
                            </div>
                            <div class="mb-3">
                                <label for="email" class="form-label">邮箱</label>
                                <input type="email" class="form-control" id="email" name="email"
                                       value='<c:out value="${sessionScope.user.email}" default=""/>' required>
                            </div>
                            <div class="mb-3">
                                <label for="phone" class="form-label">手机号</label>
                                <input type="text" class="form-control" id="phone" name="phone"
                                       value='<c:out value="${sessionScope.user.phone}" default=""/>'>
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
