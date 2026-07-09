<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.util.FileUploadUtil" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    @SuppressWarnings("unchecked")
    List<Role> userRoles = (List<Role>) session.getAttribute("roles");
    boolean isAdmin = false, isJudge = false;
    if (userRoles != null) for (Role role : userRoles) {
        if ("管理员".equals(role.getRoleName())) isAdmin = true;
        if ("评委".equals(role.getRoleName())) isJudge = true;
    }
    Work work = (Work) request.getAttribute("work");
    Team team = (Team) request.getAttribute("team");
    Competition comp = (Competition) request.getAttribute("competition");
    Integer likeCount = (Integer) request.getAttribute("likeCount");
    Boolean liked = (Boolean) request.getAttribute("liked");
    Boolean isLeader = (Boolean) request.getAttribute("isLeader");
    if (work == null) { response.sendRedirect(request.getContextPath() + "/work?error=not_found"); return; }
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy\u5e74MM\u6708dd\u65e5 HH:mm");
    String imgUrl = (work.getImagePath() != null && !work.getImagePath().isEmpty()) ? request.getContextPath() + "/" + com.poster.util.FileUploadUtil.STORAGE_DIR + work.getImagePath() : "";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= work.getTitle() != null ? work.getTitle() : "作品详情" %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root { --primary: #6C5CE7; --dark: #2D3436; --gray: #636E72; }
        body { background: #f5f5f5; min-height: 100vh; }
        .navbar { background: var(--dark) !important; }
        .detail-card { background: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); overflow: hidden; }
        .detail-image { width: 100%; max-height: 500px; object-fit: contain; background: #F8F9FA; }
        .detail-body { padding: 2rem; }
        .detail-title { font-weight: 700; font-size: 1.5rem; margin-bottom: 1rem; }
        .detail-meta { font-size: 0.9rem; color: var(--gray); margin-bottom: 1.5rem; }
        .detail-meta i { width: 18px; color: var(--primary); margin-right: 6px; }
        .action-bar { padding: 1rem 2rem; background: #FAFBFC; border-top: 1px solid #eee; display: flex; gap: 0.75rem; flex-wrap: wrap; }
        .btn-action { padding: 0.5rem 1.2rem; border-radius: 10px; border: none; font-weight: 600; font-size: 0.9rem; text-decoration: none; display: inline-block; }
        .btn-like { background: #FFF0F0; color: #FF6B6B; }
        .btn-like.liked { background: #FF6B6B; color: white; }
        .btn-primary-custom { background: var(--primary); color: white; }
        .btn-danger-custom { background: #FF6B6B; color: white; }
        .btn-back { background: #F1F2F6; color: var(--gray); }
    </style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/index">🎨 海报竞赛系统</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/index">首页</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/competition?action=list">竞赛大厅</a></li>
                <% if (!isAdmin && !isJudge) { %>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/team?action=myTeams">我的队伍</a></li>
                <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/work">已提交的作品</a></li>
                <% } %>
                <% if (isAdmin) { %>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/competition?action=add">发布竞赛</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/users">用户管理</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/news?action=manage">新闻管理</a></li>
                <% } %>
                <% if (isJudge) { %>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/score?action=list">评分管理</a></li>
                <% } %>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown"><i class="fas fa-user-circle"></i> <%= sessionUser.getRealName() %></a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile"><i class="fas fa-user-edit me-2"></i>个人信息</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt me-2"></i>退出登录</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>
<div class="container py-4">
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/work" class="btn-action btn-back"><i class="fas fa-arrow-left me-1"></i>返回</a>
    </div>
    <div class="row">
        <div class="col-lg-7">
            <div class="detail-card mb-4">
                <img src="<%= imgUrl %>" alt="<%= work.getTitle() %>" class="detail-image" style="cursor:zoom-in" onclick="window.open(this.src, '_blank')">
            </div>
        </div>
        <div class="col-lg-5">
            <div class="detail-card">
                <div class="detail-body">
                    <h3 class="detail-title"><%= work.getTitle() != null ? work.getTitle() : "未命名" %></h3>
                    <div class="detail-meta">
                        <div><i class="fas fa-users"></i><strong>队伍：</strong><%= team != null ? team.getTeamName() : "未知" %></div>
                        <% if (comp != null) { %><div><i class="fas fa-flag"></i><strong>竞赛：</strong><%= comp.getName() %></div><% } %>
                        <% if (work.getSubmitTime() != null) { %><div><i class="fas fa-clock"></i><strong>提交：</strong><%= work.getSubmitTime().format(dtf) %></div><% } %>
                        <div><i class="fas fa-heart"></i><strong>点赞：</strong><%= likeCount != null ? likeCount : 0 %></div>
                    </div>
                    <% if (work.getDescription() != null && !work.getDescription().isEmpty()) { %>
                        <hr><h6 style="font-weight:700;">作品描述</h6>
                        <p style="white-space:pre-wrap;"><%= work.getDescription() %></p>
                    <% } %>
                </div>
                <div class="action-bar">
                    <form action="${pageContext.request.contextPath}/work" method="post" style="margin:0">
                        <input type="hidden" name="action" value="<%= liked != null && liked ? "unlike" : "like" %>">
                        <input type="hidden" name="workId" value="<%= work.getWorkId() %>">
                        <button type="submit" class="btn-action btn-like <%= liked != null && liked ? "liked" : "" %>"><i class="fas fa-thumbs-up"></i> <%= liked != null && liked ? "已赞" : "点赞" %> <span class="like-count"><%= likeCount != null ? likeCount : 0 %></span></button>
                    </form>
                    <% if (isLeader != null && isLeader) { %>
                        <a href="${pageContext.request.contextPath}/work?action=edit&id=<%= work.getWorkId() %>" class="btn-action btn-primary-custom"><i class="fas fa-edit me-1"></i>编辑</a>
                        <a href="${pageContext.request.contextPath}/work?action=delete&id=<%= work.getWorkId() %>" class="btn-action btn-danger-custom" onclick="return confirm('确定删除？')"><i class="fas fa-trash me-1"></i>删除</a>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>