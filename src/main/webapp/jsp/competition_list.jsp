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

    // 角色权限检查
    User sessionUser = (User) session.getAttribute("user");
    boolean isAdmin = false;
    boolean isJudge = false;
    if (sessionUser != null) {
        @SuppressWarnings("unchecked")
        List<Role> roles = (List<Role>) session.getAttribute("roles");
        if (roles != null) {
            for (Role r : roles) {
                if ("管理员".equals(r.getRoleName())) isAdmin = true;
                if ("评委".equals(r.getRoleName())) isJudge = true;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>竞赛列表 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: #f5f5f5; }
        .competition-card {
            transition: transform 0.3s;
            cursor: pointer;
            border-radius: 10px;
        }
        .competition-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        .status-badge { font-size: 14px; }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <%
    request.setAttribute("activeNav", "competitions");
%>
<%@ include file="includes/navbar.jspf" %>

    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>竞赛列表</h2>
            <% if (isAdmin) { %>
            <a href="${pageContext.request.contextPath}/competition?action=add" class="btn btn-primary">
                发布竞赛
            </a>
            <% } %>
        </div>

        <!-- 搜索与筛选栏 -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="get" action="${pageContext.request.contextPath}/competition" class="row g-2 align-items-end">
                    <input type="hidden" name="action" value="list">
                    <div class="col-md-5">
                        <label class="form-label small text-muted">关键词搜索</label>
                        <input type="text" class="form-control" name="keyword" placeholder="搜索竞赛名称、主题、描述..."
                               value="<%= HtmlEscaper.escape(request.getAttribute("keyword") != null ? request.getAttribute("keyword").toString() : "") %>">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label small text-muted">年度</label>
                        <select class="form-select" name="year">
                            <option value="">全部</option>
                            <% Integer filterYear = (Integer) request.getAttribute("filterYear"); %>
                            <option value="2024" <%= filterYear != null && filterYear == 2024 ? "selected" : "" %>>2024</option>
                            <option value="2025" <%= filterYear != null && filterYear == 2025 ? "selected" : "" %>>2025</option>
                            <option value="2026" <%= filterYear != null && filterYear == 2026 ? "selected" : "" %>>2026</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small text-muted">状态</label>
                        <select class="form-select" name="status">
                            <option value="">全部</option>
                            <% Integer filterStatus = (Integer) request.getAttribute("filterStatus"); %>
                            <option value="1" <%= filterStatus != null && filterStatus == 1 ? "selected" : "" %>>报名中</option>
                            <option value="2" <%= filterStatus != null && filterStatus == 2 ? "selected" : "" %>>进行中</option>
                            <option value="3" <%= filterStatus != null && filterStatus == 3 ? "selected" : "" %>>已结束</option>
                            <option value="0" <%= filterStatus != null && filterStatus == 0 ? "selected" : "" %>>已取消</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex gap-2">
                        <button type="submit" class="btn btn-primary w-50"><i class="fas fa-search"></i> 搜索</button>
                        <a href="${pageContext.request.contextPath}/competition?action=list" class="btn btn-outline-secondary w-50">重置</a>
                    </div>
                </form>
            </div>
        </div>

        <!-- 统计概览 -->
        <% java.util.Map globalStats = (java.util.Map) request.getAttribute("globalStats");
           if (globalStats != null) { %>
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card text-center bg-primary bg-opacity-10 border-primary">
                    <div class="card-body py-3">
                        <h5 class="text-primary mb-1"><%= globalStats.get("compCount") %></h5>
                        <small class="text-muted">竞赛总数</small>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-center bg-success bg-opacity-10 border-success">
                    <div class="card-body py-3">
                        <h5 class="text-success mb-1"><%= globalStats.get("teamCount") %></h5>
                        <small class="text-muted">参赛队伍</small>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-center bg-warning bg-opacity-10 border-warning">
                    <div class="card-body py-3">
                        <h5 class="text-warning mb-1"><%= globalStats.get("workCount") %></h5>
                        <small class="text-muted">作品总数</small>
                    </div>
                </div>
            </div>
        </div>
        <% } %>

        <% if (competitions != null && !competitions.isEmpty()) { %>
            <div class="row">
                <% for (Competition comp : competitions) { %>
                    <div class="col-md-6 mb-3">
                        <div class="card competition-card" onclick="window.location.href='${pageContext.request.contextPath}/competition?action=detail&id=<%= comp.getCompetitionId() %>'">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <h5 class="card-title mb-0"><%= HtmlEscaper.escape(comp.getName()) %></h5>
                                    <span class="badge status-badge
                                        <% if (comp.getStatus() == 1) { %>bg-success<% }
                                           else if (comp.getStatus() == 2) { %>bg-primary<% }
                                           else if (comp.getStatus() == 3) { %>bg-secondary<% }
                                           else { %>bg-danger<% } %>">
                                        <% if (comp.getStatus() == 1) { %>报名中<% }
                                           else if (comp.getStatus() == 2) { %>进行中<% }
                                           else if (comp.getStatus() == 3) { %>已结束<% }
                                           else { %>已取消<% } %>
                                    </span>
                                </div>
                                <p class="text-muted mb-2">年度：<%= comp.getYear() %>年</p>
                                <% if (comp.getTheme() != null) { %>
                                    <p class="text-muted mb-2">主题：<%= HtmlEscaper.escape(comp.getTheme()) %></p>
                                <% } %>
                                <p class="card-text text-truncate"><%= HtmlEscaper.escape(comp.getDescription() != null ? comp.getDescription() : "暂无描述") %></p>
                                <small class="text-muted">
                                    截止时间：<%= comp.getSubmitDeadline() != null ? comp.getSubmitDeadline().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "未设置" %>
                                </small>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="alert alert-info text-center">
                暂无竞赛信息<% if (isAdmin) { %>，<a href="${pageContext.request.contextPath}/competition?action=add">立即发布</a><% } %>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
