<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="java.util.List" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    @SuppressWarnings("unchecked")
    List<Role> userRoles = (List<Role>) session.getAttribute("roles");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>首页 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f5f5f5; }
        .navbar-brand { font-weight: bold; }
        .welcome-card { border-radius: 15px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .welcome-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 15px 15px 0 0; padding: 40px; text-align: center; }
        .feature-card { border-radius: 10px; transition: transform 0.3s; cursor: pointer; }
        .feature-card:hover { transform: translateY(-5px); box-shadow: 0 5px 20px rgba(0,0,0,0.15); }
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
                        <a class="nav-link" href="${pageContext.request.contextPath}/profile">个人中心</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-danger" href="${pageContext.request.contextPath}/logout">退出登录</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <!-- 欢迎卡片 -->
        <div class="card welcome-card mb-4">
            <div class="welcome-header">
                <h2>欢迎回来，<%= sessionUser.getRealName() %>！</h2>
                <p class="mb-0">大学生海报设计竞赛系统 - 一站式竞赛管理平台</p>
            </div>
            <div class="card-body">
                <div class="row text-center">
                    <div class="col-md-4">
                        <h5>用户名</h5>
                        <p class="text-muted">@<%= sessionUser.getUsername() %></p>
                    </div>
                    <div class="col-md-4">
                        <h5>邮箱</h5>
                        <p class="text-muted"><%= sessionUser.getEmail() != null ? sessionUser.getEmail() : "未设置" %></p>
                    </div>
                    <div class="col-md-4">
                        <h5>角色</h5>
                        <p class="text-muted">
                            <% if (userRoles != null) {
                                for (int i = 0; i < userRoles.size(); i++) {
                                    %><span class="badge bg-primary"><%= userRoles.get(i).getRoleName() %></span><%
                                    if (i < userRoles.size() - 1) { %> <% }
                                }
                            } else { %>未分配<% } %>
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 功能入口 -->
        <div class="row">
            <div class="col-md-4 mb-3">
                <div class="card feature-card p-4 text-center">
                    <h5>查看竞赛</h5>
                    <p class="text-muted">浏览当前所有竞赛活动</p>
                </div>
            </div>
            <div class="col-md-4 mb-3">
                <div class="card feature-card p-4 text-center">
                    <h5>队伍管理</h5>
                    <p class="text-muted">创建队伍或管理我的队伍</p>
                </div>
            </div>
            <div class="col-md-4 mb-3">
                <div class="card feature-card p-4 text-center">
                    <h5>作品管理</h5>
                    <p class="text-muted">提交和管理参赛作品</p>
                </div>
            </div>
            <div class="col-md-4 mb-3">
                <div class="card feature-card p-4 text-center">
                    <h5>评分查看</h5>
                    <p class="text-muted">查看评委评分和获奖情况</p>
                </div>
            </div>
            <div class="col-md-4 mb-3">
                <div class="card feature-card p-4 text-center">
                    <h5>新闻公告</h5>
                    <p class="text-muted">查看最新竞赛动态和公告</p>
                </div>
            </div>
            <div class="col-md-4 mb-3">
                <div class="card feature-card p-4 text-center" onclick="location.href='${pageContext.request.contextPath}/profile'">
                    <h5>个人中心</h5>
                    <p class="text-muted">管理个人信息和密码</p>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
