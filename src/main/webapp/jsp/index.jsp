<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="java.util.List" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    @SuppressWarnings("unchecked")
    List<Role> userRoles = (sessionUser != null) ? (List<Role>) session.getAttribute("roles") : null;
    @SuppressWarnings("unchecked")
    List<Competition> competitions = (List<Competition>) request.getAttribute("competitions");

    // 检查用户角色
    boolean isAdmin = false;
    boolean isJudge = false;
    if (userRoles != null) {
        for (Role role : userRoles) {
            if ("管理员".equals(role.getRoleName())) isAdmin = true;
            if ("评委".equals(role.getRoleName())) isJudge = true;
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>首页 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f5f5f5; }
        .hero-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 60px 0;
            text-align: center;
            margin-bottom: 40px;
        }
        .competition-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
            transition: all 0.3s;
            height: 100%;
        }
        .competition-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        .status-badge {
            position: absolute;
            top: 15px;
            right: 15px;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-ongoing { background: #28a745; color: white; }
        .status-upcoming { background: #ffc107; color: #333; }
        .status-ended { background: #6c757d; color: white; }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <% request.setAttribute("activePage", "home"); %>
    <%@ include file="navbar.jsp" %>

    <!-- Hero Section -->
    <div class="hero-section">
        <div class="container">
            <% if (sessionUser != null) { %>
                <h1 class="display-4 mb-3">欢迎回来，<%= sessionUser.getRealName() %>！</h1>
                <p class="lead">发现精彩竞赛，展示你的创意才华</p>
            <% } else { %>
                <h1 class="display-4 mb-3">大学生海报设计竞赛平台</h1>
                <p class="lead">发现创意，展示才华，赢取荣誉</p>
                <div class="mt-4">
                    <a href="${pageContext.request.contextPath}/register" class="btn btn-light btn-lg me-2">立即注册</a>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light btn-lg">登录</a>
                </div>
            <% } %>
        </div>
    </div>

    <!-- 主体内容 - 根据角色显示不同内容 -->
    <div class="container mb-5">
        <% if (sessionUser != null && isAdmin) { %>
            <!-- 管理员首页 -->
            <h2 class="mb-4">管理控制台</h2>
            <div class="row g-4 mb-4">
                <div class="col-md-4">
                    <div class="card text-center">
                        <div class="card-body">
                            <h3 class="text-primary"><%= competitions != null ? competitions.size() : 0 %></h3>
                            <p class="text-muted mb-0">竞赛总数</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card text-center">
                        <div class="card-body">
                            <h3 class="text-success">-</h3>
                            <p class="text-muted mb-0">队伍总数</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card text-center">
                        <div class="card-body">
                            <h3 class="text-info">-</h3>
                            <p class="text-muted mb-0">作品总数</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="mb-0">竞赛管理</h3>
                <a href="${pageContext.request.contextPath}/competition?action=add" class="btn btn-primary">
                    + 发布新竞赛
                </a>
            </div>

        <% } else if (sessionUser != null && isJudge) { %>
            <!-- 评委首页 -->
            <h2 class="mb-4">评分工作台</h2>
            <div class="alert alert-info">
                <strong>提示：</strong> 评分功能正在开发中，敬请期待
            </div>

        <% } else { %>
            <!-- 队员/未登录用户首页 -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="mb-0">正在进行的竞赛</h2>
            </div>
        <% } %>

        <!-- 竞赛列表（管理员、队员、未登录用户都显示） -->
        <% if (competitions != null && !competitions.isEmpty()) { %>
            <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
                <% for (Competition comp : competitions) {
                    String statusClass = "";
                    String statusText = "";
                    if (comp.getStatus() == 1) {
                        statusClass = "status-ongoing";
                        statusText = "进行中";
                    } else if (comp.getStatus() == 0) {
                        statusClass = "status-upcoming";
                        statusText = "未开始";
                    } else {
                        statusClass = "status-ended";
                        statusText = "已结束";
                    }
                %>
                <div class="col">
                    <div class="card competition-card position-relative">
                        <span class="status-badge <%= statusClass %>"><%= statusText %></span>
                        <div class="card-body">
                            <h5 class="card-title"><%= comp.getName() %></h5>
                            <p class="card-text text-muted"><%= comp.getDescription() != null ? comp.getDescription() : "暂无描述" %></p>
                            <div class="d-flex justify-content-between align-items-center mt-3">
                                <small class="text-muted">
                                    <%= comp.getYear() != null ? comp.getYear() + "年" : "待定" %>
                                </small>
                                <a href="${pageContext.request.contextPath}/competition?action=detail&id=<%= comp.getCompetitionId() %>"
                                   class="btn btn-sm btn-outline-primary">查看详情</a>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="text-center py-5">
                <p class="text-muted">暂无竞赛信息</p>
                <% if (isAdmin) { %>
                    <a href="${pageContext.request.contextPath}/competition?action=add" class="btn btn-primary">发布第一个竞赛</a>
                <% } %>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
