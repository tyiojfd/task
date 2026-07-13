<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.CompetitionCategory" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
<%
    Competition competition = (Competition) request.getAttribute("competition");
    Boolean hasJoined = (Boolean) request.getAttribute("hasJoined");
    Team userTeam = (Team) request.getAttribute("userTeam");
    @SuppressWarnings("unchecked")
    List<CompetitionCategory> categories = (List<CompetitionCategory>) request.getAttribute("categories");
    @SuppressWarnings("unchecked")
    List<Team> availableTeams = (List<Team>) request.getAttribute("availableTeams");
    @SuppressWarnings("unchecked")
    Map<Integer, Integer> teamMemberCounts = (Map<Integer, Integer>) request.getAttribute("teamMemberCounts");
    @SuppressWarnings("unchecked")
    Set<Integer> appliedTeamIds = (Set<Integer>) request.getAttribute("appliedTeamIds");
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
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body>
    <%
    request.setAttribute("activeNav", "competitions");
%>
<%@ include file="includes/navbar.jspf" %>

    <div class="container mt-4">
        <% if (competition != null) { %>
            <div class="card">
                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                    <h4 class="mb-0"><%= HtmlEscaper.escape(competition.getName()) %></h4>
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
                        <span><%= HtmlEscaper.escape(competition.getTheme()) %></span>
                    </div>
                    <% } %>

                    <div class="info-row">
                        <span class="info-label">描述：</span>
                        <p class="mt-2"><%= HtmlEscaper.escape(competition.getDescription() != null ? competition.getDescription() : "暂无描述") %></p>
                    </div>

                    <div class="info-row">
                        <span class="info-label">提交截止时间：</span>
                        <span><%= competition.getSubmitDeadline() != null ? competition.getSubmitDeadline().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) : "未设置" %></span>
                    </div>

                    <div class="info-row">
                        <span class="info-label">最大队伍人数：</span>
                        <span><%= competition.getMaxTeamSize() %>人</span>
                    </div>

                    <% if (categories != null && !categories.isEmpty()) { %>
                    <div class="info-row">
                        <span class="info-label">竞赛方向：</span>
                        <div class="mt-2">
                            <% for (CompetitionCategory cat : categories) { %>
                                <span class="badge bg-info text-dark me-2 mb-2"><%= HtmlEscaper.escape(cat.getCategoryName()) %></span>
                            <% } %>
                        </div>
                    </div>
                    <% } %>

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
                            <p class="mb-2">队伍：<%= HtmlEscaper.escape(userTeam != null ? userTeam.getTeamName() : "未知") %></p>
                            <a href="${pageContext.request.contextPath}/team?action=detail&id=<%= userTeam != null ? userTeam.getTeamId() : "" %>"
                               class="btn btn-primary me-2">查看队伍</a>
                            <a href="${pageContext.request.contextPath}/work?action=myWorks" class="btn btn-success">查看作品</a>
                        <% } else { %>
                            <h5>参加此竞赛</h5>
                            <% if (competition.getStatus() != null && competition.getStatus() == 1) { %>
                                <p class="text-muted mb-3">报名阶段可以创建队伍，或申请加入其他正在组建的队伍。</p>
                                <a href="${pageContext.request.contextPath}/team?action=create&competitionId=<%= competition.getCompetitionId() %>"
                                   class="btn btn-primary me-2">创建队伍</a>
                                <button type="button" class="btn btn-outline-primary me-2" data-bs-toggle="modal" data-bs-target="#joinTeamModal">
                                    <i class="fas fa-search me-1"></i>搜索并加入队伍
                                </button>
                            <% } else { %>
                                <p class="text-muted mb-0">当前竞赛不在报名阶段，不能创建或加入队伍。</p>
                            <% } %>
                        <% } %>
                    </div>

                    <% if (competition.getStatus() != null && competition.getStatus() == 3) { %>
                    <div class="mt-4 p-3 border rounded bg-white">
                        <h5><i class="fas fa-images me-2"></i>作品展厅</h5>
                        <p class="text-muted mb-2">比赛已结束，参赛者可以查看本竞赛其他队伍的作品。</p>
                        <a href="${pageContext.request.contextPath}/work?action=competitionWorks&competitionId=<%= competition.getCompetitionId() %>" class="btn btn-outline-primary">查看作品展厅</a>
                    </div>
                    <% } %>

                    <% if (canParticipate && !hasJoined && competition.getStatus() != null && competition.getStatus() == 1 && availableTeams != null && !availableTeams.isEmpty()) { %>
                    <div class="mt-4 p-3 border rounded bg-white">
                        <h5><i class="fas fa-user-plus me-2"></i>申请加入队伍</h5>
                        <p class="text-muted">以下队伍正在组建中，可以申请加入。</p>
                        <% for (Team t : availableTeams) {
                            int memberCount = teamMemberCounts != null && teamMemberCounts.get(t.getTeamId()) != null ? teamMemberCounts.get(t.getTeamId()) : 0;
                            boolean applied = appliedTeamIds != null && appliedTeamIds.contains(t.getTeamId());
                        %>
                        <div class="d-flex justify-content-between align-items-center border rounded p-2 mb-2 flex-wrap gap-2">
                            <div><strong><%= HtmlEscaper.escape(t.getTeamName()) %></strong><span class="text-muted ms-2"><%= memberCount %>/<%= competition.getMaxTeamSize() %> 人</span></div>
                            <% if (applied) { %>
                                <button class="btn btn-sm btn-secondary" disabled>已申请</button>
                            <% } else { %>
                                <form method="post" action="${pageContext.request.contextPath}/application?action=apply" class="d-flex gap-2">
                                    <input type="hidden" name="teamId" value="<%= t.getTeamId() %>">
                                    <input type="text" name="message" class="form-control form-control-sm" placeholder="申请留言" maxlength="200">
                                    <button class="btn btn-sm btn-primary" type="submit">申请加入</button>
                                </form>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                    <% } %>

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

    <!-- ═══════════ 搜索并加入队伍 Modal ═══════════ -->
    <div class="modal fade" id="joinTeamModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content" style="border-radius:16px; border:none;">
                <div class="modal-header" style="background:linear-gradient(135deg, var(--primary), #8B7CF6); color:white; border-radius:16px 16px 0 0;">
                    <h5 class="modal-title"><i class="fas fa-user-plus me-2"></i>搜索并加入队伍</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="input-group mb-3">
                        <input type="text" class="form-control" id="teamSearchInput" placeholder="输入队伍名称搜索..." onkeyup="searchTeams()">
                        <button class="btn btn-primary" onclick="searchTeams()"><i class="fas fa-search me-1"></i>搜索</button>
                    </div>
                    <div id="teamSearchResults" class="list-group" style="max-height:360px;overflow-y:auto">
                        <div class="text-center text-muted py-4">
                            <i class="fas fa-search fa-2x mb-2"></i>
                            <p>输入队伍名称开始搜索</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function searchTeams() {
            var keyword = document.getElementById('teamSearchInput').value.trim();
            var container = document.getElementById('teamSearchResults');
            if (!keyword) { container.innerHTML = '<div class="text-center text-muted py-4"><i class="fas fa-search fa-2x mb-2"></i><p>输入队伍名称开始搜索</p></div>'; return; }
            container.innerHTML = '<div class="text-center py-4"><div class="spinner-border text-primary" role="status"></div></div>';
            var xhr = new XMLHttpRequest();
            xhr.open('GET', '${pageContext.request.contextPath}/team?action=searchTeam&keyword=' + encodeURIComponent(keyword) + '&competitionId=<%= competition.getCompetitionId() %>');
            xhr.onload = function() {
                try {
                    var teams = JSON.parse(xhr.responseText);
                    if (!teams.length) { container.innerHTML = '<div class="text-center text-muted py-4"><i class="fas fa-users-slash fa-2x mb-2"></i><p>未找到匹配的队伍</p></div>'; return; }
                    container.innerHTML = '';
                    teams.forEach(function(t) {
                        var item = document.createElement('div');
                        item.className = 'list-group-item d-flex justify-content-between align-items-center flex-wrap gap-2';
                        var info = document.createElement('div');
                        var name = document.createElement('strong');
                        name.textContent = t.teamName || '未命名队伍';
                        var competitionName = document.createElement('small');
                        competitionName.className = 'text-muted ms-2';
                        competitionName.textContent = t.competitionName || '';
                        var count = document.createElement('small');
                        count.className = 'text-muted';
                        count.textContent = (t.memberCount || 0) + '/' + (t.maxTeamSize || 0) + ' 人';
                        info.appendChild(name);
                        info.appendChild(competitionName);
                        info.appendChild(document.createElement('br'));
                        info.appendChild(count);
                        var form = document.createElement('form');
                        form.method = 'post';
                        form.action = '${pageContext.request.contextPath}/application?action=apply';
                        form.className = 'd-flex gap-2';
                        form.onsubmit = function() { return confirm('确认申请加入「' + (t.teamName || '该队伍') + '」吗？'); };
                        var teamId = document.createElement('input');
                        teamId.type = 'hidden'; teamId.name = 'teamId'; teamId.value = t.teamId;
                        var message = document.createElement('input');
                        message.type = 'hidden'; message.name = 'message'; message.value = '';
                        var button = document.createElement('button');
                        button.className = 'btn btn-sm btn-primary'; button.type = 'submit'; button.textContent = '申请加入';
                        form.appendChild(teamId); form.appendChild(message); form.appendChild(button);
                        item.appendChild(info); item.appendChild(form); container.appendChild(item);
                    });
                } catch(e) { container.innerHTML = '<div class="text-center text-danger py-4">搜索出错，请重试</div>'; }
            };
            xhr.send();
        }
    </script>
</body>
</html>
