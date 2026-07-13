<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
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
    Competition competition = (Competition) request.getAttribute("competition");
    @SuppressWarnings("unchecked")
    List<Work> works = (List<Work>) request.getAttribute("works");
    @SuppressWarnings("unchecked")
    Map<Integer, Team> teamMap = (Map<Integer, Team>) request.getAttribute("teamMap");
    @SuppressWarnings("unchecked")
    Map<Integer, Integer> likeCountMap = (Map<Integer, Integer>) request.getAttribute("likeCountMap");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>作品展厅 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-gallery app-page-competition-works">
<% request.setAttribute("activeNav", "competitions"); %>
<%@ include file="includes/navbar.jspf" %>
<div class="container">
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h2 class="mb-2"><i class="fas fa-images me-2"></i>作品展厅</h2>
            <p class="mb-0"><%= HtmlEscaper.escape(competition != null ? competition.getName() : "竞赛作品") %></p>
        </div>
        <a href="${pageContext.request.contextPath}/competition?action=detail&id=<%= competition != null ? competition.getCompetitionId() : "" %>" class="btn btn-light">
            <i class="fas fa-arrow-left me-1"></i>返回竞赛
        </a>
    </div>

    <% if (works != null && !works.isEmpty()) { %>
    <section class="app-art-grid" aria-label="作品展厅">
        <% for (Work work : works) {
            if (work.getStatus() == null || (work.getStatus() != 2 && work.getStatus() != 3)) continue;
            Team team = teamMap != null ? teamMap.get(work.getTeamId()) : null;
            Integer likes = likeCountMap != null ? likeCountMap.get(work.getWorkId()) : 0;
            String imgUrl = request.getContextPath() + "/image-data?workId=" + work.getWorkId() + "&type=thumb";
        %>
        <article class="work-card app-art-card">
            <a class="app-art-media" href="${pageContext.request.contextPath}/work?action=detail&id=<%= work.getWorkId() %>">
                <% if (!imgUrl.isEmpty()) { %>
                <img src="<%= imgUrl %>" alt="<%= HtmlEscaper.escape(work.getTitle() != null ? work.getTitle() : "作品图片") %>">
                <% } else { %>
                <div class="d-flex align-items-center justify-content-center text-muted" style="aspect-ratio:4/3;"><i class="fas fa-image fa-3x"></i></div>
                <% } %>
            </a>
            <div class="work-body app-art-info">
                <div class="work-title"><a href="${pageContext.request.contextPath}/work?action=detail&id=<%= work.getWorkId() %>"><%= HtmlEscaper.escape(work.getTitle() != null ? work.getTitle() : "未命名作品") %></a></div>
                <div class="work-meta app-art-meta">
                    <div><i class="fas fa-users me-1"></i><%= HtmlEscaper.escape(team != null ? team.getTeamName() : "未知队伍") %></div>
                    <div><i class="fas fa-heart me-1"></i><%= likes != null ? likes : 0 %> 赞</div>
                </div>
            </div>
            <div class="work-actions app-art-actions">
                <a href="${pageContext.request.contextPath}/work?action=detail&id=<%= work.getWorkId() %>" class="btn btn-sm">查看详情</a>
            </div>
        </article>
        <% } %>
    </section>
    <% } else { %>
    <div class="app-empty">
        <i class="fas fa-images"></i>
        <h2>暂无作品</h2>
        <p>该竞赛暂未展示已提交作品。</p>
    </div>
    <% } %>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
