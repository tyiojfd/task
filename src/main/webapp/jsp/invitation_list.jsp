<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Invitation" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
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
    List<Invitation> invitations = (List<Invitation>) request.getAttribute("invitations");
    @SuppressWarnings("unchecked")
    Map<Integer, String> teamNames = (Map<Integer, String>) request.getAttribute("teamNames");
    @SuppressWarnings("unchecked")
    Map<Integer, String> inviterNames = (Map<Integer, String>) request.getAttribute("inviterNames");

    int pendingCount = 0;
    int processedCount = 0;
    if (invitations != null) {
        for (Invitation inv : invitations) {
            if (inv.getStatus() != null && inv.getStatus() == 0) {
                pendingCount++;
            } else {
                processedCount++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>邀请通知 - 大学生海报设计竞赛系统</title>
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

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin: 2rem 0 1.5rem;
        }
        .page-header h2 { font-weight: 700; color: var(--dark); margin: 0; }
        .page-header h2 i { color: var(--primary); }

        /* ── Tab切换 ── */
        .tab-nav {
            display: flex;
            gap: 0;
            margin-bottom: 1.5rem;
            background: white;
            border-radius: 14px;
            padding: 5px;
            box-shadow: var(--card-shadow);
        }
        .tab-btn {
            flex: 1;
            padding: 0.7rem 1.2rem;
            border: none;
            background: transparent;
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.9rem;
            color: var(--gray);
            transition: all 0.25s;
            cursor: pointer;
        }
        .tab-btn.active {
            background: var(--primary);
            color: white;
            box-shadow: 0 2px 8px rgba(108, 92, 231, 0.25);
        }
        .tab-btn .badge-count {
            display: inline-block;
            min-width: 22px;
            height: 22px;
            border-radius: 11px;
            font-size: 0.75rem;
            line-height: 22px;
            margin-left: 6px;
            font-weight: 700;
        }
        .tab-btn.active .badge-count { background: rgba(255,255,255,0.3); color: white; }
        .tab-btn:not(.active) .badge-count { background: #EDE9FE; color: var(--primary); }

        /* ── 邀请卡片 ── */
        .invitation-card {
            background: white;
            border-radius: 16px;
            box-shadow: var(--card-shadow);
            padding: 1.3rem 1.5rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .invitation-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(108, 92, 231, 0.1);
        }
        .inv-card-icon {
            width: 52px; height: 52px;
            border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem;
            flex-shrink: 0;
        }
        .inv-card-info { flex: 1; min-width: 0; }
        .inv-card-info h6 { font-weight: 700; margin-bottom: 0.2rem; color: var(--dark); }
        .inv-card-info p { margin: 0; font-size: 0.85rem; color: var(--gray); }
        .inv-card-info p i { width: 16px; margin-right: 4px; }
        .inv-card-actions {
            display: flex;
            gap: 8px;
            flex-shrink: 0;
        }
        .btn-accept {
            background: linear-gradient(135deg, #00CEC9 0%, #00B894 100%);
            border: none; border-radius: 10px;
            padding: 0.5rem 1.2rem;
            font-weight: 600; font-size: 0.85rem;
            color: white;
            transition: all 0.3s;
        }
        .btn-accept:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0, 206, 201, 0.4); color: white; }
        .btn-reject {
            border: 2px solid #DFE6E9;
            border-radius: 10px;
            padding: 0.5rem 1.2rem;
            font-weight: 600; font-size: 0.85rem;
            color: var(--gray);
            background: white;
            transition: all 0.3s;
        }
        .btn-reject:hover { border-color: #E17055; color: #E17055; background: #FFF5F5; }

        .status-badge {
            font-size: 0.75rem;
            padding: 0.3rem 0.7rem;
            border-radius: 20px;
            font-weight: 600;
        }
        .status-accepted { background: #E8F8F5; color: #00B894; }
        .status-rejected { background: #FFF0F0; color: #E17055; }
        .status-pending { background: #FFF8E1; color: #F39C12; }

        /* ── 空状态 ── */
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 20px;
            box-shadow: var(--card-shadow);
        }
        .empty-illustration {
            width: 140px; height: 140px;
            margin: 0 auto 1.5rem;
            background: linear-gradient(135deg, #F0EDFF 0%, #EDE9FE 100%);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 3.5rem;
            color: var(--primary-light);
        }
        .empty-state h4 { font-weight: 700; color: var(--dark); }
        .empty-state p { color: var(--gray); max-width: 400px; margin: 0 auto; }

        .alert { border-radius: 14px; border: none; }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
        <div class="container">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/index">🎨 海报竞赛系统</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/index">竞赛大厅</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/team?action=myTeams">我的队伍</a></li>
                    <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/invitation">邀请通知</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/work?action=myWorks">我的作品</a></li>
                    <% if (isJudge) { %>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/score?action=list">评分管理</a></li>
                    <% } %>
                    <% if (isAdmin) { %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">管理中心</a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/competition?action=list">竞赛管理</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/award?action=manage">获奖管理</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/news?action=manage">新闻管理</a></li>
                        </ul>
                    </li>
                    <% } %>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/news?action=list">新闻公告</a></li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown"><%= sessionUser.getRealName() %></a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">个人中心</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">退出登录</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container">
        <!-- ═══════════ 页面标题 ═══════════ -->
        <div class="page-header">
            <h2><i class="fas fa-envelope me-2"></i>邀请通知</h2>
        </div>

        <!-- 提示消息 -->
        <% String msg = request.getParameter("msg"); %>
        <% if ("accept_success".equals(msg)) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>已成功加入队伍！
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } else if ("reject_success".equals(msg)) { %>
            <div class="alert alert-secondary alert-dismissible fade show" role="alert">
                <i class="fas fa-info-circle me-2"></i>已拒绝该邀请
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        <% String error = request.getParameter("error"); %>
        <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>
                <% if ("accept_failed".equals(error)) { %>接受邀请失败，队伍可能已满或您已在队伍中<% }
                   else if ("reject_failed".equals(error)) { %>拒绝邀请失败<% }
                   else if ("invalid_id".equals(error)) { %>无效的邀请ID<% }
                   else { %><%= error %><% } %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <!-- ═══════════ Tab切换 ═══════════ -->
        <div class="tab-nav">
            <button class="tab-btn active" onclick="switchTab('pending')">
                <i class="fas fa-clock me-1"></i>待处理
                <span class="badge-count"><%= pendingCount %></span>
            </button>
            <button class="tab-btn" onclick="switchTab('processed')">
                <i class="fas fa-check-circle me-1"></i>已处理
                <span class="badge-count"><%= processedCount %></span>
            </button>
        </div>

        <!-- ═══════════ 待处理邀请 ═══════════ -->
        <div id="tab-pending" class="tab-content-section">
            <% if (invitations != null) {
                boolean hasPending = false;
                for (Invitation inv : invitations) {
                    if (inv.getStatus() == null || inv.getStatus() != 0) continue;
                    hasPending = true;
                    String teamName = teamNames != null ? teamNames.getOrDefault(inv.getTeamId(), "队伍 #" + inv.getTeamId()) : "队伍 #" + inv.getTeamId();
                    String inviterName = inviterNames != null ? inviterNames.getOrDefault(inv.getInviterId(), "用户 #" + inv.getInviterId()) : "用户 #" + inv.getInviterId();
                    String timeStr = inv.getInviteTime() != null ? inv.getInviteTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "";
            %>
                <div class="invitation-card">
                    <div class="inv-card-icon" style="background: #EDE9FE; color: var(--primary);">
                        <i class="fas fa-user-plus"></i>
                    </div>
                    <div class="inv-card-info">
                        <h6><%= inviterName %> 邀请你加入 <strong><%= teamName %></strong></h6>
                        <p><i class="far fa-clock"></i><%= timeStr %></p>
                    </div>
                    <div class="inv-card-actions">
                        <form action="${pageContext.request.contextPath}/invitation" method="post" onsubmit="return confirm('确定要接受此邀请吗？')">
                            <input type="hidden" name="action" value="accept">
                            <input type="hidden" name="invitationId" value="<%= inv.getInvitationId() %>">
                            <button type="submit" class="btn-accept"><i class="fas fa-check me-1"></i>接受</button>
                        </form>
                        <form action="${pageContext.request.contextPath}/invitation" method="post" onsubmit="return confirm('确定要拒绝此邀请吗？')">
                            <input type="hidden" name="action" value="reject">
                            <input type="hidden" name="invitationId" value="<%= inv.getInvitationId() %>">
                            <button type="submit" class="btn-reject"><i class="fas fa-times me-1"></i>拒绝</button>
                        </form>
                    </div>
                </div>
            <%      }
                if (!hasPending) { %>
                <div class="empty-state">
                    <div class="empty-illustration"><i class="fas fa-inbox"></i></div>
                    <h4>暂无待处理的邀请</h4>
                    <p>当有人邀请你加入队伍时，会在这里显示</p>
                </div>
            <%  }
            } else { %>
                <div class="empty-state">
                    <div class="empty-illustration"><i class="fas fa-inbox"></i></div>
                    <h4>暂无邀请</h4>
                    <p>还没有收到任何队伍邀请</p>
                </div>
            <% } %>
        </div>

        <!-- ═══════════ 已处理邀请 ═══════════ -->
        <div id="tab-processed" class="tab-content-section" style="display:none;">
            <% if (invitations != null) {
                boolean hasProcessed = false;
                for (Invitation inv : invitations) {
                    if (inv.getStatus() == null || inv.getStatus() == 0) continue;
                    hasProcessed = true;
                    String teamName = teamNames != null ? teamNames.getOrDefault(inv.getTeamId(), "队伍 #" + inv.getTeamId()) : "队伍 #" + inv.getTeamId();
                    String inviterName = inviterNames != null ? inviterNames.getOrDefault(inv.getInviterId(), "用户 #" + inv.getInviterId()) : "用户 #" + inv.getInviterId();
                    String timeStr = inv.getInviteTime() != null ? inv.getInviteTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "";
                    String responseTimeStr = inv.getResponseTime() != null ? inv.getResponseTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) : "";
                    boolean accepted = inv.getStatus() == 1;
            %>
                <div class="invitation-card" style="opacity: 0.7;">
                    <div class="inv-card-icon" style="background: <%= accepted ? "#E8F8F5" : "#FFF0F0" %>; color: <%= accepted ? "#00B894" : "#E17055" %>;">
                        <i class="fas fa-<%= accepted ? "check" : "times" %>"></i>
                    </div>
                    <div class="inv-card-info">
                        <h6><%= inviterName %> 邀请你加入 <strong><%= teamName %></strong></h6>
                        <p><i class="far fa-clock"></i>邀请于 <%= timeStr %></p>
                        <p><i class="fas fa-<%= accepted ? "check-circle" : "times-circle" %>"></i><%= accepted ? "已接受" : "已拒绝" %> · <%= responseTimeStr %></p>
                    </div>
                    <span class="status-badge <%= accepted ? "status-accepted" : "status-rejected" %>">
                        <%= accepted ? "已接受" : "已拒绝" %>
                    </span>
                </div>
            <%      }
                if (!hasProcessed) { %>
                <div class="empty-state">
                    <div class="empty-illustration"><i class="fas fa-history"></i></div>
                    <h4>暂无已处理的邀请</h4>
                    <p>处理过的邀请记录会显示在这里</p>
                </div>
            <%  }
            } %>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function switchTab(tab) {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            document.querySelectorAll('.tab-content-section').forEach(s => s.style.display = 'none');
            if (tab === 'pending') {
                document.querySelector('.tab-btn:nth-child(1)').classList.add('active');
                document.getElementById('tab-pending').style.display = '';
            } else {
                document.querySelector('.tab-btn:nth-child(2)').classList.add('active');
                document.getElementById('tab-processed').style.display = '';
            }
        }
    </script>
</body>
</html>
