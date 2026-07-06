<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.TeamMember" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.model.CompetitionCategory" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    Team team = (Team) request.getAttribute("team");
    if (team == null) {
        response.sendRedirect(request.getContextPath() + "/team?action=myTeams");
        return;
    }
    String competitionName = (String) request.getAttribute("competitionName");
    String categoryName = (String) request.getAttribute("categoryName");
    String leaderName = (String) request.getAttribute("leaderName");
    @SuppressWarnings("unchecked")
    List<TeamMember> members = (List<TeamMember>) request.getAttribute("members");
    @SuppressWarnings("unchecked")
    Map<Integer, User> memberUsers = (Map<Integer, User>) request.getAttribute("memberUsers");
    @SuppressWarnings("unchecked")
    List<Competition> competitions = (List<Competition>) request.getAttribute("competitions");
    @SuppressWarnings("unchecked")
    List<CompetitionCategory> categories = (List<CompetitionCategory>) request.getAttribute("categories");

    int memberCount = members != null ? members.size() : 0;
    boolean isLeader = team.getLeaderId().equals(sessionUser.getUserId());

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy年MM月dd日 HH:mm");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= team.getTeamName() %> - 大学生海报设计竞赛系统</title>
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
        }

        body {
            background: linear-gradient(135deg, #F8F9FA 0%, #E8ECF1 100%);
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
        }

        .navbar { background: var(--dark) !important; box-shadow: 0 2px 12px rgba(0,0,0,0.15); }
        .navbar-brand { font-weight: 700; }
        .navbar-brand i { color: var(--primary-light); margin-right: 6px; }
        .nav-link { font-size: 0.9rem; transition: color 0.2s; }
        .nav-link:hover { color: var(--primary-light) !important; }
        .nav-link.active { color: var(--primary-light) !important; font-weight: 600; }

        /* ── 封面横幅 ── */
        .cover-banner {
            background: linear-gradient(135deg, var(--primary) 0%, #8B7CF6 40%, var(--accent) 100%);
            border-radius: 20px;
            padding: 2rem 2.5rem;
            color: white;
            margin: 2rem 0 1.5rem;
            position: relative;
            overflow: hidden;
        }
        .cover-banner::before {
            content: '';
            position: absolute;
            width: 300px; height: 300px;
            background: rgba(255,255,255,0.06);
            border-radius: 50%;
            top: -100px; right: -60px;
        }
        .cover-banner::after {
            content: '';
            position: absolute;
            width: 150px; height: 150px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%;
            bottom: -40px; left: 30%;
        }
        .cover-content { position: relative; z-index: 1; }
        .team-logo {
            width: 80px; height: 80px;
            border-radius: 20px;
            background: rgba(255,255,255,0.2);
            backdrop-filter: blur(10px);
            display: flex; align-items: center; justify-content: center;
            font-size: 2rem;
            border: 2px solid rgba(255,255,255,0.3);
        }
        .cover-banner h2 { font-weight: 800; }
        .cover-meta { font-size: 0.9rem; opacity: 0.9; }
        .cover-meta i { width: 18px; }

        /* ── Tab 导航 ── */
        .tab-nav {
            display: flex;
            gap: 4px;
            background: white;
            border-radius: 14px;
            padding: 4px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.04);
            margin-bottom: 1.5rem;
        }
        .tab-btn {
            flex: 1;
            padding: 0.65rem 1rem;
            border: none;
            background: transparent;
            border-radius: 11px;
            font-weight: 600;
            font-size: 0.9rem;
            color: var(--gray);
            transition: all 0.25s;
            cursor: pointer;
        }
        .tab-btn.active {
            background: var(--primary);
            color: white;
            box-shadow: 0 3px 10px rgba(108, 92, 231, 0.25);
        }
        .tab-btn:hover:not(.active) { background: #F0EDFF; color: var(--primary); }
        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

        /* ── 信息卡片 ── */
        .info-card {
            background: white;
            border-radius: 18px;
            padding: 1.5rem;
            box-shadow: 0 2px 14px rgba(108, 92, 231, 0.05);
            height: 100%;
        }
        .info-card h6 { font-weight: 700; color: var(--dark); font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px; }
        .info-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 0.6rem 0;
            border-bottom: 1px solid #F1F3F4;
        }
        .info-item:last-child { border-bottom: none; }
        .info-icon {
            width: 38px; height: 38px;
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.9rem;
        }

        /* ── 成员网格 ── */
        .member-grid-card {
            background: white;
            border-radius: 18px;
            padding: 1.8rem;
            box-shadow: 0 2px 14px rgba(108, 92, 231, 0.05);
            text-align: center;
            transition: transform 0.2s, box-shadow 0.2s;
            cursor: default;
        }
        .member-grid-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(108, 92, 231, 0.12);
        }
        .member-grid-avatar {
            width: 72px; height: 72px;
            border-radius: 50%;
            margin: 0 auto 0.8rem;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.8rem;
            font-weight: 700;
            color: white;
        }
        .crown-badge {
            position: absolute;
            top: -4px; right: -4px;
            font-size: 0.8rem;
            color: #F39C12;
        }

        /* ── 操作按钮 ── */
        .action-btn {
            border: none;
            border-radius: 12px;
            padding: 0.7rem 1.2rem;
            font-weight: 600;
            font-size: 0.9rem;
            transition: all 0.25s;
            display: flex;
            align-items: center;
            gap: 8px;
            justify-content: center;
        }
        .btn-invite {
            background: linear-gradient(135deg, #00CEC9, #81ECEC);
            color: white;
            box-shadow: 0 4px 12px rgba(0, 206, 201, 0.3);
        }
        .btn-edit {
            background: linear-gradient(135deg, #F39C12, #FDCB6E);
            color: white;
            box-shadow: 0 4px 12px rgba(243, 156, 18, 0.3);
        }
        .btn-delete {
            background: linear-gradient(135deg, #E17055, #FAB1A0);
            color: white;
            box-shadow: 0 4px 12px rgba(225, 112, 85, 0.3);
        }
        .btn-register {
            background: linear-gradient(135deg, var(--primary), #8B7CF6);
            color: white;
            box-shadow: 0 4px 12px rgba(108, 92, 231, 0.3);
        }
        .action-btn:hover {
            transform: translateY(-2px);
            color: white;
            box-shadow: 0 6px 18px rgba(0,0,0,0.2);
        }

        /* ── alert / breadcrumb ── */
        .breadcrumb { margin-bottom: 0; }
        .breadcrumb-item a { color: var(--primary); text-decoration: none; font-weight: 500; }
        .alert { border-radius: 14px; border: none; }

        /* ── 统计数字 ── */
        .stat-mini { text-align: center; padding: 0.5rem; }
        .stat-mini .number { font-size: 1.5rem; font-weight: 800; color: var(--dark); }
        .stat-mini .label  { font-size: 0.75rem; color: var(--gray); }
    </style>
</head>
<body>
    <!-- ═══════════ 导航栏 ═══════════ -->
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/index">
                <i class="fas fa-palette"></i> 海报竞赛系统
            </a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/index"><i class="fas fa-home"></i> 首页</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/competition?action=list"><i class="fas fa-trophy"></i> 竞赛列表</a></li>
                    <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/team?action=myTeams"><i class="fas fa-users"></i> 我的队伍</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/invitation"><i class="fas fa-envelope"></i> 邀请通知</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/profile"><i class="fas fa-user-circle"></i> 个人中心</a></li>
                    <li class="nav-item"><a class="nav-link text-danger" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> 退出</a></li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container">
        <!-- 面包屑 -->
        <nav class="mt-3" aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/team?action=myTeams"><i class="fas fa-users me-1"></i>我的队伍</a></li>
                <li class="breadcrumb-item active"><%= team.getTeamName() %></li>
            </ol>
        </nav>

        <!-- 提示消息 -->
        <% String msg = request.getParameter("msg"); %>
        <% if ("invite_success".equals(msg)) { %>
            <div class="alert alert-success alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i>邀请发送成功！<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
        <% } else if ("remove_success".equals(msg)) { %>
            <div class="alert alert-success alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i>移除成功！<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
        <% } else if ("register_success".equals(msg)) { %>
            <div class="alert alert-success alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i>报名成功！队伍已正式参赛。<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
        <% } %>
        <% String error = request.getParameter("error"); %>
        <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show"><i class="fas fa-exclamation-circle me-2"></i><%= error %><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
        <% } %>

        <!-- ═══════════ 封面横幅 ═══════════ -->
        <div class="cover-banner">
            <div class="cover-content">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="team-logo">
                        <i class="fas fa-users"></i>
                    </div>
                    <div>
                        <h2 class="mb-1"><%= team.getTeamName() %></h2>
                        <div class="cover-meta">
                            <i class="fas fa-trophy me-1"></i><%= competitionName != null ? competitionName : "未指定竞赛" %>
                            <span class="mx-2">·</span>
                            <i class="fas fa-layer-group me-1"></i><%= categoryName != null ? categoryName : "未指定子类" %>
                        </div>
                    </div>
                    <div class="ms-auto text-end">
                        <% if (team.getStatus() == 1) { %>
                            <span class="badge bg-warning text-dark fs-6">组建中</span>
                        <% } else if (team.getStatus() == 2) { %>
                            <span class="badge bg-success fs-6">已报名</span>
                        <% } else { %>
                            <span class="badge bg-secondary fs-6">已取消</span>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-3">
            <!-- ═══════════ 左侧主内容 ═══════════ -->
            <div class="col-lg-8">
                <!-- Tab 导航 -->
                <div class="tab-nav">
                    <button class="tab-btn active" onclick="switchTab('overview', this)"><i class="fas fa-info-circle me-1"></i>概览</button>
                    <button class="tab-btn" onclick="switchTab('members', this)"><i class="fas fa-user-friends me-1"></i>成员 (<%= memberCount %>)</button>
                    <button class="tab-btn" onclick="switchTab('works', this)"><i class="fas fa-image me-1"></i>作品</button>
                </div>

                <!-- Tab: 概览 -->
                <div class="tab-panel active" id="tab-overview">
                    <div class="info-card mb-3">
                        <h6 class="mb-3">队伍信息</h6>
                        <div class="row g-3">
                            <div class="col-6 col-md-3">
                                <div class="stat-mini">
                                    <div class="number" style="color:var(--primary)"><%= memberCount %></div>
                                    <div class="label">成员人数</div>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="stat-mini">
                                    <div class="number" style="color:#00CEC9"><%= team.getStatus() == 1 ? "组建中" : team.getStatus() == 2 ? "已报名" : "已取消" %></div>
                                    <div class="label">队伍状态</div>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="stat-mini">
                                    <div class="number" style="color:#F39C12">0</div>
                                    <div class="label">提交作品</div>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="stat-mini">
                                    <div class="number" style="color:#FD79A8">0</div>
                                    <div class="label">获得点赞</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="info-card mb-3">
                        <h6 class="mb-3">基本信息</h6>
                        <div class="info-item">
                            <div class="info-icon" style="background:#EDE9FE; color:var(--primary)"><i class="fas fa-crown"></i></div>
                            <div>
                                <div class="small text-muted">队长</div>
                                <strong><%= leaderName != null ? leaderName : "用户 #" + team.getLeaderId() %></strong>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon" style="background:#E8F8F5; color:#00CEC9"><i class="fas fa-trophy"></i></div>
                            <div>
                                <div class="small text-muted">参赛竞赛</div>
                                <strong><%= competitionName != null ? competitionName : "未指定" %></strong>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon" style="background:#FEF3E2; color:#F39C12"><i class="fas fa-layer-group"></i></div>
                            <div>
                                <div class="small text-muted">参赛子类</div>
                                <strong><%= categoryName != null ? categoryName : "未指定" %></strong>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon" style="background:#FCE4EC; color:#FD79A8"><i class="fas fa-calendar-alt"></i></div>
                            <div>
                                <div class="small text-muted">创建时间</div>
                                <strong><%= team.getCreateTime() != null ? team.getCreateTime().format(dtf) : "未知" %></strong>
                            </div>
                        </div>
                    </div>

                    <div class="info-card mb-3">
                        <h6 class="mb-3">队伍简介</h6>
                        <p class="text-muted mb-0">
                            <%= team.getTeamDesc() != null && !team.getTeamDesc().isEmpty() ? team.getTeamDesc() : "这个队伍还没有填写简介，快去编辑吧 ✨" %>
                        </p>
                    </div>
                </div>

                <!-- Tab: 成员 -->
                <div class="tab-panel" id="tab-members">
                    <div class="row g-3">
                        <% if (members != null && !members.isEmpty()) {
                            String[] avatarColors = {"#6C5CE7", "#FD79A8", "#00CEC9", "#F39C12", "#E17055", "#74B9FF"};
                            int aIdx = 0;
                            for (TeamMember m : members) {
                                User mu = memberUsers != null ? memberUsers.get(m.getUserId()) : null;
                                String name = mu != null ? mu.getRealName() : "用户 #" + m.getUserId();
                                String email = mu != null ? mu.getEmail() : "";
                                String initial = name.substring(0, 1);
                                String color = avatarColors[aIdx % avatarColors.length];
                                boolean isTeamLeader = m.getRole() != null && m.getRole() == 1;
                        %>
                            <div class="col-md-6">
                                <div class="member-grid-card" style="position:relative">
                                    <% if (isTeamLeader) { %>
                                        <span class="crown-badge" style="position:absolute; top:12px; right:16px;">
                                            <i class="fas fa-crown" style="color:#F39C12;" title="队长"></i>
                                        </span>
                                    <% } %>
                                    <div class="member-grid-avatar" style="background:<%= color %>; position:relative;">
                                        <%= initial %>
                                    </div>
                                    <h6 class="mb-0"><%= name %></h6>
                                    <span class="badge <%= isTeamLeader ? "bg-warning text-dark" : "bg-light text-muted" %> mt-1">
                                        <%= isTeamLeader ? "👑 队长" : "队员" %>
                                    </span>
                                    <% if (email != null && !email.isEmpty()) { %>
                                        <div class="small text-muted mt-1"><%= email %></div>
                                    <% } %>
                                </div>
                            </div>
                        <%      aIdx++;
                            }
                        } else { %>
                            <div class="col-12 text-center py-5">
                                <i class="fas fa-user-slash fa-3x text-muted mb-3"></i>
                                <p class="text-muted">暂无成员数据</p>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Tab: 作品 -->
                <div class="tab-panel" id="tab-works">
                    <div class="info-card text-center py-5">
                        <i class="fas fa-image fa-4x mb-3" style="color: #DFE6E9;"></i>
                        <h5 class="text-muted">暂无作品</h5>
                        <p class="text-muted">组队完成后即可提交参赛作品</p>
                    </div>
                </div>
            </div>

            <!-- ═══════════ 右侧操作面板 ═══════════ -->
            <div class="col-lg-4">
                <div class="info-card mb-3">
                    <h6 class="mb-3"><i class="fas fa-cog me-2"></i>队伍操作</h6>
                    <% if (isLeader) { %>
                        <div class="d-grid gap-2">
                            <button class="action-btn btn-edit" onclick="openEditModal()">
                                <i class="fas fa-edit"></i>编辑队伍信息
                            </button>
                            <button class="action-btn btn-invite" onclick="openInviteModal()">
                                <i class="fas fa-user-plus"></i>邀请队员
                            </button>
                            <% if (team.getStatus() != null && team.getStatus() == 1) { %>
                                <form action="${pageContext.request.contextPath}/team?action=register" method="post"
                                      onsubmit="return confirm('确认报名参赛？报名后队伍状态将变为已报名，不可更改。')">
                                    <input type="hidden" name="teamId" value="<%= team.getTeamId() %>">
                                    <button type="submit" class="action-btn btn-register w-100">
                                        <i class="fas fa-check-circle"></i>报名参赛
                                    </button>
                                </form>
                            <% } else if (team.getStatus() != null && team.getStatus() == 2) { %>
                                <button class="action-btn btn-register" disabled style="opacity:0.6;">
                                    <i class="fas fa-check-circle"></i>已报名参赛
                                </button>
                            <% } %>
                            <hr>
                            <a href="${pageContext.request.contextPath}/team?action=delete&id=<%= team.getTeamId() %>"
                               class="action-btn btn-delete text-decoration-none"
                               onclick="return confirm('⚠️ 确定要解散队伍「<%= team.getTeamName() %>」吗？\n\n此操作不可恢复，所有成员将被移除。')">
                                <i class="fas fa-trash-alt"></i>解散队伍
                            </a>
                        </div>
                    <% } else { %>
                        <p class="text-muted text-center py-3">
                            <i class="fas fa-lock fa-2x d-block mb-2"></i>
                            仅队长可操作队伍设置
                        </p>
                    <% } %>
                </div>

                <div class="info-card">
                    <h6 class="mb-3"><i class="fas fa-lightbulb me-2" style="color:#F39C12;"></i>下一步做什么？</h6>
                    <div class="d-flex flex-column gap-2">
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge rounded-pill" style="background:var(--primary);">1</span>
                            <small>邀请队员加入队伍</small>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge rounded-pill" style="background:#B2BEC3;">2</span>
                            <small class="text-muted">完成队伍组建</small>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge rounded-pill" style="background:#B2BEC3;">3</span>
                            <small class="text-muted">提交参赛作品</small>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge rounded-pill" style="background:#B2BEC3;">4</span>
                            <small class="text-muted">等待评委评分</small>
                        </div>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/team?action=myTeams" class="btn btn-light w-100 mt-3 rounded-3 py-2 fw-bold" style="border:2px solid #EAEEF2">
                    <i class="fas fa-arrow-left me-2"></i>返回队伍列表
                </a>
            </div>
        </div>
    </div>

    <!-- ═══════════ 编辑队伍Modal ═══════════ -->
    <div class="modal fade" id="editTeamModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content" style="border-radius:18px; border:none;">
                <div class="modal-header" style="background:linear-gradient(135deg, var(--primary), #8B7CF6); color:white; border-radius:18px 18px 0 0;">
                    <h5 class="modal-title"><i class="fas fa-edit me-2"></i>编辑队伍信息</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <form action="${pageContext.request.contextPath}/team?action=update" method="post">
                    <input type="hidden" name="teamId" value="<%= team.getTeamId() %>">
                    <div class="modal-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">队伍名称 *</label>
                                <input type="text" class="form-control" name="teamName"
                                       value="<%= team.getTeamName() %>" required style="border-radius:10px;">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">参赛竞赛 *</label>
                                <select class="form-select" name="competitionId" style="border-radius:10px;">
                                    <% if (competitions != null) {
                                        for (Competition c : competitions) { %>
                                            <option value="<%= c.getCompetitionId() %>"
                                                <%= c.getCompetitionId().equals(team.getCompetitionId()) ? "selected" : "" %>>
                                                <%= c.getName() %>
                                            </option>
                                    <%  }
                                    } %>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">参赛子类 *</label>
                                <select class="form-select" name="categoryId" style="border-radius:10px;">
                                    <% if (categories != null) {
                                        for (CompetitionCategory cat : categories) { %>
                                            <option value="<%= cat.getCategoryId() %>"
                                                <%= cat.getCategoryId().equals(team.getCategoryId()) ? "selected" : "" %>>
                                                <%= cat.getCategoryName() %>
                                            </option>
                                    <%  }
                                    } %>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-bold">队伍简介</label>
                                <textarea class="form-control" name="teamDesc" rows="3"
                                          style="border-radius:10px;" maxlength="500"><%= team.getTeamDesc() != null ? team.getTeamDesc() : "" %></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-light rounded-3" data-bs-dismiss="modal">取消</button>
                        <button type="submit" class="btn btn-primary rounded-3 px-4" style="background:var(--primary); border:none;">保存修改</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- ═══════════ 邀请队员Modal ═══════════ -->
    <div class="modal fade" id="inviteMemberModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content" style="border-radius:18px; border:none;">
                <div class="modal-header" style="background:linear-gradient(135deg, #00CEC9, #81ECEC); color:white; border-radius:18px 18px 0 0;">
                    <h5 class="modal-title"><i class="fas fa-user-plus me-2"></i>邀请队员</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label fw-bold">搜索用户</label>
                        <div class="input-group">
                            <span class="input-group-text" style="border-radius:10px 0 0 10px;"><i class="fas fa-search"></i></span>
                            <input type="text" class="form-control" id="userSearchInput"
                                   placeholder="输入用户真实姓名..." style="border-radius:0 10px 10px 0;"
                                   oninput="searchUsers()">
                        </div>
                    </div>
                    <div id="userSearchResults" class="mt-3" style="max-height:300px; overflow-y:auto;">
                        <p class="text-muted text-center py-3" id="searchHint">输入姓名开始搜索</p>
                    </div>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-light rounded-3" data-bs-dismiss="modal">关闭</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Toast通知 -->
    <div class="position-fixed bottom-0 end-0 p-3" style="z-index:9999;">
        <div id="inviteToast" class="toast align-items-center text-white border-0" style="background:linear-gradient(135deg, #00CEC9, #00B894); border-radius:14px;" role="alert">
            <div class="d-flex">
                <div class="toast-body fw-bold" id="toastMessage">
                    <i class="fas fa-check-circle me-2"></i>邀请已发送
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function switchTab(tabName, btn) {
            document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            document.getElementById('tab-' + tabName).classList.add('active');
            btn.classList.add('active');
        }

        // ── 编辑队伍Modal ──
        function openEditModal() {
            new bootstrap.Modal(document.getElementById('editTeamModal')).show();
        }

        // ── 邀请队员Modal ──
        function openInviteModal() {
            document.getElementById('userSearchInput').value = '';
            document.getElementById('userSearchResults').innerHTML = '<p class="text-muted text-center py-3" id="searchHint">输入姓名开始搜索</p>';
            new bootstrap.Modal(document.getElementById('inviteMemberModal')).show();
        }

        var searchTimer = null;
        function searchUsers() {
            clearTimeout(searchTimer);
            searchTimer = setTimeout(function() {
                var keyword = document.getElementById('userSearchInput').value.trim();
                var resultsDiv = document.getElementById('userSearchResults');

                if (keyword.length === 0) {
                    resultsDiv.innerHTML = '<p class="text-muted text-center py-3" id="searchHint">输入姓名开始搜索</p>';
                    return;
                }

                resultsDiv.innerHTML = '<p class="text-muted text-center py-3"><i class="fas fa-spinner fa-spin me-2"></i>搜索中...</p>';

                fetch('${pageContext.request.contextPath}/team?action=searchUser&keyword=' + encodeURIComponent(keyword), {
                    method: 'POST'
                })
                .then(res => res.json())
                .then(users => {
                    if (!users || users.length === 0) {
                        resultsDiv.innerHTML = '<p class="text-muted text-center py-3"><i class="fas fa-search me-2"></i>未找到匹配用户</p>';
                        return;
                    }
                    var html = '';
                    users.forEach(function(u) {
                        html += '<div class="d-flex align-items-center p-2 border rounded-3 mb-2" style="border-color:#EAEEF2 !important;">';
                        html += '<div class="rounded-circle d-flex align-items-center justify-content-center me-3" style="width:40px;height:40px;background:linear-gradient(135deg, #6C5CE7, #A29BFE);color:white;font-weight:700;font-size:0.9rem;">' + u.realName.charAt(0) + '</div>';
                        html += '<div class="flex-grow-1"><strong>' + u.realName + '</strong><br><small class="text-muted">@' + u.username + '</small></div>';
                        html += '<button class="btn btn-sm btn-invite-action" style="background:linear-gradient(135deg, #00CEC9, #00B894); color:white; border:none; border-radius:10px; padding:0.4rem 1rem; font-weight:600;" ';
                        html += 'onclick="inviteUser(' + u.userId + ', \'' + u.realName.replace(/'/g, "\\'") + '\')">';
                        html += '<i class="fas fa-paper-plane me-1"></i>邀请</button>';
                        html += '</div>';
                    });
                    resultsDiv.innerHTML = html;
                })
                .catch(function() {
                    resultsDiv.innerHTML = '<p class="text-danger text-center py-3">搜索失败，请重试</p>';
                });
            }, 300);
        }

        function inviteUser(userId, realName) {
            if (!confirm('确定要邀请「' + realName + '」加入队伍吗？')) return;

            var formData = new URLSearchParams();
            formData.append('action', 'invite');
            formData.append('teamId', '<%= team.getTeamId() %>');
            formData.append('inviteeId', userId);
            formData.append('ajax', 'true');

            fetch('${pageContext.request.contextPath}/team', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    // 显示Toast
                    document.getElementById('toastMessage').innerHTML = '<i class="fas fa-check-circle me-2"></i>已向 ' + realName + ' 发送邀请';
                    var toast = new bootstrap.Toast(document.getElementById('inviteToast'));
                    toast.show();
                    // 从搜索结果中移除该用户
                    var btn = event.target.closest('.d-flex');
                    if (btn) btn.style.opacity = '0.5';
                    event.target.disabled = true;
                    event.target.innerHTML = '<i class="fas fa-check me-1"></i>已邀请';
                } else {
                    alert('邀请失败：' + (data.message || '未知错误'));
                }
            })
            .catch(function() {
                alert('邀请请求失败，请重试');
            });
        }
    </script>
</body>
</html>
