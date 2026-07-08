<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Role> userRoles = (List<Role>) session.getAttribute("roles");
    boolean isAdmin = false;
    if (userRoles != null) {
        for (Role role : userRoles) {
            if ("管理员".equals(role.getRoleName())) isAdmin = true;
        }
    }

    @SuppressWarnings("unchecked")
    List<Certificate> certificates = (List<Certificate>) request.getAttribute("certificates");
    @SuppressWarnings("unchecked")
    Map<Integer, Award> awardMap = (Map<Integer, Award>) request.getAttribute("awardMap");
    @SuppressWarnings("unchecked")
    Map<Integer, Work> workMap = (Map<Integer, Work>) request.getAttribute("workMap");
    @SuppressWarnings("unchecked")
    Map<Integer, String> teamNameMap = (Map<Integer, String>) request.getAttribute("teamNameMap");
    @SuppressWarnings("unchecked")
    Map<Integer, String> competitionNameMap = (Map<Integer, String>) request.getAttribute("competitionNameMap");

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的奖状 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #6C5CE7; --primary-light: #A29BFE; --accent: #FD79A8;
            --dark: #2D3436; --gray: #636E72; --gold: #D4A843;
            --card-shadow: 0 2px 16px rgba(108, 92, 231, 0.06);
        }
        body {
            background: linear-gradient(135deg, #F8F9FA 0%, #E8ECF1 100%);
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
        }
        .navbar { background: var(--dark) !important; box-shadow: 0 2px 12px rgba(0,0,0,0.15); }
        .navbar-brand { font-weight: 700; }
        .navbar-brand i { color: var(--primary-light); margin-right: 6px; }
        .nav-link { font-size: 0.9rem; }
        .nav-link:hover { color: var(--primary-light) !important; }

        .page-header {
            background: linear-gradient(135deg, #D4A843 0%, #F0D78C 100%);
            border-radius: 20px; padding: 2.5rem 2rem; margin: 2rem 0; color: #5D3A1A; text-align: center;
        }
        .page-header h2 { font-weight: 700; margin: 0; }
        .page-header p { opacity: 0.8; margin: 0.5rem 0 0; }

        .cert-card {
            background: white; border-radius: 16px; padding: 1.8rem;
            margin-bottom: 1rem; box-shadow: var(--card-shadow);
            border-left: 4px solid var(--gold);
            transition: transform 0.2s;
        }
        .cert-card:hover { transform: translateY(-2px); box-shadow: 0 4px 20px rgba(108, 92, 231, 0.12); }

        .empty-state { text-align: center; padding: 4rem 2rem; color: var(--gray); }
        .empty-state i { font-size: 4rem; margin-bottom: 1rem; opacity: 0.4; }
    </style>
</head>
<body>

<!-- 导航栏 -->
<nav class="navbar navbar-expand-lg navbar-dark sticky-top">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/index">
            <i class="fas fa-palette"></i>海报竞赛系统
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/index"><i class="fas fa-home"></i> 首页</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/competition?action=list"><i class="fas fa-trophy"></i> 竞赛大厅</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/team?action=myTeams"><i class="fas fa-users"></i> 我的队伍</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/news?action=list"><i class="fas fa-newspaper"></i> 新闻公告</a></li>
                <% if (isAdmin) { %>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown"><i class="fas fa-crown"></i> 管理</a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/competition?action=add"><i class="fas fa-plus-circle"></i> 发布竞赛</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/award?action=manage"><i class="fas fa-medal"></i> 获奖管理</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/news?action=manage"><i class="fas fa-newspaper"></i> 新闻管理</a></li>
                    </ul>
                </li>
                <% } %>
            </ul>
            <ul class="navbar-nav">
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle"></i> <%= sessionUser.getUsername() %>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile"><i class="fas fa-cog"></i> 个人中心</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/certificate?action=myCertificates"><i class="fas fa-certificate"></i> 我的奖状</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> 退出登录</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <h2><i class="fas fa-certificate"></i> 我的奖状</h2>
        <p>查看您所在队伍获得的所有荣誉</p>
    </div>

    <% if (certificates != null && !certificates.isEmpty()) { %>
    <div class="row">
        <% for (Certificate cert : certificates) {
            Award award = awardMap != null ? awardMap.get(cert.getCertificateId()) : null;
            Work work = workMap != null ? workMap.get(cert.getCertificateId()) : null;
            String teamName = teamNameMap != null ? teamNameMap.get(cert.getCertificateId()) : "未知队伍";
            String compName = competitionNameMap != null ? competitionNameMap.get(cert.getCertificateId()) : "未知竞赛";
        %>
        <div class="col-md-6 col-lg-4">
            <div class="cert-card">
                <div class="d-flex align-items-center mb-3">
                    <div style="width:50px;height:50px;border-radius:50%;background:linear-gradient(135deg,#FFD700,#FFA500);
                                display:flex;align-items:center;justify-content:center;color:white;font-size:1.5rem;flex-shrink:0;">
                        <i class="fas fa-trophy"></i>
                    </div>
                    <div class="ms-3">
                        <div class="fw-bold">
                            <%= award != null ? award.getAwardLevel() : "获奖" %>
                        </div>
                        <small class="text-muted"><%= compName %></small>
                    </div>
                </div>
                <div class="mb-2">
                    <strong><%= work != null ? work.getTitle() : "作品" %></strong>
                </div>
                <small class="text-muted">
                    <i class="fas fa-users"></i> <%= teamName %> &nbsp;
                    <i class="fas fa-star"></i> <%= award != null ? String.format("%.1f", award.getFinalScore()) : "0.0" %> 分
                </small>
                <div class="mt-2 text-muted" style="font-size:0.85rem;">
                    <i class="fas fa-barcode"></i> <%= cert.getCertificateNo() %>
                </div>
                <a href="${pageContext.request.contextPath}/certificate?action=view&awardId=<%= cert.getAwardId() %>"
                   class="btn btn-outline-warning btn-sm w-100 mt-3" target="_blank">
                    <i class="fas fa-certificate"></i> 查看奖状
                </a>
            </div>
        </div>
        <% } %>
    </div>
    <% } else { %>
    <div class="empty-state">
        <i class="fas fa-certificate"></i>
        <h5>暂无奖状</h5>
        <p class="text-muted">您的队伍暂未获得奖状，继续加油！</p>
        <a href="${pageContext.request.contextPath}/competition?action=list" class="btn btn-primary mt-3">
            <i class="fas fa-trophy"></i> 查看竞赛
        </a>
    </div>
    <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
