<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
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
    List<Work> works = (List<Work>) request.getAttribute("works");
    @SuppressWarnings("unchecked")
    List<Team> myTeams = (List<Team>) request.getAttribute("myTeams");
    @SuppressWarnings("unchecked")
    Map<Integer, String> teamNameMap = (Map<Integer, String>) request.getAttribute("teamNameMap");
    @SuppressWarnings("unchecked")
    Map<Integer, String> competitionNameMap = (Map<Integer, String>) request.getAttribute("competitionNameMap");

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
    String serverError = (String) request.getAttribute("error");

    int totalWorks = works != null ? works.size() : 0;

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>作品管理 - 大学生海报设计竞赛系统</title>
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
        .navbar-brand { font-weight: 700; }
        .navbar-brand i { color: var(--primary-light); margin-right: 6px; }
        .nav-link { font-size: 0.9rem; transition: color 0.2s; }
        .nav-link:hover { color: var(--primary-light) !important; }
        .nav-link.active { color: var(--primary-light) !important; font-weight: 600; }

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin: 2rem 0 1.5rem;
            flex-wrap: wrap;
            gap: 1rem;
        }
        .page-header h2 { font-weight: 700; color: var(--dark); margin: 0; }
        .page-header h2 i { color: var(--primary); }

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

        .work-card {
            background: white;
            border-radius: 16px;
            box-shadow: var(--card-shadow);
            overflow: hidden;
            transition: all 0.3s;
            height: 100%;
        }
        .work-card:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(108, 92, 231, 0.12); }

        .work-thumb {
            width: 100%;
            height: 200px;
            object-fit: cover;
            cursor: pointer;
            background: #F8F9FA;
        }
        .work-thumb-placeholder {
            width: 100%;
            height: 200px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #F0EDFF 0%, #E8ECF1 100%);
            color: #B2BEC3;
            font-size: 3rem;
        }

        .work-body { padding: 1.25rem; }
        .work-body h5 {
            font-weight: 700;
            font-size: 1rem;
            margin-bottom: 0.5rem;
            color: var(--dark);
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .work-body .work-desc {
            font-size: 0.85rem;
            color: var(--gray);
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            margin-bottom: 0.75rem;
            min-height: 2.5em;
        }
        .work-meta {
            font-size: 0.78rem;
            color: #B2BEC3;
        }
        .work-meta i { width: 14px; margin-right: 3px; }

        .work-actions {
            display: flex;
            gap: 6px;
            padding: 0 1.25rem 1.25rem;
        }
        .work-actions .btn-sm {
            border-radius: 8px;
            font-size: 0.78rem;
            font-weight: 600;
            padding: 0.35rem 0.8rem;
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
        }
        .empty-state .empty-illustration {
            width: 100px; height: 100px;
            border-radius: 50%;
            background: #F0EDFF;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 1.5rem;
            font-size: 2.5rem;
            color: var(--primary-light);
        }
        .empty-state h4 { font-weight: 700; color: var(--dark); }
        .empty-state p { color: var(--gray); max-width: 400px; margin: 0 auto 1.5rem; }

        .btn-primary-custom {
            background: linear-gradient(135deg, var(--primary) 0%, #8B7CF6 100%);
            border: none; border-radius: 12px;
            padding: 0.65rem 1.6rem;
            font-weight: 600; font-size: 0.95rem;
            color: white;
            transition: all 0.3s;
            box-shadow: 0 4px 14px rgba(108, 92, 231, 0.3);
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(108, 92, 231, 0.45);
            color: white;
        }

        /* 图片预览弹窗 */
        .modal-preview .modal-content {
            border: none;
            border-radius: 16px;
            overflow: hidden;
            background: transparent;
        }
        .modal-preview .modal-body { padding: 0; text-align: center; }
        .modal-preview img { max-width: 100%; max-height: 80vh; border-radius: 12px; box-shadow: 0 8px 32px rgba(0,0,0,0.3); }
        .modal-preview .btn-close {
            position: absolute; top: 10px; right: 10px;
            background: rgba(0,0,0,0.5);
            border-radius: 50%;
            width: 36px; height: 36px;
            opacity: 0.8;
        }

        .badge-status {
            font-size: 0.7rem;
            padding: 0.3rem 0.6rem;
            border-radius: 20px;
        }

        /* 队伍选择列表 */
        .team-select-list {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 1.5rem;
        }
        .team-select-btn {
            padding: 0.5rem 1.2rem;
            border-radius: 10px;
            border: 2px solid #EAEEF2;
            background: white;
            font-weight: 600;
            font-size: 0.85rem;
            color: var(--gray);
            transition: all 0.2s;
            cursor: pointer;
            text-decoration: none;
        }
        .team-select-btn:hover { border-color: var(--primary-light); color: var(--primary); }
        .team-select-btn i { margin-right: 4px; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/index">
                <i class="fas fa-palette"></i>海报竞赛系统
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/index"><i class="fas fa-home me-1"></i>竞赛大厅</a>
                    </li>
                    <% if (!isAdmin && !isJudge) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/team?action=myTeams"><i class="fas fa-users me-1"></i>我的队伍</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/invitation"><i class="fas fa-envelope me-1"></i>邀请通知</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/work?action=myWorks"><i class="fas fa-image me-1"></i>我的作品</a>
                    </li>
                    <% } %>
                    <% if (isJudge) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/score?action=list"><i class="fas fa-star-half-alt me-1"></i>评分管理</a>
                    </li>
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
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/news?action=list"><i class="fas fa-bullhorn me-1"></i>新闻公告</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/profile"><i class="fas fa-user me-1"></i>个人中心</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-danger" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt me-1"></i>退出</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h2><i class="fas fa-image me-2"></i>作品管理</h2>
        </div>

        <% if (msg != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>
                <% if ("submit_success".equals(msg)) { %>作品提交成功！<% } %>
                <% if ("update_success".equals(msg)) { %>作品更新成功！<% } %>
                <% if ("delete_success".equals(msg)) { %>作品已删除。<% } %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        <% if (error != null || serverError != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>
                <%= error != null ? error : serverError %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <!-- 统计卡片 -->
        <div class="row stats-row">
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="stat-icon" style="background:#F0EDFF;color:var(--primary);">
                        <i class="fas fa-image"></i>
                    </div>
                    <div>
                        <div class="stat-value"><%= totalWorks %></div>
                        <div class="stat-label">提交作品</div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="stat-icon" style="background:#FFF3E0;color:#F39C12;">
                        <i class="fas fa-users"></i>
                    </div>
                    <div>
                        <div class="stat-value"><%= myTeams != null ? myTeams.size() : 0 %></div>
                        <div class="stat-label">我的队伍</div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="stat-icon" style="background:#E8F8F5;color:#00B894;">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div>
                        <div class="stat-value"><%= (int) (works != null ? works.stream().filter(w -> w.getStatus() != null && w.getStatus() == 2).count() : 0) %></div>
                        <div class="stat-label">已提交</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 队伍快速入口 -->
        <% List<Integer> leaderTeamIds = (List<Integer>) request.getAttribute("leaderTeamIds"); if (leaderTeamIds == null) leaderTeamIds = Collections.emptyList(); %>
        <% if (myTeams != null && !myTeams.isEmpty() && !leaderTeamIds.isEmpty()) { %>
            <div class="team-select-list">
                <% for (Team t : myTeams) {
                    if (!leaderTeamIds.contains(t.getTeamId())) continue;
                    String compName = competitionNameMap != null ? competitionNameMap.getOrDefault(t.getCompetitionId(), "") : "";
                %>
                    <a href="${pageContext.request.contextPath}/work?action=add&teamId=<%= t.getTeamId() %>" class="team-select-btn">
                        <i class="fas fa-plus-circle" style="color:var(--primary)"></i>
                        <%= t.getTeamName() %>
                        <small class="text-muted">(<%= compName %>)</small>
                    </a>
                <% } %>
            </div>
        <% } %>

        <!-- 作品列表 -->
        <% if (works != null && !works.isEmpty()) { %>
            <div class="row g-4">
                <% for (Work work : works) {
                    String teamName = teamNameMap != null ? teamNameMap.getOrDefault(work.getTeamId(), "队伍#" + work.getTeamId()) : "队伍#" + work.getTeamId();
                    String compName = competitionNameMap != null ? competitionNameMap.getOrDefault(work.getCompetitionId(), "") : "";
                    String statusText = work.getStatus() == 2 ? "已提交" : (work.getStatus() == 3 ? "已评分" : "草稿");
                    String statusClass = work.getStatus() == 2 ? "success" : (work.getStatus() == 3 ? "primary" : "secondary");
                    boolean canManage = leaderTeamIds.contains(work.getTeamId());
                %>
                    <div class="col-lg-4 col-md-6">
                        <div class="work-card">
                            <% if (work.getImagePath() != null && !work.getImagePath().isEmpty()) { %>
                                <img src="${pageContext.request.contextPath}/image-data?workId=<%= work.getWorkId() %>"
                                     class="work-thumb" alt="<%= work.getTitle() %>"
                                     onclick="previewImage('${pageContext.request.contextPath}/image-data?workId=<%= work.getWorkId() %>')">
                            <% } else { %>
                                <div class="work-thumb-placeholder">
                                    <i class="fas fa-image"></i>
                                </div>
                            <% } %>
                            <div class="work-body">
                                <div class="d-flex justify-content-between align-items-start mb-1">
                                    <h5><%= work.getTitle() != null ? work.getTitle() : "未命名作品" %></h5>
                                    <span class="badge bg-<%= statusClass %> badge-status"><%= statusText %></span>
                                </div>
                                <p class="work-desc"><%= work.getDescription() != null && !work.getDescription().isEmpty() ? work.getDescription() : "暂无描述" %></p>
                                <div class="work-meta">
                                    <div><i class="fas fa-users"></i><%= teamName %></div>
                                    <div><i class="fas fa-trophy"></i><%= compName %></div>
                                    <div><i class="fas fa-clock"></i><%= work.getSubmitTime() != null ? work.getSubmitTime().format(dtf) : "" %></div>
                                </div>
                            </div>
                            <div class="work-actions">
                                <% if (work.getImagePath() != null && !work.getImagePath().isEmpty()) { %>
                                    <button class="btn btn-outline-primary btn-sm" onclick="previewImage('${pageContext.request.contextPath}/image-data?workId=<%= work.getWorkId() %>')">
                                        <i class="fas fa-search-plus"></i> 预览
                                    </button>
                                <% } %>
                                <% if (canManage) { %>
                                <a href="${pageContext.request.contextPath}/work?action=edit&id=<%= work.getWorkId() %>" class="btn btn-outline-secondary btn-sm">
                                    <i class="fas fa-edit"></i> 修改
                                </a>
                                <a href="${pageContext.request.contextPath}/work?action=delete&id=<%= work.getWorkId() %>"
                                   class="btn btn-outline-danger btn-sm"
                                   onclick="return confirm('确定要删除作品「<%= work.getTitle() %>」吗？此操作不可恢复。')">
                                    <i class="fas fa-trash-alt"></i> 删除
                                </a>
                                <% } %>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <!-- 空状态 -->
            <div class="empty-state">
                <div class="empty-illustration">
                    <i class="fas fa-palette"></i>
                </div>
                <h4>还没有提交作品</h4>
                <p>创建队伍并报名参赛后，即可提交海报作品参与竞赛</p>
                <% if (!leaderTeamIds.isEmpty()) { %>
                    <a href="${pageContext.request.contextPath}/work?action=add&teamId=<%= leaderTeamIds.get(0) %>" class="btn-primary-custom">
                        <i class="fas fa-plus-circle me-2"></i>立即提交作品
                    </a>
                <% } else if (myTeams != null && !myTeams.isEmpty()) { %>
                    <a href="${pageContext.request.contextPath}/team?action=myTeams" class="btn-primary-custom text-decoration-none">
                        <i class="fas fa-eye me-2"></i>查看我的队伍与作品
                    </a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/team?action=myTeams" class="btn-primary-custom text-decoration-none">
                        <i class="fas fa-plus-circle me-2"></i>先去创建队伍
                    </a>
                <% } %>
            </div>
        <% } %>
    </div>

    <!-- 图片预览弹窗 -->
    <div class="modal fade modal-preview" id="imagePreviewModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered modal-xl">
            <div class="modal-content">
                <div class="modal-body">
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    <img id="previewModalImage" src="" alt="作品预览">
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function previewImage(src) {
            document.getElementById('previewModalImage').src = src;
            var modal = new bootstrap.Modal(document.getElementById('imagePreviewModal'));
            modal.show();
        }
    </script>
</body>
</html>
