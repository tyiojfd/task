<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    @SuppressWarnings("unchecked")
    List<Competition> competitions = (List<Competition>) request.getAttribute("competitions");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>竞赛列表 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
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
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/index">海报竞赛系统</a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/index">首页</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>竞赛列表</h2>
            <a href="${pageContext.request.contextPath}/competition?action=add" class="btn btn-primary">
                发布竞赛
            </a>
        </div>

        <% if (competitions != null && !competitions.isEmpty()) { %>
            <div class="row">
                <% for (Competition comp : competitions) { %>
                    <div class="col-md-6 mb-3">
                        <div class="card competition-card" onclick="window.location.href='${pageContext.request.contextPath}/competition?action=detail&id=<%= comp.getCompetitionId() %>'">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <h5 class="card-title mb-0"><%= comp.getName() %></h5>
                                    <span class="badge status-badge <%= comp.getStatus() == 1 ? "bg-success" : comp.getStatus() == 2 ? "bg-primary" : "bg-secondary" %>">
                                        <%= comp.getStatus() == 1 ? "报名中" : comp.getStatus() == 2 ? "进行中" : "已结束" %>
                                    </span>
                                </div>
                                <p class="text-muted mb-2">年度：<%= comp.getYear() %>年</p>
                                <% if (comp.getTheme() != null) { %>
                                    <p class="text-muted mb-2">主题：<%= comp.getTheme() %></p>
                                <% } %>
                                <p class="card-text text-truncate"><%= comp.getDescription() != null ? comp.getDescription() : "暂无描述" %></p>
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
                暂无竞赛信息，<a href="${pageContext.request.contextPath}/competition?action=add">立即发布</a>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
