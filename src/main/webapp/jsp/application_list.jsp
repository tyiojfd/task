<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    @SuppressWarnings("unchecked")
    List<TeamApplication> applications = (List<TeamApplication>) request.getAttribute("applications");
    @SuppressWarnings("unchecked")
    Map<Integer, Team> teamMap = (Map<Integer, Team>) request.getAttribute("teamMap");
    @SuppressWarnings("unchecked")
    Map<Integer, User> userMap = (Map<Integer, User>) request.getAttribute("userMap");
    Team team = (Team) request.getAttribute("team");
    String viewMode = (String) request.getAttribute("viewMode");
    boolean teamMode = "team".equals(viewMode);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= teamMode ? "入队申请审核" : "我的入队申请" %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-catalog app-page-applications">
<% request.setAttribute("activeNav", "applications"); %>
<%@ include file="includes/navbar.jspf" %>
<div class="container">
    <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h2 class="mb-2"><i class="fas fa-user-plus me-2"></i><%= teamMode ? "入队申请审核" : "我的入队申请" %></h2>
            <p class="mb-0"><%= HtmlEscaper.escape(teamMode && team != null ? team.getTeamName() : "查看申请进度") %></p>
        </div>
        <a class="btn btn-light" href="${pageContext.request.contextPath}/<%= teamMode && team != null ? "team?action=detail&id=" + team.getTeamId() : "team?action=myTeams" %>">返回</a>
    </div>

    <% String msg = request.getParameter("msg"); String error = request.getParameter("error"); %>
    <% if (msg != null) { %><div class="alert alert-success">操作成功</div><% } %>
    <% if (error != null) { %><div class="alert alert-danger">操作失败，请确认队伍仍在组建中且人数未满</div><% } %>

    <% if (applications == null || applications.isEmpty()) { %>
        <div class="text-center bg-white rounded-4 p-5 text-muted"><i class="fas fa-inbox fa-3x mb-3"></i><h4>暂无申请记录</h4></div>
    <% } else { %>
        <% for (TeamApplication app : applications) {
            String statusText = app.getStatus() != null && app.getStatus() == 1 ? "已通过" : app.getStatus() != null && app.getStatus() == 2 ? "已拒绝" : app.getStatus() != null && app.getStatus() == 3 ? "已取消" : "待处理";
            Team itemTeam = teamMode ? team : (teamMap != null ? teamMap.get(app.getTeamId()) : null);
            User applicant = userMap != null ? userMap.get(app.getApplicantId()) : null;
        %>
        <div class="app-card">
            <div class="d-flex justify-content-between align-items-start gap-3 flex-wrap">
                <div>
                    <h5 class="fw-bold mb-2"><%= HtmlEscaper.escape(teamMode ? (applicant != null ? applicant.getRealName() : "申请人#" + app.getApplicantId()) : (itemTeam != null ? itemTeam.getTeamName() : "队伍#" + app.getTeamId())) %></h5>
                    <p class="text-muted mb-2"><%= HtmlEscaper.escape(app.getMessage() != null && !app.getMessage().trim().isEmpty() ? app.getMessage() : "申请加入队伍") %></p>
                    <span class="badge status-<%= app.getStatus() != null ? app.getStatus() : 0 %>"><%= statusText %></span>
                </div>
                <% if (teamMode && app.getStatus() != null && app.getStatus() == 0) { %>
                <div class="d-flex gap-2">
                    <form method="post" action="${pageContext.request.contextPath}/application?action=approve">
                        <input type="hidden" name="applicationId" value="<%= app.getApplicationId() %>">
                        <input type="hidden" name="teamId" value="<%= app.getTeamId() %>">
                        <button class="btn btn-success btn-sm" type="submit">通过</button>
                    </form>
                    <form method="post" action="${pageContext.request.contextPath}/application?action=reject">
                        <input type="hidden" name="applicationId" value="<%= app.getApplicationId() %>">
                        <input type="hidden" name="teamId" value="<%= app.getTeamId() %>">
                        <button class="btn btn-outline-danger btn-sm" type="submit">拒绝</button>
                    </form>
                </div>
                <% } else if (!teamMode && app.getStatus() != null && app.getStatus() == 0) { %>
                <form method="post" action="${pageContext.request.contextPath}/application?action=cancel">
                    <input type="hidden" name="applicationId" value="<%= app.getApplicationId() %>">
                    <button class="btn btn-outline-secondary btn-sm" type="submit">取消申请</button>
                </form>
                <% } %>
            </div>
        </div>
        <% } %>
    <% } %>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
