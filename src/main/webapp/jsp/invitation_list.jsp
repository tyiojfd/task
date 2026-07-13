<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Invitation" %>
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

<%@ include file="includes/app-shell-assets.jspf" %>
<style>
    .tab-nav { display: flex; gap: 0; margin-bottom: 1.5rem; background: var(--app-surface); border: 1px solid rgba(21,50,71,0.07); border-radius: 12px; padding: 5px; box-shadow: var(--shadow-sm); }
    .tab-btn { flex: 1; padding: 0.7rem 1.2rem; border: none; background: transparent; border-radius: 8px; font-weight: 700; font-size: 0.9rem; color: var(--app-muted); transition: all 0.2s; cursor: pointer; }
    .tab-btn.active { background: var(--app-blue); color: #fff; box-shadow: var(--shadow-sm); }
    .badge-count { display: inline-block; min-width: 22px; height: 22px; border-radius: 11px; font-size: 0.75rem; line-height: 22px; margin-left: 6px; font-weight: 700; text-align: center; }
    .tab-btn.active .badge-count { background: rgba(255,255,255,0.28); color: #fff; }
    .tab-btn:not(.active) .badge-count { background: var(--app-surface-soft); color: var(--app-blue); }
    .inv-card { background: var(--app-surface); border: 1px solid rgba(21,50,71,0.07); border-radius: 12px; padding: 1.25rem; box-shadow: var(--shadow-sm); margin-bottom: 1rem; display: flex; align-items: center; gap: 1rem; }
    .inv-card-icon { width: 52px; height: 52px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; font-weight: 800; flex-shrink: 0; background: var(--app-surface-soft); color: var(--app-ink-soft); }
    .inv-card-info { flex: 1; min-width: 0; }
    .inv-card-info strong { display: block; color: var(--app-ink); font-size: 1rem; }
    .inv-card-info small { color: var(--app-muted); }
    .inv-card-actions { display: flex; gap: 0.5rem; flex-shrink: 0; }
</style>
</head>
<body class="app-page app-page-catalog app-page-invitations">
    <!-- 导航栏 -->
    <%
    request.setAttribute("activeNav", "invitations");
%>
<%@ include file="includes/navbar.jspf" %>

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
                <% if ("accept_failed".equals(error)) { %>接受邀请失败：队伍可能已满、邀请已失效、您已在队伍/同竞赛其他队伍中，或当前账号不是可参赛账号。管理员和评委不可加入队伍。<% }
                   else if ("reject_failed".equals(error)) { %>拒绝邀请失败<% }
                   else if ("invalid_id".equals(error)) { %>无效的邀请ID<% }
                   else { %><%= HtmlEscaper.escape(error) %><% } %>
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
                    <div class="inv-card-icon">
                        <i class="fas fa-user-plus"></i>
                    </div>
                    <div class="inv-card-info">
                        <h6><%= HtmlEscaper.escape(inviterName) %> 邀请你加入 <strong><%= HtmlEscaper.escape(teamName) %></strong></h6>
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
                        <h6><%= HtmlEscaper.escape(inviterName) %> 邀请你加入 <strong><%= HtmlEscaper.escape(teamName) %></strong></h6>
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
