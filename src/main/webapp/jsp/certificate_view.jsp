<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
<%
    User sessionUser = (User) session.getAttribute("user");

    Certificate certificate = (Certificate) request.getAttribute("certificate");
    Award award = (Award) request.getAttribute("award");
    Work work = (Work) request.getAttribute("work");
    Team team = (Team) request.getAttribute("team");
    Competition competition = (Competition) request.getAttribute("competition");
    User leader = (User) request.getAttribute("leader");

    @SuppressWarnings("unchecked")
    List<TeamMember> members = (List<TeamMember>) request.getAttribute("members");

    if (award == null) {
        response.sendRedirect(request.getContextPath() + "/index");
        return;
    }

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy年MM月dd日");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>电子奖状 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-catalog app-page-certificate-detail">

<button class="btn btn-primary btn-print no-print" onclick="window.print()">
    <i class="fas fa-print"></i> 打印奖状
</button>
<a class="btn btn-success no-print" style="position:fixed;top:20px;right:140px;z-index:999;"
   href="<%= request.getContextPath() %>/certificate?action=download&awardId=<%= award.getAwardId() %>">
    <i class="fas fa-download"></i> 下载奖状
</a>

<div class="certificate-container">
    <i class="fas fa-trophy cert-decor decor-tl"></i>
    <i class="fas fa-star cert-decor decor-tr"></i>
    <i class="fas fa-medal cert-decor decor-bl"></i>
    <i class="fas fa-crown cert-decor decor-br"></i>

    <div class="cert-header">
        <div class="cert-title">获 奖 证 书</div>
        <div class="cert-subtitle">CERTIFICATE OF AWARD</div>
    </div>

    <div class="cert-body">
        <div class="competition-name">
            在「<%= HtmlEscaper.escape(competition != null ? competition.getName() : "大学生海报设计竞赛") %>」中
        </div>

        <div class="recipient">
            <strong><%= HtmlEscaper.escape(team != null ? team.getTeamName() : "优秀团队") %></strong>
            <% if (leader != null) { %>
            （队长：<%= HtmlEscaper.escape(leader.getRealName() != null ? leader.getRealName() : leader.getUsername()) %>）
            <% } %>
        </div>

        <div>
            提交的作品
            <span class="work-title">《<%= HtmlEscaper.escape(work != null ? work.getTitle() : "优秀作品") %>》</span>
        </div>

        <div>荣获</div>

        <div class="award-level">
            <%= HtmlEscaper.escape(award.getAwardLevel()) %>
        </div>

        <div>最终得分：<strong><%= String.format("%.1f", award.getFinalScore()) %></strong> 分</div>

        <% if (certificate != null) { %>
            <div class="cert-no">证书编号：<%= HtmlEscaper.escape(certificate.getCertificateNo()) %></div>
        <% } %>
    </div>

    <div class="cert-footer">
        <div class="issuer">大学生海报设计竞赛组委会</div>
        <div class="date">
            <%= award.getAwardTime() != null ? award.getAwardTime().format(dtf) : "" %>
        </div>
    </div>

    <div class="cert-stamp">证书专用章</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
