<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    @SuppressWarnings("unchecked")
    List<Competition> competitions = (List<Competition>) request.getAttribute("competitions");

    // 管理员权限检查
    User sessionUser = (User) session.getAttribute("user");
    boolean isAdmin = false;
    if (sessionUser != null) {
        @SuppressWarnings("unchecked")
        List<Role> roles = (List<Role>) session.getAttribute("roles");
        if (roles != null) {
            for (Role r : roles) {
                if ("管理员".equals(r.getRoleName())) { isAdmin = true; break; }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>竞赛列表 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f5f5f5; }
        .competition-card {
            transition: transform 0.3s;
            cursor: pointer;
            border-radius: 10px;
        }
        .competition-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        .status-badge { font-size: 14px; }
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
                    <% if (sessionUser != null) { %>
                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/team?action=myTeams">我的队伍</a></li>
                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/work?action=myWorks">我的作品</a></li>
                        <% if (isAdmin) { %>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle active" href="#" role="button" data-bs-toggle="dropdown">管理中心</a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/competition?action=list">竞赛管理</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/award?action=manage">获奖管理</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/news?action=manage">新闻管理</a></li>
                            </ul>
                        </li>
                        <% } %>
                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/news?action=list">新闻公告</a></li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown"><%= sessionUser.getRealName() %></a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">个人中心</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">退出登录</a></li>
                            </ul>
                        </li>
                    <% } else { %>
                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/news?action=list">新闻公告</a></li>
                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/login">登录</a></li>
                        <li class="nav-item"><a class="nav-link btn btn-primary text-white ms-2" href="${pageContext.request.contextPath}/register">注册</a></li>
                    <% } %>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>竞赛列表</h2>
            <% if (isAdmin) { %>
            <a href="${pageContext.request.contextPath}/competition?action=add" class="btn btn-primary">
                发布竞赛
            </a>
            <% } %>
        </div>

        <% if (competitions != null && !competitions.isEmpty()) { %>
            <div class="row">
                <% for (Competition comp : competitions) { %>
                    <div class="col-md-6 mb-3">
                        <div class="card competition-card" onclick="window.location.href='${pageContext.request.contextPath}/competition?action=detail&id=<%= comp.getCompetitionId() %>'">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <h5 class="card-title mb-0"><%= comp.getName() %></h5>
                                    <span class="badge status-badge <%= comp.getStatus() == 1 ? "bg-success" : comp.getStatus() == 2 ? "bg-primary" : "bg-secondary" %>">
                                        <%= comp.getStatus() == 1 ? "报名中" : comp.getStatus() == 2 ? "进行中" : "已结束" %>
                                    </span>
                                </div>
                                <p class="text-muted mb-2">年度：<%= comp.getYear() %>年</p>
                                <% if (comp.getTheme() != null) { %>
                                    <p class="text-muted mb-2">主题：<%= comp.getTheme() %></p>
                                <% } %>
                                <p class="card-text text-truncate"><%= comp.getDescription() != null ? comp.getDescription() : "暂无描述" %></p>
                                <small class="text-muted">
                                    截止时间：<%= comp.getSubmitDeadline() != null ? comp.getSubmitDeadline().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "未设置" %>
                                </small>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="alert alert-info text-center">
                暂无竞赛信息，<a href="${pageContext.request.contextPath}/competition?action=add">立即发布</a>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
