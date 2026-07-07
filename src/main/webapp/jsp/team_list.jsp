<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.TeamMember" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
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
    <style>
        :root {
            --primary: #6C5CE7;
            --primary-light: #A29BFE;
            --accent: #FD79A8;
            --dark: #2D3436;
            --gray: #636E72;
            --light-bg: #F8F9FA;
            --card-shadow: 0 2px 16px rgba(108, 92, 231, 0.06);
        }

        body {
            background: linear-gradient(135deg, #F8F9FA 0%, #E8ECF1 100%);
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
        }

        .navbar { background: var(--dark) !important; box-shadow: 0 2px 12px rgba(0,0,0,0.15); }
        .navbar-brand { font-weight: 700; letter-spacing: 0.5px; }
        .navbar-brand i { color: var(--primary-light); margin-right: 6px; }
        .nav-link { font-size: 0.9rem; transition: color 0.2s; }
        .nav-link:hover { color: var(--primary-light) !important; }
        .nav-link.active { color: var(--primary-light) !important; font-weight: 600; }

        /* ── 页面标题区 ── */
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin: 2rem 0 1.5rem;
        }
        .page-header h2 { font-weight: 700; color: var(--dark); margin: 0; }
        .page-header h2 i { color: var(--primary); }

        .btn-create {
            background: linear-gradient(135deg, var(--primary) 0%, #8B7CF6 100%);
            border: none; border-radius: 12px;
            padding: 0.65rem 1.6rem;
            font-weight: 600; font-size: 0.95rem;
            color: white;
            transition: all 0.3s;
            box-shadow: 0 4px 14px rgba(108, 92, 231, 0.3);
        }
        .btn-create:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(108, 92, 231, 0.45);
            color: white;
        }

        /* ── 统计卡片 ── */
        .stats-row { margin-bottom: 1.5rem; }
        .stat-card {
            background: white;
            border-radius: 16px;
            padding: 1.2rem 1.5rem;
            box-shadow: var(--card-shadow);
            display: flex;
            align-items: center;
            gap: 14px;
            transition: transform 0.2s;
        }
        .stat-card:hover { transform: translateY(-2px); }
        .stat-icon {
            width: 50px; height: 50px;
            border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem;
        }
        .stat-value { font-size: 1.6rem; font-weight: 700; color: var(--dark); line-height: 1.2; }
        .stat-label { font-size: 0.8rem; color: var(--gray); }

        /* ── 队伍卡片 ── */
        .team-grid-card {
            background: white;
            border-radius: 20px;
            box-shadow: var(--card-shadow);
            overflow: hidden;
            transition: all 0.3s;
            cursor: pointer;
            border: none;
            height: 100%;
        }
        .team-grid-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 36px rgba(108, 92, 231, 0.14);
        }
        .team-card-cover {
            height: 100px;
            position: relative;
            display: flex;
            align-items: flex-end;
            padding: 1rem 1.2rem;
        }
        .team-card-cover .team-badge-status {
            position: absolute;
            top: 14px; right: 14px;
        }
        .team-card-cover .team-avatar {
            width: 56px; height: 56px;
            border-radius: 16px;
            border: 3px solid white;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem;
            color: white;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        .team-card-body { padding: 1rem 1.2rem 1.2rem; }
        .team-card-body h5 { font-weight: 700; font-size: 1.05rem; margin-bottom: 0.35rem; color: var(--dark); }

        .member-avatars {
            display: flex;
            align-items: center;
            gap: 2px;
            margin-top: 0.5rem;
        }
        .member-avatar-sm {
            width: 30px; height: 30px;
            border-radius: 50%;
            border: 2px solid white;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.65rem;
            color: white;
            font-weight: 600;
            box-shadow: 0 1px 4px rgba(0,0,0,0.1);
            margin-left: -6px;
        }
        .member-avatar-sm:first-child { margin-left: 0; }
        .member-count-badge {
            font-size: 0.75rem;
            color: var(--gray);
            margin-left: 6px;
        }

        /* ── 空状态 ── */
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 20px;
            box-shadow: var(--card-shadow);
        }
        .empty-illustration {
            width: 160px; height: 160px;
            margin: 0 auto 1.5rem;
            background: linear-gradient(135deg, #F0EDFF 0%, #EDE9FE 100%);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 4rem;
            color: var(--primary-light);
        }
        .empty-state h4 { font-weight: 700; color: var(--dark); }
        .empty-state p { color: var(--gray); max-width: 400px; margin: 0 auto 1.5rem; }

        /* ── 搜索栏 ── */
        .search-box {
            position: relative;
            margin-bottom: 1.5rem;
        }
        .search-box input {
            border: 2px solid #EAEEF2;
            border-radius: 14px;
            padding: 0.7rem 1rem 0.7rem 2.8rem;
            font-size: 0.95rem;
            transition: all 0.25s;
            background: white;
        }
        .search-box input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(108, 92, 231, 0.08);
        }
        .search-box .search-icon {
            position: absolute;
            left: 14px; top: 50%;
            transform: translateY(-50%);
            color: var(--gray);
            font-size: 1rem;
        }

        /* ── alert ── */
        .alert { border-radius: 14px; border: none; }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <% request.setAttribute("activePage", "myTeams"); %>
    <%@ include file="navbar.jsp" %>

    <div class="container">
        <!-- ═══════════ 页面标题 ═══════════ -->
        <div class="page-header">
            <h2><i class="fas fa-users me-2"></i>我的队伍</h2>
            <a href="${pageContext.request.contextPath}/team?action=create" class="btn-create text-decoration-none">
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
                    <div class="stat-icon" style="background: #EDE9FE; color: var(--primary);">
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
                    <div class="stat-icon" style="background: #E8F8F5; color: #00CEC9;">
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
                    <div class="stat-icon" style="background: #FFF3E0; color: #F39C12;">
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
                    <div class="stat-icon" style="background: #FCE4EC; color: #FD79A8;">
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
        <div class="search-box">
            <span class="search-icon"><i class="fas fa-search"></i></span>
            <input type="text" class="form-control" id="teamSearch" placeholder="搜索队伍名称或竞赛...">
        </div>

        <!-- ═══════════ 队伍列表 ═══════════ -->
        <% if (myTeams != null && !myTeams.isEmpty()) { %>
            <div class="row g-3" id="teamGrid">
                <%  String[][] cardColors = {
                        {"#6C5CE7", "#A29BFE"},
                        {"#FD79A8", "#FDCB6E"},
                        {"#00CEC9", "#81ECEC"},
                        {"#E17055", "#FAB1A0"},
                        {"#74B9FF", "#A0D2FF"},
                        {"#636E72", "#B2BEC3"}
                    };
                    int colorIdx = 0;
                    for (Team team : myTeams) {
                        String[] colors = cardColors[colorIdx % cardColors.length];
                        String compName = competitionNames != null ? competitionNames.getOrDefault(team.getTeamId(), "竞赛 #" + team.getCompetitionId()) : "竞赛 #" + team.getCompetitionId();
                        int memberCount = memberCounts != null ? memberCounts.getOrDefault(team.getTeamId(), 0) : 0;
                        String statusText = team.getStatus() == 1 ? "组建中" : team.getStatus() == 2 ? "已报名" : "已取消";
                        String statusClass = team.getStatus() == 1 ? "warning" : team.getStatus() == 2 ? "success" : "secondary";
                        Integer myRole = myTeamRoles != null ? myTeamRoles.get(team.getTeamId()) : null;
                        boolean isMyTeam = myRole != null && myRole == 1;
                        List<TeamMember> members = teamMembers != null ? teamMembers.get(team.getTeamId()) : null;
                %>
                    <div class="col-lg-4 col-md-6 team-item" data-name="<%= team.getTeamName().toLowerCase() %> <%= compName.toLowerCase() %>">
                        <div class="card team-grid-card" onclick="window.location.href='${pageContext.request.contextPath}/team?action=detail&id=<%= team.getTeamId() %>'">
                            <div class="team-card-cover" style="background: linear-gradient(135deg, <%= colors[0] %> 0%, <%= colors[1] %> 100%);">
                                <span class="badge bg-<%= statusClass %> team-badge-status" style="font-size:0.75rem"><%= statusText %></span>
                                <div class="team-avatar" style="background: rgba(255,255,255,0.2);">
                                    <i class="fas fa-users"></i>
                                </div>
                            </div>
                            <div class="team-card-body">
                                <h5>
                                    <%= team.getTeamName() %>
                                    <% if (isMyTeam) { %>
                                        <span class="badge rounded-pill" style="background:var(--primary); font-size:0.65rem;">队长</span>
                                    <% } else { %>
                                        <span class="badge rounded-pill" style="background:#00CEC9; font-size:0.65rem;">队员</span>
                                    <% } %>
                                </h5>
                                <p class="text-muted small mb-2">
                                    <i class="fas fa-trophy me-1" style="color:<%= colors[0] %>"></i><%= compName %>
                                </p>
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="member-avatars">
                                        <% if (members != null && !members.isEmpty()) {
                                            int shown = 0;
                                            for (TeamMember m : members) {
                                                if (shown >= 4) break;
                                                String name = userNames != null ? userNames.get(m.getUserId()) : "?";
                                                String initial = name != null && !name.isEmpty() ? name.substring(0, 1) : "?";
                                                String[] avatarColors = {"#6C5CE7", "#FD79A8", "#00CEC9", "#F39C12"};
                                        %>
                                            <span class="member-avatar-sm" style="background:<%= avatarColors[shown % 4] %>" title="<%= name %>"><%= initial %></span>
                                        <%      shown++;
                                            }
                                            if (memberCount > 4) {
                                        %>
                                            <span class="member-avatar-sm" style="background:#B2BEC3">+<%= memberCount - 4 %></span>
                                        <%  }
                                        } %>
                                        <span class="member-count-badge"><%= memberCount %> 人</span>
                                    </div>
                                    <small class="text-muted">
                                        <%= team.getCreateTime() != null ? team.getCreateTime().format(DateTimeFormatter.ofPattern("MM/dd")) : "" %>
                                    </small>
                                </div>
                            </div>
                        </div>
                    </div>
                <%      colorIdx++;
                    }
                %>
            </div>
        <% } else { %>
            <!-- 空状态 -->
            <div class="empty-state">
                <div class="empty-illustration">
                    <i class="fas fa-user-plus"></i>
                </div>
                <h4>还没有队伍</h4>
                <p>创建你的第一支队伍，邀请志同道合的队友一起参赛吧</p>
                <a href="${pageContext.request.contextPath}/team?action=create" class="btn-create text-decoration-none">
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
