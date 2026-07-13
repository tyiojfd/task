<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.TeamMember" %>
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
    // 检查用户角色
    @SuppressWarnings("unchecked")
    List<Role> userRoles = (List<Role>) session.getAttribute("roles");
    boolean isAdmin = false;
    boolean isJudge = false;
    if (userRoles != null) {
        for (Role role : userRoles) {
            if ("管理员".equals(role.getRoleName())) isAdmin = true;
            if ("评委".equals(role.getRoleName())) isJudge = true;
        }
    }

    @SuppressWarnings("unchecked")
    List<Team> myTeams = (List<Team>) request.getAttribute("myTeams");
    @SuppressWarnings("unchecked")
    Map<Integer, String> competitionNames = (Map<Integer, String>) request.getAttribute("competitionNames");
    @SuppressWarnings("unchecked")
    Map<Integer, Integer> memberCounts = (Map<Integer, Integer>) request.getAttribute("memberCounts");
    @SuppressWarnings("unchecked")
    Map<Integer, List<TeamMember>> teamMembers = (Map<Integer, List<TeamMember>>) request.getAttribute("teamMembers");
    @SuppressWarnings("unchecked")
    Map<Integer, String> userNames = (Map<Integer, String>) request.getAttribute("userNames");
    @SuppressWarnings("unchecked")
    Map<Integer, String> userAvatars = (Map<Integer, String>) request.getAttribute("userAvatars");
    @SuppressWarnings("unchecked")
    Map<Integer, Integer> myTeamRoles = (Map<Integer, Integer>) request.getAttribute("myTeamRoles");

    // 统计数据
    int totalTeams = myTeams != null ? myTeams.size() : 0;
    int createdTeams = 0;
    int joinedTeams = 0;
    int activeTeams = 0;
    int totalMembers = 0;
    if (myTeams != null) {
        for (Team t : myTeams) {
            if (t.getStatus() != null && t.getStatus() != 0) activeTeams++;
            Integer count = memberCounts != null ? memberCounts.get(t.getTeamId()) : null;
            if (count != null) totalMembers += count;
            Integer role = myTeamRoles != null ? myTeamRoles.get(t.getTeamId()) : null;
            if (role != null && role == 1) createdTeams++;
            else joinedTeams++;
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的队伍 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-catalog app-page-team-list">
    <!-- 导航栏 -->
    <%
    request.setAttribute("activeNav", "teams");
%>
<%@ include file="includes/navbar.jspf" %>

    <div class="container">
        <!-- ═══════════ 页面标题 ═══════════ -->
        <div class="page-header">
            <h2><i class="fas fa-users me-2"></i>我的队伍</h2>
            <a href="${pageContext.request.contextPath}/team?action=create" class="btn btn-primary">
                <i class="fas fa-plus me-2"></i>创建队伍
            </a>
        </div>

        <!-- 提示消息 -->
        <% String msg = request.getParameter("msg"); %>
        <% if ("invite_success".equals(msg)) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>邀请发送成功！
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        <% String error = request.getParameter("error"); %>
        <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i><%= error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <!-- ═══════════ 统计概览 ═══════════ -->
        <div class="row stats-row g-3">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:#c9e3f5; color:var(--app-blue);">
                        <i class="fas fa-flag"></i>
                    </div>
                    <div>
                        <div class="stat-value"><%= totalTeams %></div>
                        <div class="stat-label">全部队伍</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:#cdeee3; color:var(--app-sea);">
                        <i class="fas fa-crown"></i>
                    </div>
                    <div>
                        <div class="stat-value"><%= createdTeams %></div>
                        <div class="stat-label">我创建的</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:#fdf3d4; color:#a07e25;">
                        <i class="fas fa-user-plus"></i>
                    </div>
                    <div>
                        <div class="stat-value"><%= joinedTeams %></div>
                        <div class="stat-label">我加入的</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:var(--app-pink); color:#8e3448;">
                        <i class="fas fa-user-friends"></i>
                    </div>
                    <div>
                        <div class="stat-value"><%= totalMembers %></div>
                        <div class="stat-label">队员总数</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 搜索栏 -->
        <div class="app-toolbar">
            <div class="toolbar-field toolbar-field-wide">
                <label for="teamSearch">搜索队伍</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-search"></i></span>
                    <input type="text" class="form-control" id="teamSearch" placeholder="队伍名称或竞赛...">
                </div>
            </div>
        </div>

        <!-- ═══════════ 队伍列表 ═══════════ -->
        <% if (myTeams != null && !myTeams.isEmpty()) { %>
            <div class="row g-3" id="teamGrid">
                <%  for (Team team : myTeams) {
                        String compName = competitionNames != null ? competitionNames.getOrDefault(team.getTeamId(), "竞赛 #" + team.getCompetitionId()) : "竞赛 #" + team.getCompetitionId();
                        int memberCount = memberCounts != null ? memberCounts.getOrDefault(team.getTeamId(), 0) : 0;
                        String statusText = team.getStatus() == 1 ? "组建中" : team.getStatus() == 2 ? "已报名" : "已取消";
                        String statusClass = team.getStatus() == 1 ? "warning" : team.getStatus() == 2 ? "success" : "secondary";
                        String borderClass = team.getStatus() == 1 ? "status-open" : team.getStatus() == 2 ? "status-active" : "status-ended";
                        Integer myRole = myTeamRoles != null ? myTeamRoles.get(team.getTeamId()) : null;
                        boolean isMyTeam = myRole != null && myRole == 1;
                        List<TeamMember> members = teamMembers != null ? teamMembers.get(team.getTeamId()) : null;
                        String[] avatarTokens = {"var(--app-blue)", "var(--app-sea)", "var(--app-yellow)", "var(--app-pink)"};
                %>
                    <div class="col-lg-4 col-md-6 team-item" data-name="<%= HtmlEscaper.escape(team.getTeamName().toLowerCase()) %> <%= HtmlEscaper.escape(compName.toLowerCase()) %>">
                        <div class="competition-card <%= borderClass %>" style="cursor:pointer;" onclick="window.location.href='${pageContext.request.contextPath}/team?action=detail&id=<%= team.getTeamId() %>'">
                            <span class="status-badge badge bg-<%= statusClass %>"><%= statusText %></span>
                            <div class="card-body">
                                <div class="card-title"><%= HtmlEscaper.escape(team.getTeamName()) %></div>
                                <p class="card-text"><i class="fas fa-trophy me-1"></i><%= HtmlEscaper.escape(compName) %></p>
                                <div style="display:flex; align-items:center; gap:6px; margin-bottom:8px;">
                                    <span class="badge rounded-pill" style="background:var(--app-blue); font-size:0.65rem; color:#fff;"><%= isMyTeam ? "队长" : "队员" %></span>
                                    <span style="font-size:0.78rem; color:var(--app-muted);"><%= memberCount %> 人</span>
                                </div>
                                <div class="member-avatars" style="display:flex; align-items:center; gap:0; margin-top:6px;">
                                    <% if (members != null && !members.isEmpty()) {
                                        int shown = 0;
                                        for (TeamMember m : members) {
                                            if (shown >= 4) break;
                                            String name = userNames != null ? userNames.get(m.getUserId()) : "?";
                                            String initial = name != null && !name.isEmpty() ? name.substring(0, 1) : "?";
                                    %>
                                        <% String ava = userAvatars != null ? userAvatars.get(m.getUserId()) : null; %>
                                        <% if (ava != null && !ava.isEmpty()) { %>
                                            <img src="<%= request.getContextPath() + ava %>"
                                                 class="member-avatar-sm" style="object-fit:cover; width:28px; height:28px; border-radius:50%; border:2px solid #fff; margin-left:<%= shown > 0 ? "-6px" : "0" %>;" title="<%= HtmlEscaper.escape(name) %>">
                                        <% } else { %>
                                            <span class="member-avatar-sm" title="<%= HtmlEscaper.escape(name) %>" style="width:28px;height:28px;border-radius:50%;border:2px solid #fff;display:flex;align-items:center;justify-content:center;font-size:0.6rem;color:#fff;font-weight:600;background:<%= avatarTokens[shown % 4] %>; margin-left:<%= shown > 0 ? "-6px" : "0" %>;"><%= HtmlEscaper.escape(initial) %></span>
                                        <% } %>
                                    <%      shown++;
                                        }
                                        if (memberCount > 4) {
                                    %>
                                        <span class="member-avatar-sm" style="width:28px;height:28px;border-radius:50%;border:2px solid #fff;display:flex;align-items:center;justify-content:center;font-size:0.6rem;color:var(--app-muted);font-weight:600;background:var(--app-rule); margin-left:-6px;">+<%= memberCount - 4 %></span>
                                    <%  }
                                    } %>
                                </div>
                                <div style="margin-top:10px; font-size:0.78rem; color:var(--app-muted);">
                                    <i class="far fa-calendar me-1"></i><%= team.getCreateTime() != null ? team.getCreateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) : "" %>
                                </div>
                            </div>
                        </div>
                    </div>
                <%  }
                %>
            </div>
        <% } else { %>
            <!-- 空状态 -->
            <div class="empty-state">
                <i class="fas fa-user-plus" style="font-size:3rem; color:var(--app-blue); margin-bottom:1rem;"></i>
                <h4>还没有队伍</h4>
                <p>创建你的第一支队伍，邀请志同道合的队友一起参赛吧</p>
                <a href="${pageContext.request.contextPath}/team?action=create" class="btn btn-primary">
                    <i class="fas fa-plus me-2"></i>立即创建队伍
                </a>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 搜索过滤
        document.getElementById('teamSearch').addEventListener('input', function() {
            const query = this.value.toLowerCase();
            document.querySelectorAll('.team-item').forEach(item => {
                item.style.display = item.dataset.name.includes(query) ? '' : 'none';
            });
        });
    </script>
</body>
</html>
