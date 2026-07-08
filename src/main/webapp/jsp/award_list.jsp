<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Award" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User sessionUser = (User) session.getAttribute("user");

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

    @SuppressWarnings("unchecked")
    List<Award> awards = (List<Award>) request.getAttribute("awards");
    Competition competition = (Competition) request.getAttribute("competition");
    @SuppressWarnings("unchecked")
    Map<Integer, Work> workMap = (Map<Integer, Work>) request.getAttribute("workMap");
    @SuppressWarnings("unchecked")
    Map<Integer, String> teamNameMap = (Map<Integer, String>) request.getAttribute("teamNameMap");
    @SuppressWarnings("unchecked")
    Map<Integer, Double> avgScoreMap = (Map<Integer, Double>) request.getAttribute("avgScoreMap");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>获奖名单 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #6C5CE7; --primary-light: #A29BFE; --accent: #FD79A8;
            --dark: #2D3436; --gray: #636E72; --gold: #FFD700; --silver: #C0C0C0; --bronze: #CD7F32;
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
        .nav-link { font-size: 0.9rem; transition: color 0.2s; }
        .nav-link:hover { color: var(--primary-light) !important; }

        .page-header {
            background: linear-gradient(135deg, #6C5CE7 0%, #A29BFE 100%);
            border-radius: 20px;
            padding: 2.5rem 2rem;
            margin: 2rem 0;
            color: white;
            text-align: center;
        }
        .page-header h2 { font-weight: 700; margin: 0; }
        .page-header p { opacity: 0.9; margin: 0.5rem 0 0; }

        .award-card {
            background: white;
            border-radius: 20px;
            padding: 0;
            margin-bottom: 1.5rem;
            box-shadow: var(--card-shadow);
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .award-card:hover { transform: translateY(-4px); box-shadow: 0 8px 30px rgba(108, 92, 231, 0.15); }

        .award-card.first  { border-top: 4px solid #FFD700; }
        .award-card.second { border-top: 4px solid #C0C0C0; }
        .award-card.third  { border-top: 4px solid #CD7F32; }

        .award-rank {
            width: 60px; height: 60px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem; font-weight: 700; color: white;
        }
        .rank-1 { background: linear-gradient(135deg, #FFD700, #FFA500); }
        .rank-2 { background: linear-gradient(135deg, #C0C0C0, #909090); }
        .rank-3 { background: linear-gradient(135deg, #CD7F32, #A0522D); }

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
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/index"><i class="fas fa-home"></i> 首页</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/competition?action=list"><i class="fas fa-trophy"></i> 竞赛大厅</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/news?action=list"><i class="fas fa-newspaper"></i> 新闻公告</a></li>
                <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/award?action=list"><i class="fas fa-medal"></i> 获奖名单</a></li>
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
                <% if (sessionUser != null) { %>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle"></i> <%= sessionUser.getUsername() %>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile"><i class="fas fa-cog"></i> 个人中心</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> 退出登录</a></li>
                    </ul>
                </li>
                <% } else { %>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/login"><i class="fas fa-sign-in-alt"></i> 登录</a></li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <h2><i class="fas fa-medal"></i> 获奖名单</h2>
        <p><%= competition != null ? competition.getName() : "查看各竞赛的获奖作品" %></p>
    </div>

    <% if (awards != null && !awards.isEmpty()) { %>
    <div class="row">
        <% int rank = 0;
           for (Award award : awards) {
               rank++;
               Work work = workMap != null ? workMap.get(award.getWorkId()) : null;
               String teamName = teamNameMap != null ? teamNameMap.get(award.getWorkId()) : "未知队伍";
               Double avg = avgScoreMap != null ? avgScoreMap.get(award.getWorkId()) : 0.0;

               String cardClass = "";
               String rankClass = "";
               if ("一等奖".equals(award.getAwardLevel())) { cardClass = "first"; rankClass = "rank-1"; }
               else if ("二等奖".equals(award.getAwardLevel())) { cardClass = "second"; rankClass = "rank-2"; }
               else { cardClass = "third"; rankClass = "rank-3"; }
        %>
        <div class="col-md-6 col-lg-4">
            <div class="award-card <%= cardClass %>">
                <div class="p-4">
                    <div class="d-flex align-items-center mb-3">
                        <div class="award-rank <%= rankClass %> me-3"><%= rank %></div>
                        <div>
                            <div class="fw-bold fs-5"><%= work != null ? work.getTitle() : "作品#" + award.getWorkId() %></div>
                            <small class="text-muted"><i class="fas fa-users"></i> <%= teamName %></small>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="badge <%= "一等奖".equals(award.getAwardLevel()) ? "bg-warning text-dark" : ("二等奖".equals(award.getAwardLevel()) ? "bg-secondary" : "bg-danger") %> fs-6">
                            <i class="fas fa-trophy"></i> <%= award.getAwardLevel() %>
                        </span>
                        <span class="text-muted"><%= String.format("%.1f", award.getFinalScore()) %> 分</span>
                    </div>
                    <div class="mt-3">
                        <a href="${pageContext.request.contextPath}/certificate?action=view&awardId=<%= award.getAwardId() %>"
                           class="btn btn-outline-primary btn-sm w-100" target="_blank">
                            <i class="fas fa-certificate"></i> 查看奖状
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } else { %>
    <div class="empty-state">
        <i class="fas fa-medal"></i>
        <h5>暂无获奖信息</h5>
        <p class="text-muted">获奖名单将在竞赛评审结束后公布，敬请期待！</p>
    </div>
    <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
