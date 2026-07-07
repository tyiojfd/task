<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.model.CompetitionCategory" %>
<%@ page import="java.util.List" %>
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
    List<Competition> competitions = (List<Competition>) request.getAttribute("competitions");
    @SuppressWarnings("unchecked")
    List<CompetitionCategory> categories = (List<CompetitionCategory>) request.getAttribute("categories");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>创建队伍 - 大学生海报设计竞赛系统</title>
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
            --card-shadow: 0 2px 16px rgba(108, 92, 231, 0.08);
            --card-hover-shadow: 0 8px 32px rgba(108, 92, 231, 0.16);
        }

        body {
            background: linear-gradient(135deg, #F8F9FA 0%, #E8ECF1 100%);
            min-height: 100vh;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'PingFang SC', 'Microsoft YaHei', sans-serif;
        }

        /* ── 顶部导航 ── */
        .navbar { background: var(--dark) !important; box-shadow: 0 2px 12px rgba(0,0,0,0.15); }
        .navbar-brand { font-weight: 700; letter-spacing: 0.5px; }
        .navbar-brand i { color: var(--primary-light); margin-right: 6px; }
        .nav-link { font-size: 0.9rem; transition: color 0.2s; }
        .nav-link:hover { color: var(--primary-light) !important; }
        .nav-link.active { color: var(--primary-light) !important; font-weight: 600; }

        /* ── 步骤指示器 ── */
        .steps-bar {
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 2rem 0 2.5rem;
            position: relative;
        }
        .step-item {
            display: flex;
            align-items: center;
            gap: 10px;
            z-index: 2;
            background: var(--light-bg);
            padding: 0 20px;
        }
        .step-circle {
            width: 40px; height: 40px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 1rem;
            transition: all 0.3s;
        }
        .step-circle.done {
            background: var(--primary);
            color: white;
        }
        .step-circle.active {
            background: white;
            color: var(--primary);
            border: 3px solid var(--primary);
            box-shadow: 0 0 0 6px rgba(108, 92, 231, 0.15);
        }
        .step-circle.pending {
            background: #DFE6E9;
            color: #B2BEC3;
        }
        .step-label { font-size: 0.85rem; font-weight: 600; color: var(--gray); }
        .step-label.done { color: var(--primary); }

        .step-connector {
            width: 80px; height: 3px;
            background: #DFE6E9;
            z-index: 1;
            border-radius: 2px;
        }
        .step-connector.done {
            background: var(--primary);
        }

        /* ── 竞赛选择卡片 ── */
        .comp-select-card {
            border: 2px solid #E8ECF1;
            border-radius: 16px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.25s;
            background: white;
            position: relative;
            height: 100%;
        }
        .comp-select-card:hover {
            border-color: var(--primary-light);
            box-shadow: var(--card-hover-shadow);
            transform: translateY(-2px);
        }
        .comp-select-card.selected {
            border-color: var(--primary);
            background: linear-gradient(135deg, #F8F7FF 0%, #EDE9FE 100%);
            box-shadow: 0 0 0 4px rgba(108, 92, 231, 0.12);
        }
        .comp-select-card input[type="radio"] { display: none; }
        .comp-select-card .comp-icon {
            width: 48px; height: 48px;
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem;
            margin-bottom: 12px;
        }
        .comp-select-card .badge-status {
            position: absolute;
            top: 16px; right: 16px;
            font-size: 0.75rem;
        }

        /* ── 表单卡片 ── */
        .form-card {
            background: white;
            border-radius: 20px;
            box-shadow: var(--card-shadow);
            border: none;
            overflow: hidden;
        }
        .form-card .card-header {
            background: linear-gradient(135deg, var(--primary) 0%, #8B7CF6 100%);
            color: white;
            border: none;
            padding: 1.2rem 1.8rem;
        }
        .form-card .card-body { padding: 2rem; }
        .form-label { font-weight: 600; font-size: 0.9rem; color: var(--dark); margin-bottom: 0.5rem; }
        .form-label i { color: var(--primary); width: 20px; margin-right: 4px; }
        .form-control, .form-select {
            border: 2px solid #EAEEF2;
            border-radius: 12px;
            padding: 0.65rem 1rem;
            transition: all 0.25s;
            font-size: 0.95rem;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(108, 92, 231, 0.1);
        }
        textarea.form-control { resize: none; }

        .btn-primary-action {
            background: linear-gradient(135deg, var(--primary) 0%, #8B7CF6 100%);
            border: none;
            border-radius: 12px;
            padding: 0.7rem 2rem;
            font-weight: 600;
            font-size: 1rem;
            color: white;
            transition: all 0.3s;
            box-shadow: 0 4px 14px rgba(108, 92, 231, 0.3);
        }
        .btn-primary-action:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(108, 92, 231, 0.45);
            color: white;
        }
        .btn-secondary-action {
            border: 2px solid #DFE6E9;
            border-radius: 12px;
            padding: 0.7rem 2rem;
            font-weight: 600;
            font-size: 1rem;
            color: var(--gray);
            transition: all 0.3s;
            background: white;
        }
        .btn-secondary-action:hover {
            border-color: var(--gray);
            color: var(--dark);
        }

        /* ── 提示卡片 ── */
        .tips-card {
            background: linear-gradient(135deg, #FFF8E1 0%, #FFF3CD 100%);
            border: 1px solid #FFE082;
            border-radius: 16px;
            padding: 1.2rem 1.5rem;
        }
        .tips-card i { color: #F39C12; }
        .tips-card li { margin-bottom: 0.35rem; font-size: 0.9rem; color: #6D5E00; }

        /* ── 预览卡片 ── */
        .preview-card {
            background: white;
            border-radius: 16px;
            box-shadow: var(--card-shadow);
            padding: 1.5rem;
            position: sticky;
            top: 1rem;
        }
        .preview-card .team-preview-avatar {
            width: 64px; height: 64px;
            border-radius: 16px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--accent) 100%);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.6rem;
            color: white;
            margin-bottom: 1rem;
        }
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
                    <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/team?action=myTeams">我的队伍</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/invitation">邀请通知</a></li>
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

    <div class="container mt-4">
        <!-- ═══════════ 步骤指示器 ═══════════ -->
        <div class="steps-bar">
            <span class="step-item">
                <span class="step-circle active">1</span>
                <span class="step-label">组建队伍</span>
            </span>
            <span class="step-connector"></span>
            <span class="step-item">
                <span class="step-circle pending">2</span>
                <span class="step-label">邀请队员</span>
            </span>
            <span class="step-connector"></span>
            <span class="step-item">
                <span class="step-circle pending">3</span>
                <span class="step-label">报名参赛</span>
            </span>
        </div>

        <div class="row">
            <!-- ═══════════ 左侧表单 ═══════════ -->
            <div class="col-lg-8">
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show rounded-3" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i><%= request.getAttribute("error") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/team?action=create" method="post" id="createTeamForm">

                    <!-- 选择竞赛 -->
                    <div class="form-card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-trophy me-2"></i>选择参赛竞赛</h5>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <% if (competitions != null && !competitions.isEmpty()) {
                                    int idx = 0;
                                    for (Competition comp : competitions) {
                                        String statusColor = comp.getStatus() == 1 ? "success" : comp.getStatus() == 2 ? "primary" : "secondary";
                                        String statusText = comp.getStatus() == 1 ? "报名中" : comp.getStatus() == 2 ? "进行中" : "已结束";
                                        String[] iconColors = {"#6C5CE7", "#FD79A8", "#00CEC9", "#FDCB6E", "#E17055", "#74B9FF"};
                                        String iconColor = iconColors[idx % iconColors.length];
                                %>
                                    <div class="col-md-6">
                                        <label class="comp-select-card <%= idx == 0 ? "selected" : "" %>" for="comp_<%= comp.getCompetitionId() %>">
                                            <input type="radio" name="competitionId" id="comp_<%= comp.getCompetitionId() %>"
                                                   value="<%= comp.getCompetitionId() %>" <%= idx == 0 ? "checked" : "" %>
                                                   onchange="selectCompetition(this)">
                                            <span class="badge bg-<%= statusColor %> badge-status"><%= statusText %></span>
                                            <div class="comp-icon" style="background: <%= iconColor %>1A; color: <%= iconColor %>;">
                                                <i class="fas fa-<%= idx % 2 == 0 ? "medal" : "star" %>"></i>
                                            </div>
                                            <h6 class="fw-bold mb-1"><%= comp.getName() %></h6>
                                            <p class="text-muted small mb-0"><%= comp.getYear() %>年度 · 最多<%= comp.getMaxTeamSize() %>人/队</p>
                                            <% if (comp.getTheme() != null && !comp.getTheme().isEmpty()) { %>
                                                <span class="badge bg-light text-muted mt-2"><i class="fas fa-tag me-1"></i><%= comp.getTheme() %></span>
                                            <% } %>
                                        </label>
                                    </div>
                                <%      idx++;
                                    }
                                } else { %>
                                    <div class="col-12 text-center py-4">
                                        <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                        <p class="text-muted">暂无可报名的竞赛</p>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- 队伍信息 -->
                    <div class="form-card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-users me-2"></i>填写队伍信息</h5>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-md-7">
                                    <label for="teamName" class="form-label"><i class="fas fa-flag"></i> 队伍名称 *</label>
                                    <input type="text" class="form-control" id="teamName" name="teamName"
                                           placeholder="给你的队伍起个响亮的名字" required minlength="2" maxlength="100">
                                </div>
                                <div class="col-md-5">
                                    <label for="categoryId" class="form-label"><i class="fas fa-layer-group"></i> 参赛子类 *</label>
                                    <select class="form-select" id="categoryId" name="categoryId" required>
                                        <option value="">选择参赛方向</option>
                                        <% if (categories != null && !categories.isEmpty()) {
                                            for (CompetitionCategory cat : categories) {
                                        %>
                                            <option value="<%= cat.getCategoryId() %>"
                                                    data-comp-id="<%= cat.getCompetitionId() %>">
                                                <%= cat.getCategoryName() %>
                                            </option>
                                        <%  }
                                        } else { %>
                                            <option value="" disabled>暂无子类数据，请先联系管理员创建竞赛和子类</option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="col-12">
                                    <label for="teamDesc" class="form-label"><i class="fas fa-align-left"></i> 队伍简介</label>
                                    <textarea class="form-control" id="teamDesc" name="teamDesc" rows="3"
                                              placeholder="介绍一下你们队伍的特色、设计理念或目标..." maxlength="500"></textarea>
                                    <div class="form-text text-end"><span id="charCount">0</span>/500</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 操作按钮 -->
                    <div class="d-flex justify-content-between mb-4">
                        <a href="${pageContext.request.contextPath}/team?action=myTeams" class="btn-secondary-action text-decoration-none">
                            <i class="fas fa-arrow-left me-2"></i>返回列表
                        </a>
                        <button type="submit" class="btn-primary-action">
                            <i class="fas fa-rocket me-2"></i>创建队伍
                        </button>
                    </div>
                </form>
            </div>

            <!-- ═══════════ 右侧面板 ═══════════ -->
            <div class="col-lg-4">
                <div class="preview-card mb-4">
                    <div class="team-preview-avatar">
                        <i class="fas fa-users"></i>
                    </div>
                    <h6 class="fw-bold">创建须知</h6>
                    <div class="tips-card mt-3">
                        <ul class="mb-0 ps-3">
                            <li>创建后你将成为<b>队长</b></li>
                            <li>可通过邀请码邀请队员加入</li>
                            <li>每队最多<b>5名</b>成员</li>
                            <li>报名截止前完成组队</li>
                        </ul>
                    </div>
                </div>

                <div class="preview-card">
                    <h6 class="fw-bold mb-3"><i class="fas fa-lightbulb text-warning me-2"></i>组队小贴士</h6>
                    <p class="text-muted small mb-2">🎨 成员搭配建议：</p>
                    <div class="d-flex flex-wrap gap-2">
                        <span class="badge bg-light text-dark border">设计师</span>
                        <span class="badge bg-light text-dark border">文案策划</span>
                        <span class="badge bg-light text-dark border">技术达人</span>
                        <span class="badge bg-light text-dark border">摄影后期</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 竞赛卡片选择交互 + 子类过滤
        function selectCompetition(radio) {
            document.querySelectorAll('.comp-select-card').forEach(card => card.classList.remove('selected'));
            radio.closest('.comp-select-card').classList.add('selected');
            filterCategories(radio.value);
        }

        // 根据选中的竞赛过滤子类下拉框
        function filterCategories(competitionId) {
            var select = document.getElementById('categoryId');
            var options = select.querySelectorAll('option');
            var hasVisible = false;
            options.forEach(function(opt) {
                if (opt.value === '') return; // 跳过"选择参赛方向"
                var compId = opt.getAttribute('data-comp-id');
                if (compId === competitionId) {
                    opt.style.display = '';
                    if (!hasVisible) {
                        hasVisible = true;
                    }
                } else {
                    opt.style.display = 'none';
                }
            });
            // 如果当前选中项被隐藏了，重置为默认
            if (select.options[select.selectedIndex] &&
                select.options[select.selectedIndex].style.display === 'none') {
                select.value = '';
            }
        }

        // 页面加载时，根据默认选中的竞赛过滤
        (function() {
            var checkedRadio = document.querySelector('input[name="competitionId"]:checked');
            if (checkedRadio) {
                filterCategories(checkedRadio.value);
            }
        })();

        // 字数统计
        const textarea = document.getElementById('teamDesc');
        const charCount = document.getElementById('charCount');
        if (textarea && charCount) {
            textarea.addEventListener('input', () => charCount.textContent = textarea.value.length);
        }
    </script>
</body>
</html>
