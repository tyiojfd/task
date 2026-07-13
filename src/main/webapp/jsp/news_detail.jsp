<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.News" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="java.util.List" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    News news = (News) request.getAttribute("news");
    User sessionUser = (User) session.getAttribute("user");
    @SuppressWarnings("unchecked")
    List<Role> sessionRoles = (List<Role>) session.getAttribute("roles");
    boolean isAdmin = false;
    if (sessionRoles != null) {
        for (Role role : sessionRoles) {
            if ("管理员".equals(role.getRoleName())) { isAdmin = true; break; }
        }
    }
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
    <title><%= HtmlEscaper.escape(news.getTitle()) %> - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-detail app-page-news-detail">
    <!-- 导航栏 -->
    <%
    request.setAttribute("activeNav", "news");
%>
<%@ include file="includes/navbar.jspf" %>

    <div class="container mt-4">
        <!-- 返回按钮 -->
        <a href="${pageContext.request.contextPath}/news?action=list" class="btn btn-outline-secondary mb-4">
            <i class="fas fa-arrow-left me-1"></i>返回列表
        </a>

        <div class="app-detail-layout">
            <!-- ═══ Main: 新闻内容 ═══ -->
            <div class="app-detail-main" style="padding:0;">
                <div style="background: var(--app-ink); color: #fff; padding: 28px 28px 20px;">
                    <h1 style="color:#fff; margin:0;">
                        <%= HtmlEscaper.escape(news.getTitle()) %>
                    </h1>
                </div>
                <div style="padding:22px 28px;">
                    <div class="news-content" style="font-size:1.05rem; line-height:1.8; color:var(--app-ink-soft); white-space:pre-wrap; word-wrap:break-word;">
                        <%= HtmlEscaper.escape(news.getContent() != null ? news.getContent() : "暂无内容") %>
                    </div>
                </div>
            </div>

            <!-- ═══ Rail: 元数据 ═══ -->
            <div class="app-detail-rail">
                <h3 style="margin-top:0;">新闻信息</h3>

                <span class="app-detail-label">发布时间</span>
                <p class="app-detail-value"><i class="far fa-calendar-alt me-1"></i><%= news.getPublishTime() != null ? news.getPublishTime().format(formatter) : "未知时间" %></p>

                <% if (news.getCompetitionId() != null) { %>
                <span class="app-detail-label">关联竞赛ID</span>
                <p class="app-detail-value"><i class="fas fa-trophy me-1"></i><%= news.getCompetitionId() %></p>
                <% } %>

                <span class="app-detail-label">状态</span>
                <p class="app-detail-value">
                    <% if (news.getStatus() != null && news.getStatus() == 1) { %>
                        <span class="badge" style="background:var(--app-mint); color:#124d3b;">已发布</span>
                    <% } else { %>
                        <span class="badge" style="background:#e0e7ea; color:var(--app-ink-soft);">已撤回</span>
                    <% } %>
                </p>

                <% if (isAdmin) { %>
                    <hr style="border-color:var(--app-rule); margin: 18px 0;">
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <a href="${pageContext.request.contextPath}/news?action=edit&id=<%= news.getNewsId() %>" class="btn btn-outline-primary" style="width:100%;">
                            <i class="fas fa-edit me-1"></i>编辑
                        </a>
                        <a href="${pageContext.request.contextPath}/news?action=manage" class="btn btn-outline-secondary" style="width:100%;">
                            <i class="fas fa-cog me-1"></i>管理
                        </a>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
