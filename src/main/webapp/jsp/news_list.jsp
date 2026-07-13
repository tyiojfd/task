<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.News" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
<%
    @SuppressWarnings("unchecked")
    List<News> newsList = (List<News>) request.getAttribute("newsList");
    User sessionUser = (User) session.getAttribute("user");
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    @SuppressWarnings("unchecked")
    List<Role> userRoles = (sessionUser != null) ? (List<Role>) session.getAttribute("roles") : null;
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
    <title>新闻公告 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #667eea;
            --secondary: #764ba2;
            --accent: #f093fb;
        }
        body { background: #f5f5f5; }
        .navbar-brand { font-weight: bold; }
        .page-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            border-radius: 15px;
            padding: 30px 40px;
            margin-bottom: 25px;
        }
        .news-card {
            border-radius: 12px;
            border: none;
            transition: all 0.3s ease;
            cursor: pointer;
            margin-bottom: 16px;
            background: white;
        }
        .news-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }
        .news-card .card-body { padding: 20px 24px; }
        .news-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .news-meta {
            font-size: 0.85rem;
            color: #999;
        }
        .news-meta i { margin-right: 4px; }
        .news-excerpt {
            color: #666;
            font-size: 0.9rem;
            margin-top: 8px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            color: #aaa;
        }
        .empty-state i { font-size: 4rem; margin-bottom: 20px; display: block; }
        .btn-publish {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            border: none;
            border-radius: 8px;
            padding: 8px 20px;
            transition: opacity 0.3s;
        }
        .btn-publish:hover { opacity: 0.9; color: white; }
    </style>
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body>
    <!-- 导航栏 -->
    <%
    request.setAttribute("activeNav", "news");
%>
<%@ include file="includes/navbar.jspf" %>

    <div class="container mt-4">
        <!-- 页面标题 -->
        <div class="page-header d-flex justify-content-between align-items-center">
            <div>
                <h3 class="mb-1"><i class="fas fa-newspaper me-2"></i>新闻公告</h3>
                <p class="mb-0 opacity-75">了解最新竞赛动态与通知</p>
            </div>
            <% if (isAdmin) { %>
                <a href="${pageContext.request.contextPath}/news?action=publish" class="btn btn-light">
                    <i class="fas fa-plus me-1"></i>发布新闻
                </a>
            <% } %>
        </div>

        <!-- 新闻列表 -->
        <% if (newsList != null && !newsList.isEmpty()) { %>
            <div class="row">
                <% for (News news : newsList) {
                    String excerpt = news.getContent();
                    if (excerpt != null && excerpt.length() > 150) {
                        excerpt = excerpt.substring(0, 150) + "...";
                    }
                %>
                    <div class="col-12">
                        <div class="card news-card" onclick="window.location.href='${pageContext.request.contextPath}/news?action=detail&id=<%= news.getNewsId() %>'">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div class="flex-grow-1">
                                        <h5 class="news-title"><%= HtmlEscaper.escape(news.getTitle()) %></h5>
                                        <div class="news-meta">
                                            <i class="far fa-clock"></i>
                                            <%= news.getPublishTime() != null ? news.getPublishTime().format(formatter) : "未知时间" %>
                                        </div>
                                        <p class="news-excerpt"><%= HtmlEscaper.escape(excerpt) %></p>
                                    </div>
                                    <i class="fas fa-chevron-right text-muted ms-3 mt-2"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <i class="far fa-newspaper"></i>
                <h5>暂无新闻公告</h5>
                <p>敬请期待最新动态</p>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
