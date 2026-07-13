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
    <style>
        body { background: linear-gradient(135deg, #F8F9FA 0%, #E8ECF1 100%); min-height: 100vh; }
        .page-header { background: linear-gradient(135deg, #6C5CE7, #A29BFE); color: white; border-radius: 20px; padding: 2rem; margin: 2rem 0; }
        .work-card { background: white; border-radius: 18px; overflow: hidden; box-shadow: 0 2px 16px rgba(108,92,231,0.08); transition: transform .2s, box-shadow .2s; height: 100%; }
        .work-card:hover { transform: translateY(-4px); box-shadow: 0 10px 28px rgba(108,92,231,0.16); }
        .work-cover { width: 100%; height: 220px; object-fit: cover; background: #f1f2f6; }
        .empty-state { text-align: center; padding: 4rem 2rem; color: #636E72; }
        .empty-state i { font-size: 4rem; opacity: .35; margin-bottom: 1rem; }
    </style>
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body>
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
    <div class="row g-4 mb-5">
        <% for (Work work : works) {
            if (work.getStatus() == null || (work.getStatus() != 2 && work.getStatus() != 3)) continue;
            Team team = teamMap != null ? teamMap.get(work.getTeamId()) : null;
            Integer likes = likeCountMap != null ? likeCountMap.get(work.getWorkId()) : 0;
            String imgUrl = request.getContextPath() + "/image-data?workId=" + work.getWorkId() + "&type=thumb";
        %>
        <div class="col-md-6 col-lg-4">
            <div class="work-card">
                <% if (!imgUrl.isEmpty()) { %>
                <img src="<%= imgUrl %>" class="work-cover" alt="<%= HtmlEscaper.escape(work.getTitle() != null ? work.getTitle() : "作品图片") %>">
                <% } else { %>
                <div class="work-cover d-flex align-items-center justify-content-center text-muted"><i class="fas fa-image fa-3x"></i></div>
                <% } %>
                <div class="p-4">
                    <h5 class="fw-bold mb-2"><%= HtmlEscaper.escape(work.getTitle() != null ? work.getTitle() : "未命名作品") %></h5>
                    <div class="text-muted small mb-3"><i class="fas fa-users me-1"></i><%= HtmlEscaper.escape(team != null ? team.getTeamName() : "未知队伍") %></div>
                    <p class="text-muted" style="min-height:3rem;"><%= HtmlEscaper.escape(work.getDescription() != null && work.getDescription().length() > 60 ? work.getDescription().substring(0, 60) + "..." : (work.getDescription() != null ? work.getDescription() : "暂无描述")) %></p>
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="text-muted small"><i class="fas fa-heart text-danger me-1"></i><%= likes != null ? likes : 0 %></span>
                        <a href="${pageContext.request.contextPath}/work?action=detail&id=<%= work.getWorkId() %>" class="btn btn-outline-primary btn-sm">查看详情</a>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>
    <% } else { %>
    <div class="empty-state bg-white rounded-4">
        <i class="fas fa-images"></i>
        <h4>暂无作品</h4>
        <p>该竞赛暂未展示已提交作品。</p>
    </div>
    <% } %>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
