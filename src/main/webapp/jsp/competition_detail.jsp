<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Competition competition = (Competition) request.getAttribute("competition");
    Boolean hasJoined = (Boolean) request.getAttribute("hasJoined");
    Team userTeam = (Team) request.getAttribute("userTeam");
    User sessionUser = (User) session.getAttribute("user");
    if (hasJoined == null) hasJoined = false;

    // 检查用户角色
    boolean isAdmin = false;
    boolean isJudge = false;
    if (sessionUser != null) {
        List<Role> userRoles = (List<Role>) session.getAttribute("roles");
        if (userRoles != null) {
            for (Role role : userRoles) {
                if ("管理员".equals(role.getRoleName())) {
                    isAdmin = true;
                }
                if ("评委".equals(role.getRoleName())) {
                    isJudge = true;
                }
            }
        }
    }
    boolean canParticipate = sessionUser != null && !isAdmin && !isJudge;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>竞赛详情 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .info-row { padding: 15px 0; border-bottom: 1px solid #eee; }
        .info-label { font-weight: bold; color: #666; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/index">海报竞赛系统</a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/competition?action=list">竞赛列表</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <% if (competition != null) { %>
            <div class="card">
                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                    <h4 class="mb-0"><%= competition.getName() %></h4>
                    <span class="badge bg-light text-dark">
                        <% if (competition.getStatus() == 1) { %>报名中<% }
                           else if (competition.getStatus() == 2) { %>进行中<% }
                           else if (competition.getStatus() == 3) { %>已结束<% }
                           else { %>已取消<% } %>
                    </span>
                </div>
                <div class="card-body">
                    <div class="info-row">
                        <span class="info-label">竞赛ID：</span>
                        <span><%= competition.getCompetitionId() %></span>
                    </div>

                    <div class="info-row">
                        <span class="info-label">年度：</span>
                        <span><%= competition.getYear() %>年</span>
                    </div>

                    <% if (competition.getTheme() != null) { %>
                    <div class="info-row">
                        <span class="info-label">主题：</span>
                        <span><%= competition.getTheme() %></span>
                    </div>
                    <% } %>

                    <div class="info-row">
                        <span class="info-label">描述：</span>
                        <p class="mt-2"><%= competition.getDescription() != null ? competition.getDescription() : "暂无描述" %></p>
                    </div>

                    <div class="info-row">
                        <span class="info-label">提交截止时间：</span>
                        <span><%= competition.getSubmitDeadline() != null ? competition.getSubmitDeadline().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) : "未设置" %></span>
                    </div>

                    <div class="info-row">
                        <span class="info-label">最大队伍人数：</span>
                        <span><%= competition.getMaxTeamSize() %>人</span>
                    </div>

                    <div class="info-row">
                        <span class="info-label">创建时间：</span>
                        <span><%= competition.getCreateTime() != null ? competition.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) : "未知" %></span>
                    </div>

                    <!-- 竞赛统计 -->
                    <% java.util.Map stats = (java.util.Map) request.getAttribute("stats");
                       if (stats != null) { %>
                    <div class="info-row">
                        <span class="info-label">参赛统计：</span>
                        <span><span class="badge bg-primary me-2"><%= stats.get("teamCount") %> 支队伍</span>
                              <span class="badge bg-success"><%= stats.get("workCount") %> 件作品</span></span>
                    </div>
                    <% } %>

                    <!-- 参赛状态区域 -->
                    <div class="mt-4 p-3 bg-light rounded">
                        <% if (sessionUser == null) { %>
                            <p class="mb-2">请先登录后参加竞赛</p>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">立即登录</a>
                        <% } else if (!canParticipate) { %>
                            <h5 class="text-secondary">当前角色无需参赛</h5>
                            <p class="text-muted mb-0">管理员用于系统管理，评委用于评分，不参与创建或加入参赛队伍。</p>
                        <% } else if (hasJoined) { %>
                            <h5 class="text-success">✓ 您已参加此竞赛</h5>
                            <p class="mb-2">队伍：<%= userTeam != null ? userTeam.getTeamName() : "未知" %></p>
                            <a href="${pageContext.request.contextPath}/team?action=detail&id=<%= userTeam != null ? userTeam.getTeamId() : "" %>"
                               class="btn btn-primary me-2">查看队伍</a>
                            <a href="${pageContext.request.contextPath}/work?action=myWorks" class="btn btn-success">查看作品</a>
                        <% } else { %>
                            <h5>参加此竞赛</h5>
                            <p class="text-muted mb-3">参加竞赛需要创建或加入队伍</p>
                            <a href="${pageContext.request.contextPath}/team?action=create&competitionId=<%= competition.getCompetitionId() %>"
                               class="btn btn-primary me-2">创建队伍</a>
                            <a href="${pageContext.request.contextPath}/competition?action=list" class="btn btn-outline-primary">返回竞赛列表后选择参赛</a>
                        <% } %>
                    </div>

                    <div class="mt-4 d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/competition?action=list" class="btn btn-secondary">返回列表</a>
                        <% if (isAdmin) { %>
                            <a href="${pageContext.request.contextPath}/competition?action=edit&id=<%= competition.getCompetitionId() %>" class="btn btn-primary">编辑竞赛</a>
                            <% if (competition.getStatus() != 0) { %>
                            <button type="button" class="btn btn-warning" onclick="cancelCompetition(<%= competition.getCompetitionId() %>)">取消竞赛</button>
                            <% } %>
                            <button type="button" class="btn btn-danger" onclick="deleteCompetition(<%= competition.getCompetitionId() %>)">删除竞赛</button>
                        <% } %>
                    </div>
                </div>
            </div>
        <% } else { %>
            <div class="alert alert-danger">竞赛不存在</div>
            <a href="${pageContext.request.contextPath}/competition?action=list" class="btn btn-primary">返回列表</a>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function deleteCompetition(id) {
            if (confirm('确定要删除这个竞赛吗？此操作不可恢复！')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/competition?action=delete&id=' + id;
                document.body.appendChild(form);
                form.submit();
            }
        }

        function cancelCompetition(id) {
            if (confirm('确定要取消这个竞赛吗？取消后参赛者将不能继续操作。')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/competition?action=cancel&id=' + id;
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>
