<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Role> userRoles = (List<Role>) session.getAttribute("roles");
    boolean isAdmin = false;
    if (userRoles != null) {
        for (Role role : userRoles) {
            if ("管理员".equals(role.getRoleName())) isAdmin = true;
        }
    }

    @SuppressWarnings("unchecked")
    List<Certificate> certificates = (List<Certificate>) request.getAttribute("certificates");
    @SuppressWarnings("unchecked")
    Map<Integer, Award> awardMap = (Map<Integer, Award>) request.getAttribute("awardMap");
    @SuppressWarnings("unchecked")
    Map<Integer, Work> workMap = (Map<Integer, Work>) request.getAttribute("workMap");
    @SuppressWarnings("unchecked")
    Map<Integer, String> teamNameMap = (Map<Integer, String>) request.getAttribute("teamNameMap");
    @SuppressWarnings("unchecked")
    Map<Integer, String> competitionNameMap = (Map<Integer, String>) request.getAttribute("competitionNameMap");

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的奖状 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-catalog app-page-certificates">

<!-- 导航栏 -->
<%
    request.setAttribute("activeNav", "certificates");
%>
<%@ include file="includes/navbar.jspf" %>

<div class="container">
    <div class="page-header">
        <h2><i class="fas fa-certificate"></i> 我的奖状</h2>
        <p>查看您所在队伍获得的所有荣誉</p>
    </div>

    <% if (certificates != null && !certificates.isEmpty()) { %>
    <div class="row">
        <% for (Certificate cert : certificates) {
            Award award = awardMap != null ? awardMap.get(cert.getCertificateId()) : null;
            Work work = workMap != null ? workMap.get(cert.getCertificateId()) : null;
            String teamName = teamNameMap != null ? teamNameMap.get(cert.getCertificateId()) : "未知队伍";
            String compName = competitionNameMap != null ? competitionNameMap.get(cert.getCertificateId()) : "未知竞赛";
        %>
        <div class="col-md-6 col-lg-4">
            <div class="cert-card">
                <div class="d-flex align-items-center mb-3">
                    <div style="width:50px;height:50px;border-radius:50%;background:linear-gradient(135deg,#FFD700,#FFA500);
                                display:flex;align-items:center;justify-content:center;color:white;font-size:1.5rem;flex-shrink:0;">
                        <i class="fas fa-trophy"></i>
                    </div>
                    <div class="ms-3">
                        <div class="fw-bold">
                            <%= HtmlEscaper.escape(award != null ? award.getAwardLevel() : "获奖") %>
                        </div>
                        <small class="text-muted"><%= HtmlEscaper.escape(compName) %></small>
                    </div>
                </div>
                <div class="mb-2">
                    <strong><%= HtmlEscaper.escape(work != null ? work.getTitle() : "作品") %></strong>
                </div>
                <small class="text-muted">
                    <i class="fas fa-users"></i> <%= HtmlEscaper.escape(teamName) %> &nbsp;
                    <i class="fas fa-star"></i> <%= award != null ? String.format("%.1f", award.getFinalScore()) : "0.0" %> 分
                </small>
                <div class="mt-2 text-muted" style="font-size:0.85rem;">
                    <i class="fas fa-barcode"></i> <%= HtmlEscaper.escape(cert.getCertificateNo()) %>
                </div>
                <a href="${pageContext.request.contextPath}/certificate?action=view&awardId=<%= cert.getAwardId() %>"
                   class="btn btn-outline-warning btn-sm w-100 mt-3" target="_blank">
                    <i class="fas fa-certificate"></i> 查看奖状
                </a>
            </div>
        </div>
        <% } %>
    </div>
    <% } else { %>
    <div class="empty-state">
        <i class="fas fa-certificate"></i>
        <h5>暂无奖状</h5>
        <p class="text-muted">您的队伍暂未获得奖状，继续加油！</p>
        <a href="${pageContext.request.contextPath}/competition?action=list" class="btn btn-primary mt-3">
            <i class="fas fa-trophy"></i> 查看竞赛
        </a>
    </div>
    <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
