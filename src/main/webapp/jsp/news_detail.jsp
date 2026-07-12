<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.News" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    News news = (News) request.getAttribute("news");
    User sessionUser = (User) session.getAttribute("user");
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    if (news == null) {
        response.sendRedirect(request.getContextPath() + "/news?action=list");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= news.getTitle() %> - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #667eea;
            --secondary: #764ba2;
        }
        body { background: #f5f5f5; }
        .navbar-brand { font-weight: bold; }
        .detail-container { max-width: 860px; margin: 0 auto; }
        .detail-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            border-radius: 15px 15px 0 0;
            padding: 40px;
        }
        .detail-body {
            background: white;
            border-radius: 0 0 15px 15px;
            padding: 40px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }
        .news-content {
            font-size: 1.05rem;
            line-height: 1.8;
            color: #444;
            white-space: pre-wrap;
            word-wrap: break-word;
        }
        .meta-bar {
            display: flex;
            gap: 20px;
            color: rgba(255,255,255,0.85);
            font-size: 0.9rem;
            margin-top: 10px;
        }
        .meta-bar i { margin-right: 5px; }
        .btn-back {
            border-radius: 8px;
            transition: all 0.3s;
        }
        .btn-back:hover { transform: translateX(-3px); }
        .action-bar { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <%
    request.setAttribute("activeNav", "news");
%>
<%@ include file="includes/navbar.jspf" %>

    <div class="container mt-4 detail-container">
        <!-- 返回按钮 -->
        <a href="${pageContext.request.contextPath}/news?action=list" class="btn btn-outline-secondary btn-back mb-3">
            <i class="fas fa-arrow-left me-1"></i>返回列表
        </a>

        <!-- 新闻详情卡片 -->
        <div class="detail-header">
            <h3><%= news.getTitle() %></h3>
            <div class="meta-bar">
                <span><i class="far fa-calendar-alt"></i><%= news.getPublishTime() != null ? news.getPublishTime().format(formatter) : "未知时间" %></span>
                <% if (news.getCompetitionId() != null) { %>
                    <span><i class="fas fa-trophy"></i>关联竞赛ID: <%= news.getCompetitionId() %></span>
                <% } %>
                <span>
                    <% if (news.getStatus() != null && news.getStatus() == 1) { %>
                        <span class="badge bg-success">已发布</span>
                    <% } else { %>
                        <span class="badge bg-secondary">已撤回</span>
                    <% } %>
                </span>
            </div>
        </div>
        <div class="detail-body">
            <div class="news-content"><%= news.getContent() != null ? news.getContent() : "暂无内容" %></div>

            <% if (sessionUser != null) { %>
                <div class="action-bar d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/news?action=edit&id=<%= news.getNewsId() %>" class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-edit me-1"></i>编辑
                    </a>
                    <a href="${pageContext.request.contextPath}/news?action=manage" class="btn btn-outline-secondary btn-sm">
                        <i class="fas fa-cog me-1"></i>管理
                    </a>
                </div>
            <% } %>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
