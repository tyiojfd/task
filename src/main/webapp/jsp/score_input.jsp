<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Score" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Work> works = (List<Work>) request.getAttribute("works");
    @SuppressWarnings("unchecked")
    List<Score> myScores = (List<Score>) request.getAttribute("myScores");

    Work targetWork = (Work) request.getAttribute("work");
    Team targetTeam = (Team) request.getAttribute("team");
    Boolean hasScored = (Boolean) request.getAttribute("hasScored");
    Score existingScore = (Score) request.getAttribute("existingScore");

    String message = (String) session.getAttribute("message");
    if (message != null) {
        session.removeAttribute("message");
    }
    String error = (String) request.getAttribute("error");

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>评分工作台 - 大学生海报设计竞赛系统</title>
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
            text-align: center;
        }
        .stat-card .stat-number { font-size: 2rem; font-weight: 700; color: var(--primary); }
        .stat-card .stat-label { font-size: 0.85rem; color: var(--gray); margin-top: 0.25rem; }
        .stat-card i { font-size: 1.3rem; color: var(--primary-light); margin-right: 4px; }

        .work-card {
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: var(--card-shadow);
            transition: transform 0.2s, box-shadow 0.2s;
            border-left: 4px solid transparent;
            cursor: pointer;
        }
        .work-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 20px rgba(108, 92, 231, 0.12);
        }
        .work-card.scored { border-left-color: #00B894; }
        .work-card.unscored { border-left-color: var(--accent); }
        .work-card .work-title { font-weight: 600; font-size: 1.1rem; color: var(--dark); }
        .work-card .work-meta { font-size: 0.85rem; color: var(--gray); margin-top: 0.3rem; }
        .work-card .badge-score { font-size: 0.8rem; padding: 0.35em 0.65em; }

        .score-form-card {
            background: white;
            border-radius: 20px;
            padding: 2rem;
            box-shadow: var(--card-shadow);
            margin-bottom: 2rem;
        }
        .score-form-card h4 { font-weight: 700; color: var(--dark); }
        .score-slider {
            width: 100%;
            height: 8px;
            border-radius: 4px;
            background: linear-gradient(to right, #FF7675, #FDCB6E, #00B894);
            outline: none;
        }
        .score-display {
            font-size: 3rem;
            font-weight: 700;
            color: var(--primary);
            text-align: center;
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 20px;
            box-shadow: var(--card-shadow);
        }
        .empty-state i { font-size: 4rem; color: var(--primary-light); }
        .empty-state h5 { margin-top: 1rem; color: var(--gray); }

        .alert-custom {
            border-radius: 12px;
            border: none;
        }

        .info-panel {
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            box-shadow: var(--card-shadow);
            margin-bottom: 1.5rem;
        }
        .info-panel .info-label { font-size: 0.8rem; color: var(--gray); text-transform: uppercase; }
        .info-panel .info-value { font-weight: 600; color: var(--dark); }

        .back-link { color: var(--primary); text-decoration: none; font-weight: 500; }
        .back-link:hover { color: var(--primary-light); }
    </style>
</head>
<body>

<!-- 导航栏 -->
<!-- 导航栏 -->
<% request.setAttribute("activePage", "scoreManage"); %>
<%@ include file="navbar.jsp" %>

<div class="container">

    <!-- 页面标题 -->
    <div class="page-header">
        <h2><i class="fas fa-star me-2"></i>评分工作台</h2>
        <div>
            <a href="${pageContext.request.contextPath}/score?action=myScores" class="btn btn-outline-primary me-2">
                <i class="fas fa-list-check me-1"></i>我的评分记录
            </a>
            <a href="${pageContext.request.contextPath}/score?action=list" class="btn btn-primary">
                <i class="fas fa-th-list me-1"></i>待评作品列表
            </a>
        </div>
    </div>

    <!-- 消息提示 -->
    <% if (message != null) { %>
    <div class="alert alert-success alert-custom alert-dismissible fade show" role="alert">
        <i class="fas fa-check-circle me-2"></i><%= message %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>
    <% if (error != null) { %>
    <div class="alert alert-danger alert-custom alert-dismissible fade show" role="alert">
        <i class="fas fa-exclamation-circle me-2"></i><%= error %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- 统计面板 -->
    <div class="row stats-row">
        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-number"><%= works != null ? works.size() : 0 %></div>
                <div class="stat-label"><i class="fas fa-image"></i>待评作品总数</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <%
                    int scoredCount = 0;
                    if (myScores != null) scoredCount = myScores.size();
                %>
                <div class="stat-number"><%= scoredCount %></div>
                <div class="stat-label"><i class="fas fa-check-circle"></i>我已评分</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <%
                    int remaining = (works != null ? works.size() : 0) - scoredCount;
                %>
                <div class="stat-number"><%= Math.max(0, remaining) %></div>
                <div class="stat-label"><i class="fas fa-clock"></i>尚未评分</div>
            </div>
        </div>
    </div>

    <%-- 评分表单模式（选中特定作品评分） --%>
    <% if (targetWork != null) { %>
    <div class="row">
        <div class="col-lg-4">
            <div class="info-panel">
                <h5 class="mb-3"><i class="fas fa-info-circle me-2"></i>作品信息</h5>
                <div class="mb-3">
                    <div class="info-label">作品名称</div>
                    <div class="info-value"><%= targetWork.getTitle() %></div>
                </div>
                <div class="mb-3">
                    <div class="info-label">作品描述</div>
                    <div class="info-value" style="font-weight:400;"><%= targetWork.getDescription() != null ? targetWork.getDescription() : "暂无描述" %></div>
                </div>
                <div class="mb-3">
                    <div class="info-label">所属队伍</div>
                    <div class="info-value"><%= targetTeam != null ? targetTeam.getTeamName() : "未知队伍" %></div>
                </div>
                <div class="mb-3">
                    <div class="info-label">提交时间</div>
                    <div class="info-value"><%= targetWork.getSubmitTime() != null ? targetWork.getSubmitTime().format(dtf) : "未知" %></div>
                </div>
                <% if (targetWork.getImagePath() != null && !targetWork.getImagePath().isEmpty()) { %>
                <div>
                    <div class="info-label">作品图片</div>
                    <img src="${pageContext.request.contextPath}/<%= targetWork.getImagePath() %>"
                         class="img-fluid rounded mt-2" alt="作品图片"
                         style="max-height: 200px; cursor: pointer;"
                         onclick="window.open(this.src, '_blank')">
                </div>
                <% } %>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="score-form-card">
                <h4 class="mb-4">
                    <% if (hasScored != null && hasScored) { %>
                    <i class="fas fa-edit me-2"></i>修改评分
                    <% } else { %>
                    <i class="fas fa-star me-2"></i>提交评分
                    <% } %>
                </h4>

                <% if (hasScored != null && hasScored && existingScore != null) { %>
                <div class="alert alert-info alert-custom mb-4">
                    <i class="fas fa-info-circle me-2"></i>
                    您已对该作品评分：<strong><%= existingScore.getScore() %> 分</strong>
                    （评分时间：<%= existingScore.getScoreTime() != null ? existingScore.getScoreTime().format(dtf) : "未知" %>）
                    <br>您可以修改评分。
                </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/score" method="post" onsubmit="return validateScore()">
                    <input type="hidden" name="action" value="<%= (hasScored != null && hasScored) ? "update" : "submit" %>">
                    <input type="hidden" name="workId" value="<%= targetWork.getWorkId() %>">
                    <% if (hasScored != null && hasScored && existingScore != null) { %>
                    <input type="hidden" name="scoreId" value="<%= existingScore.getScoreId() %>">
                    <% } %>

                    <div class="mb-4">
                        <label class="form-label fw-bold">评分（0-100分）</label>
                        <div class="score-display mb-3" id="scoreDisplay">
                            <%= (hasScored != null && hasScored && existingScore != null) ? String.format("%.0f", existingScore.getScore()) : "50" %>
                        </div>
                        <input type="range" class="score-slider" id="scoreSlider"
                               name="score" min="0" max="100" step="0.5"
                               value="<%= (hasScored != null && hasScored && existingScore != null) ? String.format("%.1f", existingScore.getScore()) : "50" %>"
                               oninput="updateScoreDisplay(this.value)">
                        <div class="d-flex justify-content-between mt-2">
                            <small class="text-muted">0 分</small>
                            <small class="text-muted">50 分</small>
                            <small class="text-muted">100 分</small>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-bold">或直接输入分数</label>
                        <input type="number" class="form-control" id="scoreInput"
                               min="0" max="100" step="0.5"
                               value="<%= (hasScored != null && hasScored && existingScore != null) ? String.format("%.1f", existingScore.getScore()) : "50" %>"
                               oninput="syncSlider(this.value)"
                               style="max-width: 150px; font-size: 1.2rem;">
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-primary btn-lg px-4">
                            <% if (hasScored != null && hasScored) { %>
                            <i class="fas fa-save me-1"></i>更新评分
                            <% } else { %>
                            <i class="fas fa-paper-plane me-1"></i>提交评分
                            <% } %>
                        </button>
                        <a href="${pageContext.request.contextPath}/score?action=list" class="btn btn-outline-secondary btn-lg">
                            <i class="fas fa-arrow-left me-1"></i>返回列表
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <%-- 作品列表模式 --%>
    <% } else { %>
    <% if (works == null || works.isEmpty()) { %>
    <div class="empty-state">
        <i class="fas fa-inbox"></i>
        <h5>暂无待评作品</h5>
        <p class="text-muted">当前没有已提交的作品需要评分</p>
    </div>
    <% } else { %>
    <div class="row">
        <% for (Work w : works) {
            boolean scored = false;
            double myScoreVal = 0;
            if (myScores != null) {
                for (Score s : myScores) {
                    if (s.getWorkId().equals(w.getWorkId())) {
                        scored = true;
                        myScoreVal = s.getScore();
                        break;
                    }
                }
            }
        %>
        <div class="col-md-6">
            <div class="work-card <%= scored ? "scored" : "unscored" %>"
                 onclick="location.href='${pageContext.request.contextPath}/score?action=input&workId=<%= w.getWorkId() %>'">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <div class="work-title"><%= w.getTitle() %></div>
                        <div class="work-meta">
                            <i class="fas fa-users me-1"></i>队伍ID: <%= w.getTeamId() %>
                            <span class="mx-2">|</span>
                            <i class="fas fa-calendar me-1"></i><%= w.getSubmitTime() != null ? w.getSubmitTime().format(dtf) : "未知" %>
                        </div>
                    </div>
                    <div>
                        <% if (scored) { %>
                        <span class="badge bg-success badge-score">
                            <i class="fas fa-check me-1"></i>已评分: <%= String.format("%.1f", myScoreVal) %>分
                        </span>
                        <% } else { %>
                        <span class="badge bg-warning text-dark badge-score">
                            <i class="fas fa-hourglass-half me-1"></i>待评分
                        </span>
                        <% } %>
                    </div>
                </div>
                <% if (w.getDescription() != null && !w.getDescription().isEmpty()) { %>
                <div class="mt-2" style="font-size:0.85rem;color:var(--gray);">
                    <%= w.getDescription().length() > 80 ? w.getDescription().substring(0, 80) + "..." : w.getDescription() %>
                </div>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
    <% } %>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function updateScoreDisplay(val) {
        document.getElementById('scoreDisplay').textContent = parseFloat(val).toFixed(1);
        document.getElementById('scoreInput').value = parseFloat(val).toFixed(1);
    }
    function syncSlider(val) {
        if (val === '' || val < 0) val = 0;
        if (val > 100) val = 100;
        document.getElementById('scoreSlider').value = parseFloat(val);
        document.getElementById('scoreDisplay').textContent = parseFloat(val).toFixed(1);
    }
    function validateScore() {
        var score = document.getElementById('scoreSlider').value;
        if (score < 0 || score > 100) {
            alert('分数必须在0-100之间');
            return false;
        }
        return true;
    }
</script>

</body>
</html>
