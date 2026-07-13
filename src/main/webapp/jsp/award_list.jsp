
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Award" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
<%
    User sessionUser = (User) session.getAttribute("user");

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
    List<Award> awards = (List<Award>) request.getAttribute("awards");
    Competition competition = (Competition) request.getAttribute("competition");
    @SuppressWarnings("unchecked")
    Map<Integer, Work> workMap = (Map<Integer, Work>) request.getAttribute("workMap");
    @SuppressWarnings("unchecked")
    Map<Integer, String> teamNameMap = (Map<Integer, String>) request.getAttribute("teamNameMap");
    @SuppressWarnings("unchecked")
    Map<Integer, Double> avgScoreMap = (Map<Integer, Double>) request.getAttribute("avgScoreMap");
    @SuppressWarnings("unchecked")
    List<Competition> endedCompetitions = (List<Competition>) request.getAttribute("endedCompetitions");
    int selectedCompId = competition != null ? competition.getCompetitionId() : 0;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>往届获奖记录 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #6C5CE7; --primary-light: #A29BFE; --accent: #FD79A8;
            --dark: #2D3436; --gray: #636E72; --gold: #FFD700; --silver: #C0C0C0; --bronze: #CD7F32;
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

        .page-header {
            background: linear-gradient(135deg, #6C5CE7 0%, #A29BFE 100%);
            border-radius: 20px;
            padding: 2.5rem 2rem;
            margin: 2rem 0;
            color: white;
            text-align: center;
        }
        .page-header h2 { font-weight: 700; margin: 0; }
        .page-header p { opacity: 0.9; margin: 0.5rem 0 0; }

        .award-card {
            background: white;
            border-radius: 20px;
            padding: 0;
            margin-bottom: 1.5rem;
            box-shadow: var(--card-shadow);
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .award-card:hover { transform: translateY(-4px); box-shadow: 0 8px 30px rgba(108, 92, 231, 0.15); }

        .award-card.first  { border-top: 4px solid #FFD700; }
        .award-card.second { border-top: 4px solid #C0C0C0; }
        .award-card.third  { border-top: 4px solid #CD7F32; }

        .award-rank {
            width: 60px; height: 60px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem; font-weight: 700; color: white;
        }
        .rank-1 { background: linear-gradient(135deg, #FFD700, #FFA500); }
        .rank-2 { background: linear-gradient(135deg, #C0C0C0, #909090); }
        .rank-3 { background: linear-gradient(135deg, #CD7F32, #A0522D); }

        .empty-state { text-align: center; padding: 4rem 2rem; color: var(--gray); }
        .empty-state i { font-size: 4rem; margin-bottom: 1rem; opacity: 0.4; }
    </style>
</head>
<body>

<!-- 导航栏 -->
<%
    request.setAttribute("activeNav", "awards");
%>
<%@ include file="includes/navbar.jspf" %>

<div class="container">
    <div class="page-header">
        <h2><i class="fas fa-history"></i> 往届获奖记录</h2>
        <p>查看已结束竞赛的获奖作品与荣誉表彰</p>
    </div>

    <%-- 竞赛选择器 --%>
    <% if (endedCompetitions != null && !endedCompetitions.isEmpty()) { %>
    <div class="competition-selector mb-4">
        <form method="get" action="${pageContext.request.contextPath}/award" class="d-flex align-items-center gap-2 flex-wrap">
            <input type="hidden" name="action" value="list">
            <label class="fw-bold text-nowrap"><i class="fas fa-trophy me-1" style="color:var(--primary)"></i>选择竞赛：</label>
            <select name="competitionId" class="form-select" style="max-width:400px" onchange="this.form.submit()">
                <% for (Competition ec : endedCompetitions) {
                    boolean isSelected = ec.getCompetitionId().equals(selectedCompId);
                %>
                <option value="<%= ec.getCompetitionId() %>" <%= isSelected ? "selected" : "" %>>
                    <%= ec.getYear() != null ? ec.getYear() + "年 " : "" %><%= HtmlEscaper.escape(ec.getName()) %>
                </option>
                <% } %>
            </select>
        </form>
    </div>
    <% } %>

    <% if (awards != null && !awards.isEmpty() && competition != null) { %>
        <section class="mb-5">
            <div class="d-flex align-items-center justify-content-between mb-3">
                <div>
                    <h4 class="fw-bold mb-1"><i class="fas fa-flag text-primary me-2"></i><%= HtmlEscaper.escape(competition.getName()) %></h4>
                    <small class="text-muted"><%= competition.getYear() != null ? competition.getYear() + " 年" : "" %> 获奖作品</small>
                </div>
                <a class="btn btn-outline-primary btn-sm" href="${pageContext.request.contextPath}/work?action=competitionWorks&competitionId=<%= competition.getCompetitionId() %>">
                    <i class="fas fa-images me-1"></i>查看作品展厅
                </a>
            </div>
            <div class="row">
            <% int rank = 0;
               for (Award award : awards) {
                   rank++;
                   Work work = workMap != null ? workMap.get(award.getWorkId()) : null;
                   String teamName = teamNameMap != null ? teamNameMap.get(award.getWorkId()) : "未知队伍";

                   String cardClass = "";
                   String rankClass = "";
                   if ("一等奖".equals(award.getAwardLevel())) { cardClass = "first"; rankClass = "rank-1"; }
                   else if ("二等奖".equals(award.getAwardLevel())) { cardClass = "second"; rankClass = "rank-2"; }
                   else { cardClass = "third"; rankClass = "rank-3"; }
            %>
            <div class="col-md-6 col-lg-4">
                <div class="award-card <%= cardClass %>">
                    <div class="p-4">
                        <div class="d-flex align-items-center mb-3">
                            <div class="award-rank <%= rankClass %> me-3"><%= rank %></div>
                            <div>
                                <div class="fw-bold fs-5"><%= HtmlEscaper.escape(work != null ? work.getTitle() : "作品#" + award.getWorkId()) %></div>
                                <small class="text-muted"><i class="fas fa-users"></i> <%= HtmlEscaper.escape(teamName) %></small>
                            </div>
                        </div>
                        <div class="d-flex justify-content-between align-items-center">
                            <span class="badge <%= "一等奖".equals(award.getAwardLevel()) ? "bg-warning text-dark" : ("二等奖".equals(award.getAwardLevel()) ? "bg-secondary" : "bg-danger") %> fs-6">
                                <i class="fas fa-trophy"></i> <%= HtmlEscaper.escape(award.getAwardLevel()) %>
                            </span>
                            <span class="text-muted"><%= String.format("%.1f", award.getFinalScore()) %> 分</span>
                        </div>
                        <div class="mt-3 d-grid gap-2">
                            <% if (work != null) { %>
                            <a href="${pageContext.request.contextPath}/work?action=detail&id=<%= work.getWorkId() %>" class="btn btn-outline-secondary btn-sm">
                                <i class="fas fa-eye"></i> 查看作品
                            </a>
                            <% } %>
                            <a href="${pageContext.request.contextPath}/certificate?action=view&awardId=<%= award.getAwardId() %>"
                               class="btn btn-outline-primary btn-sm" target="_blank">
                                <i class="fas fa-certificate"></i> 查看奖状
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
            </div>
        </section>
    <% } else { %>
    <div class="empty-state">
        <i class="fas fa-medal"></i>
        <h5><%= endedCompetitions == null || endedCompetitions.isEmpty() ? "暂无已结束的竞赛" : "该竞赛暂无获奖记录" %></h5>
        <p class="text-muted"><%= endedCompetitions == null || endedCompetitions.isEmpty() ? "获奖作品将在竞赛评审结束后公布，敬请期待！" : "请选择其他竞赛查看获奖记录" %></p>
    </div>
    <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
