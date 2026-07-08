<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Award" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    @SuppressWarnings("unchecked")
    List<Role> userRoles = (List<Role>) session.getAttribute("roles");
    boolean isAdmin = false;
    if (userRoles != null) {
        for (Role role : userRoles) {
            if ("管理员".equals(role.getRoleName())) isAdmin = true;
        }
    }
    if (!isAdmin) {
        response.sendRedirect(request.getContextPath() + "/index");
        return;
    }

    String message = (String) session.getAttribute("message");
    if (message != null) { session.removeAttribute("message"); }
    String error = (String) session.getAttribute("error");
    if (error != null) { session.removeAttribute("error"); }

    @SuppressWarnings("unchecked")
    List<Competition> competitions = (List<Competition>) request.getAttribute("competitions");
    Competition selectedCompetition = (Competition) request.getAttribute("competition");

    @SuppressWarnings("unchecked")
    List<Work> works = (List<Work>) request.getAttribute("works");
    @SuppressWarnings("unchecked")
    List<Award> existingAwards = (List<Award>) request.getAttribute("existingAwards");
    @SuppressWarnings("unchecked")
    Set<Integer> awardedWorkIds = (Set<Integer>) request.getAttribute("awardedWorkIds");
    @SuppressWarnings("unchecked")
    Map<Integer, Double> avgScoreMap = (Map<Integer, Double>) request.getAttribute("avgScoreMap");
    @SuppressWarnings("unchecked")
    Map<Integer, String> teamNameMap = (Map<Integer, String>) request.getAttribute("teamNameMap");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>获奖管理 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #6C5CE7;
            --primary-light: #A29BFE;
            --accent: #FD79A8;
            --dark: #2D3436;
            --gray: #636E72;
            --gold: #FDCB6E;
            --silver: #B2BEC3;
            --bronze: #E17055;
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

        .page-header { display: flex; align-items: center; justify-content: space-between; margin: 2rem 0 1.5rem; flex-wrap: wrap; gap: 1rem; }
        .page-header h2 { font-weight: 700; color: var(--dark); margin: 0; }
        .page-header h2 i { color: var(--primary); }

        .card-custom {
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: var(--card-shadow);
            border-left: 4px solid var(--primary);
            transition: transform 0.2s;
        }
        .card-custom:hover { transform: translateY(-2px); }
        .card-custom.awarded { border-left-color: #00B894; }

        .award-badge-1 { background: linear-gradient(135deg, #FFD700, #FFA500); color: #fff; font-weight: 700; }
        .award-badge-2 { background: linear-gradient(135deg, #C0C0C0, #A0A0A0); color: #fff; font-weight: 700; }
        .award-badge-3 { background: linear-gradient(135deg, #CD7F32, #B8860B); color: #fff; font-weight: 700; }

        .empty-state { text-align: center; padding: 4rem 2rem; color: var(--gray); }
        .empty-state i { font-size: 4rem; margin-bottom: 1rem; opacity: 0.4; }

        .competition-selector .card {
            border: 2px solid transparent;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .competition-selector .card:hover { border-color: var(--primary-light); }
        .competition-selector .card.selected { border-color: var(--primary); background: #F0EDFF; }
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
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/news?action=list"><i class="fas fa-newspaper"></i> 新闻公告</a></li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle active" href="#" data-bs-toggle="dropdown"><i class="fas fa-crown"></i> 管理</a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/competition?action=add"><i class="fas fa-plus-circle"></i> 发布竞赛</a></li>
                        <li><a class="dropdown-item active" href="${pageContext.request.contextPath}/award?action=manage"><i class="fas fa-medal"></i> 获奖管理</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/news?action=manage"><i class="fas fa-newspaper"></i> 新闻管理</a></li>
                    </ul>
                </li>
            </ul>
            <ul class="navbar-nav">
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle"></i> <%= sessionUser.getUsername() %>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile"><i class="fas fa-cog"></i> 个人中心</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> 退出登录</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <h2><i class="fas fa-medal"></i> 获奖管理</h2>
    </div>

    <% if (message != null) { %>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="fas fa-check-circle"></i> <%= message %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>
    <% if (error != null) { %>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fas fa-exclamation-circle"></i> <%= error %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- 选择竞赛 -->
    <div class="card-custom mb-4">
        <h5 class="mb-3"><i class="fas fa-search"></i> 选择竞赛</h5>
        <div class="row competition-selector">
            <% if (competitions != null) {
                for (Competition comp : competitions) { %>
            <div class="col-md-4 col-lg-3 mb-2">
                <a href="?action=manage&competitionId=<%= comp.getCompetitionId() %>" class="text-decoration-none">
                    <div class="card p-3 <%= selectedCompetition != null && selectedCompetition.getCompetitionId().equals(comp.getCompetitionId()) ? "selected" : "" %>">
                        <div class="fw-bold text-dark"><%= comp.getName() %></div>
                        <small class="text-muted"><%= comp.getStatus() == 1 ? "报名中" : (comp.getStatus() == 2 ? "进行中" : "已结束") %></small>
                    </div>
                </a>
            </div>
            <%  }
            } %>
        </div>
    </div>

    <% if (selectedCompetition != null) { %>
    <!-- 获奖设置区域 -->
    <div class="row">
        <!-- 左侧：作品列表 -->
        <div class="col-lg-7">
            <h5 class="mb-3"><i class="fas fa-image"></i> <%= selectedCompetition.getTitle() %> - 作品列表</h5>

            <% if (works != null && !works.isEmpty()) {
                for (Work w : works) {
                    boolean awarded = awardedWorkIds != null && awardedWorkIds.contains(w.getWorkId());
                    Double avg = avgScoreMap != null ? avgScoreMap.get(w.getWorkId()) : 0.0;
                    String tName = teamNameMap != null ? teamNameMap.get(w.getWorkId()) : "未知队伍";
            %>
            <div class="card-custom <%= awarded ? "awarded" : "" %>">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <div class="fw-bold"><%= w.getTitle() %></div>
                        <small class="text-muted">
                            <i class="fas fa-users"></i> <%= tName %> &nbsp;
                            <i class="fas fa-star"></i> 均分: <%= String.format("%.1f", avg != null ? avg : 0.0) %>
                        </small>
                    </div>
                    <div class="col-md-3">
                        <% if (awarded) {
                            for (Award a : existingAwards) {
                                if (a.getWorkId().equals(w.getWorkId())) {
                                    String badgeClass = "award-badge-1";
                                    if ("二等奖".equals(a.getAwardLevel())) badgeClass = "award-badge-2";
                                    if ("三等奖".equals(a.getAwardLevel())) badgeClass = "award-badge-3";
                        %>
                            <span class="badge <%= badgeClass %>"><%= a.getAwardLevel() %></span>
                            <small class="d-block text-muted">得分: <%= String.format("%.1f", a.getFinalScore()) %></small>
                        <%      }
                            }
                        } else { %>
                            <span class="text-muted">未获奖</span>
                        <% } %>
                    </div>
                    <div class="col-md-3 text-end">
                        <% if (awarded) {
                            for (Award a : existingAwards) {
                                if (a.getWorkId().equals(w.getWorkId())) {
                        %>
                            <form method="post" style="display:inline"
                                  onsubmit="return confirm('确定要删除该获奖记录吗？奖状将一并删除。')">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="awardId" value="<%= a.getAwardId() %>">
                                <input type="hidden" name="competitionId" value="<%= selectedCompetition.getCompetitionId() %>">
                                <button type="submit" class="btn btn-outline-danger btn-sm">
                                    <i class="fas fa-trash"></i> 撤销
                                </button>
                            </form>
                        <%      }
                            }
                        } else { %>
                            <button class="btn btn-primary btn-sm" data-bs-toggle="modal"
                                    data-bs-target="#awardModal<%= w.getWorkId() %>">
                                <i class="fas fa-medal"></i> 设置获奖
                            </button>
                        <% } %>
                    </div>
                </div>
            </div>

            <% if (!awarded) { %>
            <!-- 设置获奖弹窗 -->
            <div class="modal fade" id="awardModal<%= w.getWorkId() %>" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <form method="post" action="${pageContext.request.contextPath}/award">
                            <input type="hidden" name="action" value="set">
                            <input type="hidden" name="competitionId" value="<%= selectedCompetition.getCompetitionId() %>">
                            <input type="hidden" name="workId" value="<%= w.getWorkId() %>">
                            <div class="modal-header">
                                <h5 class="modal-title"><i class="fas fa-medal"></i> 设置获奖</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label fw-bold">作品</label>
                                    <p class="form-control-plaintext"><%= w.getTitle() %></p>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">平均分</label>
                                    <p class="form-control-plaintext"><%= String.format("%.1f", avg != null ? avg : 0.0) %> 分</p>
                                </div>
                                <div class="mb-3">
                                    <label for="awardLevel<%= w.getWorkId() %>" class="form-label fw-bold">获奖等级</label>
                                    <select class="form-select" id="awardLevel<%= w.getWorkId() %>" name="awardLevel" required>
                                        <option value="">请选择获奖等级</option>
                                        <option value="一等奖">🏆 一等奖</option>
                                        <option value="二等奖">🥈 二等奖</option>
                                        <option value="三等奖">🥉 三等奖</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="finalScore<%= w.getWorkId() %>" class="form-label fw-bold">最终得分</label>
                                    <input type="number" class="form-control" id="finalScore<%= w.getWorkId() %>"
                                           name="finalScore" step="0.1" min="0" max="100"
                                           value="<%= String.format("%.1f", avg != null ? avg : 0.0) %>" required>
                                    <small class="text-muted">可基于平均分进行调整</small>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                                <button type="submit" class="btn btn-primary"><i class="fas fa-check"></i> 确认设置</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>

            <%  }
            } else { %>
            <div class="empty-state">
                <i class="fas fa-inbox"></i>
                <h5>该竞赛暂无已提交的作品</h5>
            </div>
            <% } %>
        </div>

        <!-- 右侧：已获奖列表 -->
        <div class="col-lg-5">
            <div class="card-custom">
                <h5 class="mb-3"><i class="fas fa-list-check"></i> 已获奖作品</h5>
                <% if (existingAwards != null && !existingAwards.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>作品ID</th>
                                <th>等级</th>
                                <th>得分</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Award a : existingAwards) {
                                String badgeClass = "award-badge-1";
                                if ("二等奖".equals(a.getAwardLevel())) badgeClass = "award-badge-2";
                                if ("三等奖".equals(a.getAwardLevel())) badgeClass = "award-badge-3";
                            %>
                            <tr>
                                <td>#<%= a.getWorkId() %></td>
                                <td><span class="badge <%= badgeClass %>"><%= a.getAwardLevel() %></span></td>
                                <td><%= String.format("%.1f", a.getFinalScore()) %></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/certificate?action=view&awardId=<%= a.getAwardId() %>"
                                       class="btn btn-sm btn-outline-primary" target="_blank">
                                        <i class="fas fa-certificate"></i> 奖状
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/award" class="mt-3">
                    <input type="hidden" name="action" value="publishAnnouncement">
                    <input type="hidden" name="competitionId" value="<%= selectedCompetition.getCompetitionId() %>">
                    <button type="submit" class="btn btn-success w-100"
                            onclick="return confirm('确定要发布获奖公告吗？公告将作为新闻发布。')">
                        <i class="fas fa-bullhorn"></i> 发布获奖公告
                    </button>
                </form>
                <% } else { %>
                <div class="empty-state" style="padding: 2rem;">
                    <i class="fas fa-medal" style="font-size: 2.5rem;"></i>
                    <p class="mt-2">尚未设置获奖</p>
                    <small class="text-muted">从左侧作品列表中选择作品设置获奖</small>
                </div>
                <% } %>
            </div>
        </div>
    </div>
    <% } else { %>
    <div class="card-custom">
        <div class="empty-state">
            <i class="fas fa-hand-pointer"></i>
            <h5>请先选择一个竞赛</h5>
            <p class="text-muted">选择竞赛后可管理该竞赛的获奖情况</p>
        </div>
    </div>
    <% } %>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
