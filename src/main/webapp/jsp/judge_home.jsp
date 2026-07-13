<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.model.Score" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Work" %>
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

    private int stat(Map<String, Integer> stats, String key) {
        if (stats == null || stats.get(key) == null) return 0;
        return stats.get(key);
    }

    private String displayName(User user) {
        if (user == null) return "评委";
        return textOr(user.getRealName(), textOr(user.getUsername(), "评委"));
    }
%>
<%
    User currentUser = (User) request.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("user");
    @SuppressWarnings("unchecked")
    List<Work> pendingWorks = (List<Work>) request.getAttribute("pendingWorks");
    @SuppressWarnings("unchecked")
    List<Score> myScores = (List<Score>) request.getAttribute("myScores");
    @SuppressWarnings("unchecked")
    Map<String, Integer> globalStats = (Map<String, Integer>) request.getAttribute("globalStats");
    if (pendingWorks == null) pendingWorks = Collections.emptyList();
    if (myScores == null) myScores = Collections.emptyList();
    int pendingCount = pendingWorks.size();
    int scoredCount = myScores.size();
    int activeCount = stat(globalStats, "activeCount");
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>评委工作台 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/home.css?v=20260713" rel="stylesheet">
    <%@ include file="includes/app-shell-assets.jspf" %>
    <link href="${pageContext.request.contextPath}/css/role-home.css?v=20260713" rel="stylesheet">
</head>
<body class="home-page role-home judge-home">
<%
    request.setAttribute("activeNav", "home");
%>
<%@ include file="includes/navbar.jspf" %>

<main class="role-home-main">
    <section class="role-hero role-hero-judge" style="--role-hero-image: url('${pageContext.request.contextPath}/images/home/hero-2.png')" aria-labelledby="judge-home-title">
        <div class="role-hero-content">
            <p class="role-kicker">JUDGE STUDIO / 评审工作台</p>
            <h1 id="judge-home-title">把好作品，交给<br><em>专业判断</em></h1>
            <p class="role-hero-description">欢迎回来，<%= html(displayName(currentUser)) %>。从作品细节出发完成评分和评语，让每一份创意都获得清晰、可靠的反馈。</p>
            <div class="role-hero-actions">
                <a class="role-btn role-btn-primary" href="<%= contextPath %>/score?action=list">进入评分工作台 <i class="fa-solid fa-arrow-right"></i></a>
                <a class="role-btn role-btn-secondary" href="<%= contextPath %>/score?action=myScores">查看我的评分</a>
            </div>
        </div>
        <div class="role-hero-note">
            <strong><%= pendingCount %> 件作品等待你的判断</strong>
            <small>优先处理已提交作品，评分后即可继续查看评语与记录。</small>
        </div>
    </section>

    <section class="role-section" aria-labelledby="judge-stats-title">
        <div class="role-section-heading">
            <div>
                <p class="role-section-kicker">YOUR REVIEW RHYTHM</p>
                <h2 id="judge-stats-title">今天，从一件作品开始</h2>
            </div>
            <a class="role-section-link" href="<%= contextPath %>/news?action=list">查看赛事公告 <i class="fa-solid fa-arrow-right"></i></a>
        </div>
        <div class="role-stat-grid">
            <a class="role-stat-card" href="<%= contextPath %>/score?action=list">
                <span class="role-stat-number"><%= pendingCount %></span>
                <span class="role-stat-label">待评作品</span>
                <span class="role-stat-note">进入评分工作台继续处理</span>
            </a>
            <a class="role-stat-card" href="<%= contextPath %>/score?action=myScores">
                <span class="role-stat-number"><%= scoredCount %></span>
                <span class="role-stat-label">我的评分</span>
                <span class="role-stat-note">查看已提交的评分记录</span>
            </a>
            <a class="role-stat-card" href="<%= contextPath %>/competition?action=list">
                <span class="role-stat-number"><%= activeCount %></span>
                <span class="role-stat-label">进行中竞赛</span>
                <span class="role-stat-note">按竞赛进入作品评审</span>
            </a>
        </div>
    </section>

    <section class="role-section" aria-labelledby="judge-queue-title">
        <div class="role-section-heading">
            <div>
                <p class="role-section-kicker">REVIEW QUEUE</p>
                <h2 id="judge-queue-title">待评作品</h2>
            </div>
            <a class="role-section-link" href="<%= contextPath %>/score?action=list">打开完整队列 <i class="fa-solid fa-arrow-right"></i></a>
        </div>
        <div class="role-workspace-grid">
            <div class="role-panel">
                <div class="role-panel-head">
                    <div>
                        <h3><i class="fa-solid fa-layer-group me-2"></i>最新提交</h3>
                        <small>按提交状态筛选，优先完成未评分作品</small>
                    </div>
                    <span class="role-count-pill"><%= pendingCount %> 件</span>
                </div>
                <% if (pendingWorks.isEmpty()) { %>
                    <div class="role-empty">
                        <strong>当前没有待评作品</strong>
                        <p>新的作品提交后会出现在这里。</p>
                        <a class="role-btn role-btn-secondary" href="<%= contextPath %>/score?action=list">查看评分工作台</a>
                    </div>
                <% } else { %>
                    <div class="role-list">
                        <% int shown = Math.min(6, pendingWorks.size());
                           for (int i = 0; i < shown; i++) {
                               Work work = pendingWorks.get(i);
                               String title = textOr(work.getTitle(), "未命名作品");
                        %>
                            <a class="role-list-item" href="<%= contextPath %>/score?action=input&workId=<%= work.getWorkId() %>">
                                <span class="role-list-index"><%= String.format("%02d", i + 1) %></span>
                                <span class="role-list-copy">
                                    <strong><%= html(title) %></strong>
                                    <small>作品编号 #<%= work.getWorkId() %> · 等待评分</small>
                                </span>
                                <span class="role-list-action"><i class="fa-solid fa-arrow-up-right-from-square"></i></span>
                            </a>
                        <% } %>
                    </div>
                <% } %>
            </div>

            <div class="role-panel">
                <div class="role-panel-head">
                    <div>
                        <h3><i class="fa-solid fa-compass me-2"></i>评审入口</h3>
                        <small>快速回到你的工作节奏</small>
                    </div>
                </div>
                <div class="role-action-grid">
                    <a class="role-action-card" href="<%= contextPath %>/score?action=myScores">
                        <span class="role-action-icon"><i class="fa-solid fa-check-double"></i></span>
                        <span><strong>我的评分记录</strong><small>回顾已经提交的判断</small></span>
                        <span class="role-action-arrow"><i class="fa-solid fa-chevron-right"></i></span>
                    </a>
                    <a class="role-action-card" href="<%= contextPath %>/award?action=list">
                        <span class="role-action-icon"><i class="fa-solid fa-award"></i></span>
                        <span><strong>往届获奖</strong><small>浏览优秀作品与结果</small></span>
                        <span class="role-action-arrow"><i class="fa-solid fa-chevron-right"></i></span>
                    </a>
                    <a class="role-action-card" href="<%= contextPath %>/news?action=list">
                        <span class="role-action-icon"><i class="fa-regular fa-newspaper"></i></span>
                        <span><strong>赛事公告</strong><small>查看最新评审安排</small></span>
                        <span class="role-action-arrow"><i class="fa-solid fa-chevron-right"></i></span>
                    </a>
                </div>
            </div>
        </div>
    </section>
</main>

<footer class="role-home-footer">大学生海报设计竞赛系统 · 让每一份创意获得认真回应</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
