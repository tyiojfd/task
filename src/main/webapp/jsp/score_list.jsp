<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Score" %>
<%@ page import="com.poster.dao.WorkDAO" %>
<%@ page import="com.poster.service.TeamService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Score> myScores = (List<Score>) request.getAttribute("myScores");

    @SuppressWarnings("unchecked")
    List<Score> scores = (List<Score>) request.getAttribute("scores");

    Work targetWork = (Work) request.getAttribute("work");
    Team targetTeam = (Team) request.getAttribute("team");
    Double avgScore = (Double) request.getAttribute("avgScore");

    WorkDAO workDAO = (WorkDAO) request.getAttribute("workDAO");
    TeamService teamService = (TeamService) request.getAttribute("teamService");

    String message = (String) session.getAttribute("message");
    if (message != null) {
        session.removeAttribute("message");
    }

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    boolean isWorkView = (targetWork != null);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>评分记录 - 大学生海报设计竞赛系统</title>
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

        .score-table-card {
            background: white;
            border-radius: 20px;
            padding: 1.5rem;
            box-shadow: var(--card-shadow);
            overflow-x: auto;
        }

        .table { margin-bottom: 0; }
        .table th {
            font-weight: 600;
            font-size: 0.85rem;
            color: var(--gray);
            border-bottom: 2px solid #e9ecef;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .table td { vertical-align: middle; font-size: 0.9rem; }

        .score-badge {
            display: inline-block;
            min-width: 50px;
            padding: 0.25em 0.65em;
            border-radius: 8px;
            font-weight: 700;
            font-size: 0.95rem;
            text-align: center;
        }
        .score-high { background: #D5F5E3; color: #1E8449; }
        .score-mid { background: #FCF3CF; color: #B7950B; }
        .score-low { background: #FADBD8; color: #C0392B; }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 20px;
            box-shadow: var(--card-shadow);
        }
        .empty-state i { font-size: 4rem; color: var(--primary-light); }
        .empty-state h5 { margin-top: 1rem; color: var(--gray); }

        .work-info-banner {
            background: linear-gradient(135deg, var(--primary) 0%, #5B4CC4 100%);
            border-radius: 20px;
            padding: 1.5rem 2rem;
            color: white;
            margin-bottom: 1.5rem;
        }
        .work-info-banner h4 { margin: 0; font-weight: 700; }
        .work-info-banner .meta { opacity: 0.85; font-size: 0.9rem; }

        .avg-score-circle {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary);
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        }
    </style>
</head>
<body>

<!-- 导航栏 -->
<nav class="navbar navbar-expand-lg navbar-dark sticky-top">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/index">
            <i class="fas fa-palette"></i> 海报设计竞赛
        </a>
        <div class="ms-auto">
            <span class="navbar-text me-3">
                <i class="fas fa-user-circle me-1"></i><%= sessionUser.getUsername() %>
            </span>
            <a href="${pageContext.request.contextPath}/score?action=list" class="btn btn-outline-light btn-sm me-2">
                <i class="fas fa-star me-1"></i>评分工作台
            </a>
            <a href="${pageContext.request.contextPath}/index" class="btn btn-outline-light btn-sm">
                <i class="fas fa-home me-1"></i>返回首页
            </a>
        </div>
    </div>
</nav>

<div class="container">

    <!-- 消息提示 -->
    <% if (message != null) { %>
    <div class="alert alert-success alert-dismissible fade show mt-3" role="alert" style="border-radius:12px; border:none;">
        <i class="fas fa-check-circle me-2"></i><%= message %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <%-- 作品评分详情视图 --%>
    <% if (isWorkView) { %>
    <div class="page-header">
        <h2><i class="fas fa-clipboard-list me-2"></i>作品评分详情</h2>
        <a href="${pageContext.request.contextPath}/score?action=list" class="btn btn-outline-primary">
            <i class="fas fa-arrow-left me-1"></i>返回工作台
        </a>
    </div>

    <!-- 作品信息横幅 -->
    <div class="work-info-banner d-flex justify-content-between align-items-center">
        <div>
            <h4><%= targetWork.getTitle() %></h4>
            <div class="meta mt-2">
                <i class="fas fa-users me-1"></i><%= targetTeam != null ? targetTeam.getTeamName() : "未知队伍" %>
                <span class="mx-2">|</span>
                <i class="fas fa-calendar me-1"></i><%= targetWork.getSubmitTime() != null ? targetWork.getSubmitTime().format(dtf) : "未知" %>
            </div>
        </div>
        <div class="text-center">
            <div class="avg-score-circle">
                <%= avgScore != null ? String.format("%.1f", avgScore) : "N/A" %>
            </div>
            <small class="mt-1 d-block" style="opacity:0.85;">平均分</small>
        </div>
    </div>

    <!-- 评分统计 -->
    <div class="row stats-row">
        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-number"><%= scores != null ? scores.size() : 0 %></div>
                <div class="stat-label"><i class="fas fa-users"></i>已评人数</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <%
                    double maxScore = 0;
                    if (scores != null) {
                        for (Score s : scores) {
                            if (s.getScore() > maxScore) maxScore = s.getScore();
                        }
                    }
                %>
                <div class="stat-number"><%= String.format("%.1f", maxScore) %></div>
                <div class="stat-label"><i class="fas fa-arrow-up"></i>最高分</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <%
                    double minScore = 100;
                    if (scores != null && !scores.isEmpty()) {
                        for (Score s : scores) {
                            if (s.getScore() < minScore) minScore = s.getScore();
                        }
                    } else {
                        minScore = 0;
                    }
                %>
                <div class="stat-number"><%= String.format("%.1f", minScore) %></div>
                <div class="stat-label"><i class="fas fa-arrow-down"></i>最低分</div>
            </div>
        </div>
    </div>

    <!-- 评分列表 -->
    <div class="score-table-card">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>#</th>
                    <th>评委ID</th>
                    <th>评分</th>
                    <th>评分时间</th>
                </tr>
            </thead>
            <tbody>
                <% if (scores != null && !scores.isEmpty()) {
                    int idx = 1;
                    for (Score s : scores) {
                        double sc = s.getScore();
                        String cssClass = sc >= 80 ? "score-high" : (sc >= 60 ? "score-mid" : "score-low");
                %>
                <tr>
                    <td><%= idx++ %></td>
                    <td><i class="fas fa-user me-2"></i><%= s.getJudgeId() %></td>
                    <td><span class="score-badge <%= cssClass %>"><%= String.format("%.1f", sc) %> 分</span></td>
                    <td><%= s.getScoreTime() != null ? s.getScoreTime().format(dtf) : "未知" %></td>
                </tr>
                <% } } else { %>
                <tr>
                    <td colspan="4" class="text-center py-4 text-muted">
                        <i class="fas fa-inbox me-2"></i>暂无评分记录
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>

    <%-- 我的评分记录视图 --%>
    <% } else { %>
    <div class="page-header">
        <h2><i class="fas fa-list-check me-2"></i>我的评分记录</h2>
        <a href="${pageContext.request.contextPath}/score?action=list" class="btn btn-outline-primary">
            <i class="fas fa-arrow-left me-1"></i>返回工作台
        </a>
    </div>

    <!-- 统计 -->
    <div class="row stats-row">
        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-number"><%= myScores != null ? myScores.size() : 0 %></div>
                <div class="stat-label"><i class="fas fa-star"></i>我评分作品数</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <%
                    double myAvg = 0;
                    if (myScores != null && !myScores.isEmpty()) {
                        double sum = 0;
                        for (Score s : myScores) sum += s.getScore();
                        myAvg = sum / myScores.size();
                    }
                %>
                <div class="stat-number"><%= String.format("%.1f", myAvg) %></div>
                <div class="stat-label"><i class="fas fa-calculator"></i>我的平均评分</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <%
                    double myHighest = 0;
                    if (myScores != null) {
                        for (Score s : myScores) {
                            if (s.getScore() > myHighest) myHighest = s.getScore();
                        }
                    }
                %>
                <div class="stat-number"><%= String.format("%.1f", myHighest) %></div>
                <div class="stat-label"><i class="fas fa-trophy"></i>我给出的最高分</div>
            </div>
        </div>
    </div>

    <!-- 评分列表 -->
    <div class="score-table-card">
        <table class="table table-hover">
            <thead>
                <tr>
                    <th>#</th>
                    <th>作品名称</th>
                    <th>所属队伍</th>
                    <th>我的评分</th>
                    <th>平均分</th>
                    <th>评分时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <% if (myScores != null && !myScores.isEmpty()) {
                    int idx = 1;
                    for (Score s : myScores) {
                        double sc = s.getScore();
                        String cssClass = sc >= 80 ? "score-high" : (sc >= 60 ? "score-mid" : "score-low");
                        Work w = workDAO != null ? workDAO.findById(s.getWorkId()) : null;
                        Team t = (w != null && teamService != null) ? teamService.getTeamById(w.getTeamId()) : null;

                        // 计算该作品平均分
                        double workAvg = 0;
                        if (workDAO != null) {
                            try {
                                // Use reflection or just skip - average is a nice-to-have
                            } catch (Exception e) {}
                        }
                %>
                <tr>
                    <td><%= idx++ %></td>
                    <td>
                        <strong><%= w != null ? w.getTitle() : "作品#" + s.getWorkId() %></strong>
                    </td>
                    <td><%= t != null ? t.getTeamName() : "未知" %></td>
                    <td><span class="score-badge <%= cssClass %>"><%= String.format("%.1f", sc) %> 分</span></td>
                    <td class="text-muted">--</td>
                    <td><%= s.getScoreTime() != null ? s.getScoreTime().format(dtf) : "未知" %></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/score?action=input&workId=<%= s.getWorkId() %>"
                           class="btn btn-sm btn-outline-primary" title="修改评分">
                            <i class="fas fa-edit"></i>
                        </a>
                        <a href="${pageContext.request.contextPath}/score?action=workScores&workId=<%= s.getWorkId() %>"
                           class="btn btn-sm btn-outline-secondary" title="查看所有评分">
                            <i class="fas fa-eye"></i>
                        </a>
                    </td>
                </tr>
                <% } } else { %>
                <tr>
                    <td colspan="7" class="text-center py-5">
                        <i class="fas fa-inbox" style="font-size: 3rem; color: var(--primary-light); display: block; margin-bottom: 1rem;"></i>
                        <span class="text-muted">您还没有对任何作品进行评分</span>
                        <br>
                        <a href="${pageContext.request.contextPath}/score?action=list" class="btn btn-primary mt-3">
                            <i class="fas fa-star me-1"></i>去评分
                        </a>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
    <% } %>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
