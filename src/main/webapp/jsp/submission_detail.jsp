<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.model.Score" %>
<%@ page import="com.poster.model.Comment" %>
<%@ page import="com.poster.model.Award" %>
<%@ page import="com.poster.model.Certificate" %>
<%@ page import="java.util.List" %>
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

    Work work = (Work) request.getAttribute("work");
    Team team = (Team) request.getAttribute("team");
    Competition competition = (Competition) request.getAttribute("competition");

    @SuppressWarnings("unchecked")
    List<Score> scores = (List<Score>) request.getAttribute("scores");
    Double avgScore = (Double) request.getAttribute("avgScore");

    @SuppressWarnings("unchecked")
    List<Comment> comments = (List<Comment>) request.getAttribute("comments");
    Award award = (Award) request.getAttribute("award");
    Certificate certificate = (Certificate) request.getAttribute("certificate");

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
        :root {
            --primary: #6C5CE7; --primary-light: #A29BFE; --accent: #FD79A8;
            --dark: #2D3436; --gray: #636E72; --gold: #FFD700;
            --card-shadow: 0 2px 16px rgba(108,92,231,0.06);
        }
        body {
            background: linear-gradient(135deg, #F8F9FA 0%, #E8ECF1 100%);
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif;
        }
        .navbar { background: var(--dark) !important; box-shadow: 0 2px 12px rgba(0,0,0,0.15); }
        .navbar-brand { font-weight: 700; }
        .navbar-brand i { color: var(--primary-light); margin-right: 6px; }
        .nav-link { font-size: 0.9rem; }
        .nav-link:hover { color: var(--primary-light) !important; }

        .detail-card {
            background: white; border-radius: 16px;
            box-shadow: var(--card-shadow); overflow: hidden; margin-bottom: 1.5rem;
        }
        .work-image { width: 100%; max-height: 500px; object-fit: contain; background: #F8F9FA; cursor: pointer; }
        .info-label { font-size: 0.8rem; color: var(--gray); }
        .info-value { font-weight: 600; color: var(--dark); }
        .back-link { color: var(--gray); text-decoration: none; font-weight: 600; }
        .back-link:hover { color: var(--primary); }

        .score-badge { font-size: 0.85rem; padding: 0.35em 0.65em; }
        .score-high { background: #D4EDDA; color: #155724; }
        .score-mid { background: #FFF3CD; color: #856404; }
        .score-low { background: #F8D7DA; color: #721C24; }

        .comment-card {
            background: #F8F9FA; border-radius: 12px; padding: 1rem;
            margin-bottom: 0.8rem; border-left: 3px solid var(--primary-light);
        }

        .tab-content { padding: 1.5rem 0; }
        .info-section { padding: 2rem; }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <nav class="navbar navbar-expand-lg navbar-dark sticky-top">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/index">
                <i class="fas fa-palette"></i>海报竞赛系统
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/index"><i class="fas fa-home"></i> 首页</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/competition?action=list"><i class="fas fa-trophy"></i> 竞赛大厅</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/team?action=myTeams"><i class="fas fa-users"></i> 我的队伍</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/work?action=myWorks"><i class="fas fa-image"></i> 我的作品</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/news?action=list"><i class="fas fa-newspaper"></i> 新闻公告</a></li>
                    <% if (isJudge) { %>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/score?action=list"><i class="fas fa-star"></i> 评分工作台</a></li>
                    <% } %>
                    <% if (isAdmin) { %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown"><i class="fas fa-crown"></i> 管理</a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/competition?action=add"><i class="fas fa-plus-circle"></i> 发布竞赛</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/award?action=manage"><i class="fas fa-medal"></i> 获奖管理</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/news?action=manage"><i class="fas fa-newspaper"></i> 新闻管理</a></li>
                        </ul>
                    </li>
                    <% } %>
                </ul>
                <ul class="navbar-nav">
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                            <i class="fas fa-user-circle"></i> <%= sessionUser.getUsername() %>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile"><i class="fas fa-cog"></i> 个人中心</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/certificate?action=myCertificates"><i class="fas fa-certificate"></i> 我的奖状</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> 退出登录</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <a href="${pageContext.request.contextPath}/work?action=myWorks" class="back-link mb-3 d-inline-block">
            <i class="fas fa-arrow-left me-1"></i>返回作品列表
        </a>

        <div class="detail-card">
            <div class="row g-0">
                <div class="col-lg-7">
                    <% if (work.getImagePath() != null && !work.getImagePath().isEmpty()) { %>
                        <img src="${pageContext.request.contextPath}<%= work.getImagePath() %>" class="work-image"
                             alt="<%= work.getTitle() %>" onclick="window.open(this.src, '_blank')">
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

                        <!-- 获奖信息 -->
                        <% if (award != null) { %>
                        <div class="alert alert-warning border-0" style="background:linear-gradient(135deg,#FFF9E6,#FFF3CD);border-radius:12px;">
                            <div class="d-flex align-items-center">
                                <i class="fas fa-trophy" style="font-size:2rem;color:#FFD700;"></i>
                                <div class="ms-3">
                                    <strong><%= award.getAwardLevel() %></strong>
                                    <span class="text-muted ms-2">最终得分: <%= String.format("%.1f", award.getFinalScore()) %> 分</span>
                                    <% if (certificate != null) { %>
                                    <br>
                                    <a href="${pageContext.request.contextPath}/certificate?action=view&awardId=<%= award.getAwardId() %>"
                                       class="btn btn-sm btn-outline-warning mt-1" target="_blank">
                                        <i class="fas fa-certificate"></i> 查看奖状
                                    </a>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        <% } %>

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

                        <!-- 平均分 -->
                        <% if (avgScore != null && avgScore > 0) { %>
                        <div class="text-center py-2 mb-3" style="background:#F0EDFF;border-radius:12px;">
                            <span class="info-label">平均评分</span>
                            <div style="font-size:2rem;font-weight:700;color:var(--primary);"><%= String.format("%.1f", avgScore) %></div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tab切换：评分 / 评语 -->
        <div class="detail-card">
            <div class="p-3">
                <ul class="nav nav-tabs" id="detailTab" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#scoresTab">
                            <i class="fas fa-star"></i> 评分记录
                            <% if (scores != null && !scores.isEmpty()) { %>
                            <span class="badge bg-primary ms-1"><%= scores.size() %></span>
                            <% } %>
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#commentsTab">
                            <i class="fas fa-comment-dots"></i> 评委评语
                            <% if (comments != null && !comments.isEmpty()) { %>
                            <span class="badge bg-primary ms-1"><%= comments.size() %></span>
                            <% } %>
                        </button>
                    </li>
                </ul>

                <div class="tab-content">
                    <!-- 评分Tab -->
                    <div class="tab-pane fade show active" id="scoresTab">
                        <% if (scores != null && !scores.isEmpty()) { %>
                            <% for (Score s : scores) {
                                String scoreBadge = "score-high";
                                if (s.getScore() < 60) scoreBadge = "score-low";
                                else if (s.getScore() < 80) scoreBadge = "score-mid";
                            %>
                            <div class="d-flex justify-content-between align-items-center p-3 border-bottom">
                                <div>
                                    <i class="fas fa-user-circle text-muted"></i>
                                    <span class="ms-2">评委 #<%= s.getJudgeId() %></span>
                                </div>
                                <div class="d-flex align-items-center">
                                    <span class="badge score-badge <%= scoreBadge %> me-2">
                                        <%= String.format("%.1f", s.getScore()) %> 分
                                    </span>
                                    <small class="text-muted">
                                        <%= s.getScoreTime() != null ? s.getScoreTime().format(DateTimeFormatter.ofPattern("MM-dd HH:mm")) : "" %>
                                    </small>
                                </div>
                            </div>
                            <% } %>
                        <% } else { %>
                            <div class="text-center py-5 text-muted">
                                <i class="fas fa-star" style="font-size:3rem;opacity:0.3;"></i>
                                <p class="mt-2">暂无评分</p>
                            </div>
                        <% } %>
                    </div>

                    <!-- 评语Tab -->
                    <div class="tab-pane fade" id="commentsTab">
                        <% if (comments != null && !comments.isEmpty()) { %>
                            <% for (Comment c : comments) { %>
                            <div class="comment-card">
                                <div class="d-flex justify-content-between mb-2">
                                    <small class="fw-bold text-muted">
                                        <i class="fas fa-user-circle"></i> 评委 #<%= c.getJudgeId() %>
                                    </small>
                                    <small class="text-muted">
                                        <%= c.getCommentTime() != null ? c.getCommentTime().format(DateTimeFormatter.ofPattern("MM-dd HH:mm")) : "" %>
                                    </small>
                                </div>
                                <p class="mb-0"><%= c.getCommentText() %></p>
                            </div>
                            <% } %>
                        <% } else { %>
                            <div class="text-center py-5 text-muted">
                                <i class="fas fa-comment-dots" style="font-size:3rem;opacity:0.3;"></i>
                                <p class="mt-2">暂无评语</p>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
