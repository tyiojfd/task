<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.*" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
<%
    User sessionUser = (User) session.getAttribute("user");

    @SuppressWarnings("unchecked")
    java.util.List<Role> userRoles = (java.util.List<Role>) session.getAttribute("roles");
    boolean isAdmin = false;
    if (userRoles != null) {
        for (Role role : userRoles) {
            if ("管理员".equals(role.getRoleName())) isAdmin = true;
        }
    }

    Award award = (Award) request.getAttribute("award");
    Work work = (Work) request.getAttribute("work");
    Team team = (Team) request.getAttribute("team");
    Competition competition = (Competition) request.getAttribute("competition");
    Certificate certificate = (Certificate) request.getAttribute("certificate");

    if (award == null) {
        response.sendRedirect(request.getContextPath() + "/award?action=list");
        return;
    }

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy年MM月dd日 HH:mm");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>获奖详情 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-detail app-page-award-detail">

<%
    request.setAttribute("activeNav", "awards");
%>
<%@ include file="includes/navbar.jspf" %>

<div class="container">
    <div class="app-detail-layout" style="margin-top:28px;">
        <!-- ═══ Main: 获奖信息 ═══ -->
        <div class="app-detail-main" style="padding:0;">
            <div style="background: linear-gradient(135deg, #D4A843 0%, #F0D78C 100%); color: #5D3A1A; padding: 28px 28px 20px;">
                <h2 style="color:#5D3A1A; margin:0 0 4px;">
                    <i class="fas fa-medal me-2"></i><%= HtmlEscaper.escape(award.getAwardLevel()) %>
                </h2>
                <p style="margin:0; opacity:0.8;"><%= HtmlEscaper.escape(competition != null ? competition.getName() : "") %></p>
            </div>
            <div style="padding:22px 28px;">
                <h3 style="margin-top:0;">获奖详情</h3>
                <table class="table">
                    <tr><td class="text-muted" width="150">获奖等级</td><td><strong style="color:#D4A843;"><%= HtmlEscaper.escape(award.getAwardLevel()) %></strong></td></tr>
                    <tr><td class="text-muted">最终得分</td><td><strong><%= String.format("%.1f", award.getFinalScore()) %></strong> 分</td></tr>
                    <tr><td class="text-muted">获奖时间</td><td><%= award.getAwardTime() != null ? award.getAwardTime().format(dtf) : "" %></td></tr>
                    <tr><td class="text-muted">作品名称</td><td><strong><%= HtmlEscaper.escape(work != null ? work.getTitle() : "未知") %></strong></td></tr>
                    <tr><td class="text-muted">所属队伍</td><td><%= HtmlEscaper.escape(team != null ? team.getTeamName() : "未知") %></td></tr>
                    <tr><td class="text-muted">参赛竞赛</td><td><%= HtmlEscaper.escape(competition != null ? competition.getName() : "未知") %></td></tr>
                    <% if (certificate != null) { %>
                    <tr><td class="text-muted">证书编号</td><td><code><%= HtmlEscaper.escape(certificate.getCertificateNo()) %></code></td></tr>
                    <% } %>
                </table>
            </div>
        </div>

        <!-- ═══ Rail: 奖状链接 ═══ -->
        <div class="app-detail-rail" style="text-align:center;">
            <i class="fas fa-trophy" style="font-size:4rem;color:#FFD700; margin-bottom:12px; display:block;"></i>
            <h3 style="margin-top:0;"><%= HtmlEscaper.escape(award.getAwardLevel()) %></h3>
            <p class="text-muted" style="margin-bottom:18px;">最终得分: <strong><%= String.format("%.1f", award.getFinalScore()) %></strong> 分</p>

            <div style="display:flex; flex-direction:column; gap:8px;">
                <a href="${pageContext.request.contextPath}/certificate?action=view&awardId=<%= award.getAwardId() %>"
                   class="btn btn-warning w-100" target="_blank">
                    <i class="fas fa-certificate me-1"></i> 查看电子奖状
                </a>
                <a href="${pageContext.request.contextPath}/work?action=detail&id=<%= award.getWorkId() %>"
                   class="btn btn-outline-primary w-100">
                    <i class="fas fa-image me-1"></i> 查看作品
                </a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
