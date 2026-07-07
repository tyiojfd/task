<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    Work work = (Work) request.getAttribute("work");
    Team team = (Team) request.getAttribute("team");
    Competition competition = (Competition) request.getAttribute("competition");
    if (work == null) {
        response.sendRedirect(request.getContextPath() + "/work?action=myWorks");
        return;
    }

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy年MM月dd日 HH:mm");
    String statusText = work.getStatus() == 2 ? "已提交" : (work.getStatus() == 3 ? "已评分" : "草稿");
    String statusClass = work.getStatus() == 2 ? "success" : (work.getStatus() == 3 ? "primary" : "secondary");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= work.getTitle() %> - 作品详情</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root { --primary: #6C5CE7; --primary-light: #A29BFE; --accent: #FD79A8; --dark: #2D3436; --gray: #636E72; }
        body { background: linear-gradient(135deg, #F8F9FA 0%, #E8ECF1 100%); min-height: 100vh; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif; }
        .navbar { background: var(--dark) !important; box-shadow: 0 2px 12px rgba(0,0,0,0.15); }
        .navbar-brand { font-weight: 700; }
        .detail-card { background: white; border-radius: 16px; box-shadow: 0 2px 16px rgba(108,92,231,0.06); overflow: hidden; }
        .work-image { width: 100%; max-height: 500px; object-fit: contain; background: #F8F9FA; cursor: pointer; }
        .info-section { padding: 2rem; }
        .info-section h3 { font-weight: 700; color: var(--dark); }
        .info-label { font-size: 0.8rem; color: var(--gray); }
        .info-value { font-weight: 600; color: var(--dark); }
        .back-link { color: var(--gray); text-decoration: none; font-weight: 600; }
        .back-link:hover { color: var(--primary); }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <% request.setAttribute("activePage", "myWorks"); %>
    <%@ include file="navbar.jsp" %>
    <div class="container mt-4">
        <a href="${pageContext.request.contextPath}/work?action=myWorks" class="back-link mb-3 d-inline-block">
            <i class="fas fa-arrow-left me-1"></i>返回作品列表
        </a>
        <div class="detail-card">
            <div class="row g-0">
                <div class="col-lg-7">
                    <% if (work.getImagePath() != null && !work.getImagePath().isEmpty()) { %>
                        <img src="${pageContext.request.contextPath}<%= work.getImagePath() %>" class="work-image" alt="<%= work.getTitle() %>"
                             onclick="window.open(this.src, "_blank")">
                    <% } else { %>
                        <div class="work-image d-flex align-items-center justify-content-center" style="color:#B2BEC3;">
                            <i class="fas fa-image fa-5x"></i>
                        </div>
                    <% } %>
                </div>
                <div class="col-lg-5">
                    <div class="info-section">
                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <h3><%= work.getTitle() %></h3>
                            <span class="badge bg-<%= statusClass %>" style="font-size:0.85rem;"><%= statusText %></span>
                        </div>
                        <p class="text-muted mb-4"><%= work.getDescription() != null && !work.getDescription().isEmpty() ? work.getDescription() : "暂无描述" %></p>
                        <hr>
                        <div class="row mb-3">
                            <div class="col-6 mb-2">
                                <div class="info-label">队伍名称</div>
                                <div class="info-value"><%= team != null ? team.getTeamName() : "未知" %></div>
                            </div>
                            <div class="col-6 mb-2">
                                <div class="info-label">参赛竞赛</div>
                                <div class="info-value"><%= competition != null ? competition.getName() : "未知" %></div>
                            </div>
                            <div class="col-6 mb-2">
                                <div class="info-label">提交时间</div>
                                <div class="info-value"><%= work.getSubmitTime() != null ? work.getSubmitTime().format(dtf) : "未提交" %></div>
                            </div>
                            <div class="col-6 mb-2">
                                <div class="info-label">最后更新</div>
                                <div class="info-value"><%= work.getUpdateTime() != null ? work.getUpdateTime().format(dtf) : "无" %></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
