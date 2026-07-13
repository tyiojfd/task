<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
<%
    @SuppressWarnings("unchecked")
    List<Competition> competitions = (List<Competition>) request.getAttribute("competitions");

    User sessionUser = (User) session.getAttribute("user");
    boolean isAdmin = false;
    boolean isJudge = false;
    if (sessionUser != null) {
        @SuppressWarnings("unchecked")
        List<Role> roles = (List<Role>) session.getAttribute("roles");
        if (roles != null) {
            for (Role role : roles) {
                if ("管理员".equals(role.getRoleName())) isAdmin = true;
                if ("评委".equals(role.getRoleName())) isJudge = true;
            }
        }
    }
    int competitionCount = competitions == null ? 0 : competitions.size();
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>竞赛目录 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-catalog app-page-competition-list">
<%
    request.setAttribute("activeNav", "competitions");
%>
<%@ include file="includes/navbar.jspf" %>

<main class="container mt-4">
    <header class="app-page-hero">
        <div class="app-page-hero-inner">
            <div class="app-page-hero-copy">
                <p class="app-page-kicker">竞赛目录</p>
                <h1>探索赛事</h1>
                <p class="app-page-summary">从主题、时间和参赛规则开始，找到适合你的海报创作现场。</p>
            </div>
            <div class="app-page-hero-stat">
                <strong><%= competitionCount %></strong>
                <span>场赛事</span>
            </div>
            <% if (isAdmin) { %>
                <a href="${pageContext.request.contextPath}/competition?action=add" class="btn btn-light" style="border-radius:8px;font-weight:800;">
                    <i class="fas fa-plus me-1"></i>发布竞赛
                </a>
            <% } %>
        </div>
    </header>

    <div class="app-toolbar">
        <form method="get" action="${pageContext.request.contextPath}/competition" class="row g-2 align-items-end w-100">
            <input type="hidden" name="action" value="list">
            <div class="col-lg-5 toolbar-field toolbar-field-wide">
                <label for="competitionKeyword">搜索竞赛</label>
                <input id="competitionKeyword" type="text" class="form-control" name="keyword"
                       placeholder="竞赛名称、主题或描述"
                       value="<%= HtmlEscaper.escape(request.getAttribute("keyword") != null ? request.getAttribute("keyword").toString() : "") %>">
            </div>
            <div class="col-md-3 col-lg-2 toolbar-field">
                <label for="competitionYear">年度</label>
                <select id="competitionYear" class="form-select" name="year">
                    <option value="">全部年份</option>
                    <% Integer filterYear = (Integer) request.getAttribute("filterYear"); %>
                    <option value="2024" <%= filterYear != null && filterYear == 2024 ? "selected" : "" %>>2024</option>
                    <option value="2025" <%= filterYear != null && filterYear == 2025 ? "selected" : "" %>>2025</option>
                    <option value="2026" <%= filterYear != null && filterYear == 2026 ? "selected" : "" %>>2026</option>
                </select>
            </div>
            <div class="col-md-3 col-lg-2 toolbar-field">
                <label for="competitionStatus">状态</label>
                <select id="competitionStatus" class="form-select" name="status">
                    <option value="">全部状态</option>
                    <% Integer filterStatus = (Integer) request.getAttribute("filterStatus"); %>
                    <option value="1" <%= filterStatus != null && filterStatus == 1 ? "selected" : "" %>>报名中</option>
                    <option value="2" <%= filterStatus != null && filterStatus == 2 ? "selected" : "" %>>进行中</option>
                    <option value="3" <%= filterStatus != null && filterStatus == 3 ? "selected" : "" %>>已结束</option>
                    <option value="0" <%= filterStatus != null && filterStatus == 0 ? "selected" : "" %>>已取消</option>
                </select>
            </div>
            <div class="col-md-3 col-lg-3 d-flex gap-2 toolbar-field">
                <button type="submit" class="btn btn-primary"><i class="fas fa-search me-1"></i>搜索</button>
                <a href="${pageContext.request.contextPath}/competition?action=list" class="btn btn-light">重置</a>
            </div>
        </form>
    </div>

    <% if (competitions != null && !competitions.isEmpty()) { %>
        <section class="app-catalog-grid" aria-label="竞赛列表">
            <% for (Competition comp : competitions) {
                String statusColorClass;
                String statusLabel;
                String statusClass;
                if (comp.getStatus() != null && comp.getStatus() == 1) {
                    statusColorClass = "status-open";
                    statusLabel = "报名中";
                    statusClass = "bg-success";
                } else if (comp.getStatus() != null && comp.getStatus() == 2) {
                    statusColorClass = "status-active";
                    statusLabel = "进行中";
                    statusClass = "bg-primary";
                } else if (comp.getStatus() != null && comp.getStatus() == 3) {
                    statusColorClass = "status-ended";
                    statusLabel = "已结束";
                    statusClass = "bg-secondary";
                } else {
                    statusColorClass = "status-cancelled";
                    statusLabel = "已取消";
                    statusClass = "bg-danger";
                }
            %>
                <article class="competition-card <%= statusColorClass %>">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start gap-2 mb-2">
                            <h2 class="card-title mb-0"><%= HtmlEscaper.escape(comp.getName()) %></h2>
                            <span class="badge status-badge <%= statusClass %>"><%= statusLabel %></span>
                        </div>
                        <p class="text-muted mb-2"><i class="far fa-calendar me-1"></i><%= comp.getYear() %> 年</p>
                        <% if (comp.getTheme() != null && !comp.getTheme().trim().isEmpty()) { %>
                            <p class="text-muted mb-2"><i class="fas fa-compass me-1"></i><%= HtmlEscaper.escape(comp.getTheme()) %></p>
                        <% } %>
                        <p class="card-text"><%= HtmlEscaper.escape(comp.getDescription() != null && !comp.getDescription().trim().isEmpty() ? comp.getDescription() : "等待创作者进入现场") %></p>
                        <div class="d-flex align-items-center justify-content-between gap-2 mt-auto pt-2">
                            <small class="text-muted">
                                <i class="far fa-clock me-1"></i><%= comp.getSubmitDeadline() != null ? comp.getSubmitDeadline().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "截止时间待定" %>
                            </small>
                            <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/competition?action=detail&id=<%= comp.getCompetitionId() %>">查看详情</a>
                        </div>
                    </div>
                </article>
            <% } %>
        </section>
    <% } else { %>
        <section class="app-catalog-empty">
            <i class="far fa-folder-open"></i>
            <h2>暂时没有竞赛信息</h2>
            <p>新的主题还在准备中，稍后再来看看。</p>
            <% if (isAdmin) { %>
                <a href="${pageContext.request.contextPath}/competition?action=add" class="btn btn-primary mt-2">立即发布竞赛</a>
            <% } %>
        </section>
    <% } %>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
