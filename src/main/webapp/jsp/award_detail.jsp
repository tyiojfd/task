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
    <style>
        :root {
            --primary: #6C5CE7; --primary-light: #A29BFE; --accent: #FD79A8;
            --dark: #2D3436; --gray: #636E72; --gold: #D4A843;
            --card-shadow: 0 2px 16px rgba(108,92,231,0.06);
        }
        body {
            background: linear-gradient(135deg, #F8F9FA 0%, #E8ECF1 100%);
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
        }
        .navbar { background: var(--dark) !important; box-shadow: 0 2px 12px rgba(0,0,0,0.15); }
        .navbar-brand { font-weight: 700; }
        .navbar-brand i { color: var(--primary-light); margin-right: 6px; }
        .nav-link { font-size: 0.9rem; }
        .nav-link:hover { color: var(--primary-light) !important; }

        .page-header {
            background: linear-gradient(135deg, #D4A843 0%, #F0D78C 100%);
            border-radius: 20px; padding: 2.5rem 2rem; margin: 2rem 0; color: #5D3A1A; text-align: center;
        }
        .page-header h2 { font-weight: 700; }
        .card-custom {
            background: white; border-radius: 16px; padding: 1.5rem;
            box-shadow: var(--card-shadow); margin-bottom: 1.5rem;
        }
    </style>
</head>
<body>

<%
    request.setAttribute("activeNav", "awards");
%>
<%@ include file="includes/navbar.jspf" %>

<div class="container">
    <div class="page-header">
        <h2><i class="fas fa-medal"></i> <%= HtmlEscaper.escape(award.getAwardLevel()) %></h2>
        <p><%= HtmlEscaper.escape(competition != null ? competition.getName() : "") %></p>
    </div>

    <div class="row">
        <div class="col-lg-8">
            <div class="card-custom">
                <h5 class="mb-3"><i class="fas fa-info-circle"></i> 获奖信息</h5>
                <table class="table">
                    <tr><td class="text-muted" width="150">获奖等级</td><td><strong class="text-warning"><%= HtmlEscaper.escape(award.getAwardLevel()) %></strong></td></tr>
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

        <div class="col-lg-4">
            <div class="card-custom text-center">
                <i class="fas fa-trophy" style="font-size:4rem;color:#FFD700;"></i>
                <h4 class="mt-3"><%= HtmlEscaper.escape(award.getAwardLevel()) %></h4>
                <p class="text-muted">最终得分: <%= String.format("%.1f", award.getFinalScore()) %> 分</p>
                <a href="${pageContext.request.contextPath}/certificate?action=view&awardId=<%= award.getAwardId() %>"
                   class="btn btn-warning w-100 mt-3" target="_blank">
                    <i class="fas fa-certificate"></i> 查看电子奖状
                </a>
                <a href="${pageContext.request.contextPath}/work?action=detail&id=<%= award.getWorkId() %>"
                   class="btn btn-outline-primary w-100 mt-2">
                    <i class="fas fa-image"></i> 查看作品
                </a>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
