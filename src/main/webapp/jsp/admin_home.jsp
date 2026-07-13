<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%!
    private String html(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String textOr(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value;
    }

    private String brief(String value, int maxLength) {
        String text = textOr(value, "主办方暂未填写详细介绍。");
        return text.length() <= maxLength ? text : text.substring(0, maxLength) + "...";
    }

    private int stat(Map<String, Integer> stats, String key) {
        if (stats == null || stats.get(key) == null) return 0;
        return stats.get(key);
    }

    private String statusText(Integer status) {
        if (Integer.valueOf(1).equals(status)) return "报名中";
        if (Integer.valueOf(2).equals(status)) return "进行中";
        if (Integer.valueOf(3).equals(status)) return "已结束";
        return "已取消";
    }

    private String statusClass(Integer status) {
        if (Integer.valueOf(1).equals(status)) return "status-open";
        if (Integer.valueOf(2).equals(status)) return "status-live";
        if (Integer.valueOf(3).equals(status)) return "status-ended";
        return "status-closed";
    }

    private String displayName(User user) {
        if (user == null) return "管理员";
        return textOr(user.getRealName(), textOr(user.getUsername(), "管理员"));
    }
%>
<%
    User currentUser = (User) request.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");
    @SuppressWarnings("unchecked")
    List<Competition> competitions = (List<Competition>) request.getAttribute("competitions");
    @SuppressWarnings("unchecked")
    Map<String, Integer> globalStats = (Map<String, Integer>) request.getAttribute("globalStats");
    if (competitions == null) competitions = Collections.emptyList();
    int compCount = stat(globalStats, "compCount");
    int teamCount = stat(globalStats, "teamCount");
    int workCount = stat(globalStats, "workCount");
    int activeCount = stat(globalStats, "activeCount");
    Object userCountValue = request.getAttribute("userCount");
    int userCount = userCountValue instanceof Number ? ((Number) userCountValue).intValue() : 0;
    String contextPath = request.getContextPath();
    String assetVersion = "20260713-admin1";
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy.MM.dd");
    String[] fallbackCovers = {
            contextPath + "/images/home/poster-1.png",
            contextPath + "/images/home/poster-2.png",
            contextPath + "/images/home/poster-3.png",
            contextPath + "/images/home/poster-4.png",
            contextPath + "/images/home/poster-5.png",
            contextPath + "/images/home/poster-6.png"
    };
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理员工作台 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/home.css?v=<%= assetVersion %>" rel="stylesheet">
    <%@ include file="includes/app-shell-assets.jspf" %>
    <link href="${pageContext.request.contextPath}/css/role-home.css?v=<%= assetVersion %>" rel="stylesheet">
</head>
<body class="home-page role-home admin-home">
<%
    request.setAttribute("activeNav", "home");
%>
<%@ include file="includes/navbar.jspf" %>

<main class="role-home-main">
    <section class="role-hero role-hero-admin" style="--role-hero-image: url('${pageContext.request.contextPath}/images/home/hero-1.png')" aria-labelledby="admin-home-title">
        <div class="role-hero-content">
            <p class="role-kicker">COMPETITION CONTROL / 赛事运营</p>
            <h1 id="admin-home-title">让每一场竞赛，<br><em>顺利发生</em></h1>
            <p class="role-hero-description">欢迎回来，<%= html(displayName(currentUser)) %>。从赛题发布到获奖公示，在一个清晰的运营台里掌握赛事节奏。</p>
            <div class="role-hero-actions">
                <a class="role-btn role-btn-primary" href="<%= contextPath %>/competition?action=add">发布新竞赛 <i class="fa-solid fa-plus"></i></a>
                <a class="role-btn role-btn-secondary" href="<%= contextPath %>/competition?action=list">进入竞赛管理</a>
            </div>
        </div>
        <div class="role-hero-note">
            <strong><%= activeCount %> 场竞赛正在进行</strong>
            <small>继续维护赛题状态、作品节奏和结果发布，让参赛者始终知道下一步。</small>
        </div>
    </section>

    <section class="role-section" aria-labelledby="admin-stats-title">
        <div class="role-section-heading">
            <div>
                <p class="role-section-kicker">OPERATION PULSE</p>
                <h2 id="admin-stats-title">赛事全局，一眼掌握</h2>
            </div>
            <a class="role-section-link" href="<%= contextPath %>/news?action=manage">管理赛事公告 <i class="fa-solid fa-arrow-right"></i></a>
        </div>
        <div class="role-stat-grid">
            <a class="role-stat-card" href="<%= contextPath %>/competition?action=list">
                <span class="role-stat-number"><%= compCount %></span>
                <span class="role-stat-label">竞赛总数</span>
                <span class="role-stat-note">查看所有赛题与状态</span>
            </a>
            <a class="role-stat-card" href="<%= contextPath %>/team?action=list">
                <span class="role-stat-number"><%= teamCount %></span>
                <span class="role-stat-label">参赛队伍</span>
                <span class="role-stat-note">掌握当前报名规模</span>
            </a>
            <a class="role-stat-card" href="<%= contextPath %>/work?action=list">
                <span class="role-stat-number"><%= workCount %></span>
                <span class="role-stat-label">参赛作品</span>
                <span class="role-stat-note">进入作品与评审流程</span>
            </a>
            <a class="role-stat-card" href="<%= contextPath %>/admin/users">
                <span class="role-stat-number"><%= userCount %></span>
                <span class="role-stat-label">注册用户</span>
                <span class="role-stat-note">管理账号与角色权限</span>
            </a>
        </div>
    </section>

    <section class="role-section" aria-labelledby="admin-actions-title">
        <div class="role-section-heading">
            <div>
                <p class="role-section-kicker">CONTROL ROOM</p>
                <h2 id="admin-actions-title">运营入口</h2>
            </div>
            <a class="role-section-link" href="<%= contextPath %>/certificate?action=list">查看证书管理 <i class="fa-solid fa-arrow-right"></i></a>
        </div>
        <div class="role-workspace-grid">
            <div class="role-panel">
                <div class="role-panel-head">
                    <div>
                        <h3><i class="fa-solid fa-sliders me-2"></i>常用管理</h3>
                        <small>把高频运营动作放在顺手的位置</small>
                    </div>
                </div>
                <div class="role-action-grid">
                    <a class="role-action-card" href="<%= contextPath %>/competition?action=add">
                        <span class="role-action-icon"><i class="fa-solid fa-bullhorn"></i></span>
                        <span><strong>发布竞赛</strong><small>创建赛题、设置报名与提交窗口</small></span>
                        <span class="role-action-arrow"><i class="fa-solid fa-chevron-right"></i></span>
                    </a>
                    <a class="role-action-card" href="<%= contextPath %>/admin/users">
                        <span class="role-action-icon"><i class="fa-solid fa-users-gear"></i></span>
                        <span><strong>用户管理</strong><small>查看账号、状态和角色配置</small></span>
                        <span class="role-action-arrow"><i class="fa-solid fa-chevron-right"></i></span>
                    </a>
                    <a class="role-action-card" href="<%= contextPath %>/award?action=manage">
                        <span class="role-action-icon"><i class="fa-solid fa-medal"></i></span>
                        <span><strong>获奖管理</strong><small>设置奖项并推进结果发布</small></span>
                        <span class="role-action-arrow"><i class="fa-solid fa-chevron-right"></i></span>
                    </a>
                    <a class="role-action-card" href="<%= contextPath %>/news?action=manage">
                        <span class="role-action-icon"><i class="fa-regular fa-newspaper"></i></span>
                        <span><strong>新闻管理</strong><small>维护公告与赛事动态</small></span>
                        <span class="role-action-arrow"><i class="fa-solid fa-chevron-right"></i></span>
                    </a>
                </div>
            </div>

            <div class="role-panel">
                <div class="role-panel-head">
                    <div>
                        <h3><i class="fa-solid fa-compass me-2"></i>快速跳转</h3>
                        <small>从这里继续你的工作</small>
                    </div>
                </div>
                <div class="role-action-grid">
                    <a class="role-action-card" href="<%= contextPath %>/competition?action=list">
                        <span class="role-action-icon"><i class="fa-solid fa-rectangle-list"></i></span>
                        <span><strong>竞赛列表</strong><small>查看所有赛题状态</small></span>
                        <span class="role-action-arrow"><i class="fa-solid fa-chevron-right"></i></span>
                    </a>
                    <a class="role-action-card" href="<%= contextPath %>/certificate?action=list">
                        <span class="role-action-icon"><i class="fa-solid fa-certificate"></i></span>
                        <span><strong>证书管理</strong><small>查看电子奖状记录</small></span>
                        <span class="role-action-arrow"><i class="fa-solid fa-chevron-right"></i></span>
                    </a>
                    <a class="role-action-card" href="<%= contextPath %>/news?action=list">
                        <span class="role-action-icon"><i class="fa-solid fa-rss"></i></span>
                        <span><strong>公告中心</strong><small>检查对外发布内容</small></span>
                        <span class="role-action-arrow"><i class="fa-solid fa-chevron-right"></i></span>
                    </a>
                </div>
            </div>
        </div>
    </section>

    <section class="role-section" aria-labelledby="admin-competitions-title">
        <div class="role-section-heading">
            <div>
                <p class="role-section-kicker">EVENTS IN VIEW</p>
                <h2 id="admin-competitions-title">最近竞赛</h2>
            </div>
            <a class="role-section-link" href="<%= contextPath %>/competition?action=list">查看全部竞赛 <i class="fa-solid fa-arrow-right"></i></a>
        </div>
        <% if (competitions.isEmpty()) { %>
            <div class="role-empty">
                <strong>还没有竞赛内容</strong>
                <p>发布第一个竞赛后，赛题封面和状态会显示在这里。</p>
                <a class="role-btn role-btn-secondary" href="<%= contextPath %>/competition?action=add">发布第一个竞赛</a>
            </div>
        <% } else { %>
            <div class="role-competition-grid">
                <% int shown = Math.min(6, competitions.size());
                   for (int i = 0; i < shown; i++) {
                       Competition competition = competitions.get(i);
                       String cover = contextPath + "/uploads/competition_" + competition.getCompetitionId() + "/cover.jpg";
                       String fallback = fallbackCovers[i % fallbackCovers.length];
                       String deadline = competition.getSubmitDeadline() == null
                               ? "截止时间待定" : competition.getSubmitDeadline().format(dateFormatter);
                %>
                    <article class="role-competition-card">
                        <a class="role-competition-cover" href="<%= contextPath %>/competition?action=detail&id=<%= competition.getCompetitionId() %>">
                            <img src="<%= cover %>" alt="<%= html(textOr(competition.getName(), "竞赛封面")) %>" onerror="this.onerror=null;this.src='<%= fallback %>'">
                        </a>
                        <div class="role-competition-body">
                            <span class="role-status-pill <%= statusClass(competition.getStatus()) %>"><%= statusText(competition.getStatus()) %></span>
                            <h3><a href="<%= contextPath %>/competition?action=detail&id=<%= competition.getCompetitionId() %>"><%= html(textOr(competition.getName(), "未命名竞赛")) %></a></h3>
                            <p><%= html(brief(competition.getDescription(), 60)) %></p>
                            <div class="role-competition-meta">
                                <span><i class="fa-regular fa-calendar me-1"></i><%= html(deadline) %></span>
                                <a href="<%= contextPath %>/competition?action=edit&id=<%= competition.getCompetitionId() %>">编辑 <i class="fa-solid fa-arrow-right"></i></a>
                            </div>
                        </div>
                    </article>
                <% } %>
            </div>
        <% } %>
    </section>
</main>

<footer class="role-home-footer">大学生海报设计竞赛系统 · 让每一场竞赛顺利发生</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
