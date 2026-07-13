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
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-catalog app-page-news-list">
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
