<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.TeamMember" %>
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

    int memberCount = members != null ? members.size() : 0;
    boolean isLeader = team.getLeaderId().equals(sessionUser.getUserId());

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy骞碝M鏈坉d鏃?HH:mm");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= team.getTeamName() %> - 澶у鐢熸捣鎶ヨ璁＄珵璧涚郴缁?/title>
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

        /* 鈹€鈹€ 灏侀潰妯箙 鈹€鈹€ */
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

        /* 鈹€鈹€ Tab 瀵艰埅 鈹€鈹€ */
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

        /* 鈹€鈹€ 淇℃伅鍗＄墖 鈹€鈹€ */
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

        /* 鈹€鈹€ 鎴愬憳缃戞牸 鈹€鈹€ */
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

        /* 鈹€鈹€ 鎿嶄綔鎸夐挳 鈹€鈹€ */
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

        /* 鈹€鈹€ alert / breadcrumb 鈹€鈹€ */
        .breadcrumb { margin-bottom: 0; }
        .breadcrumb-item a { color: var(--primary); text-decoration: none; font-weight: 500; }
        .alert { border-radius: 14px; border: none; }

        /* 鈹€鈹€ 缁熻鏁板瓧 鈹€鈹€ */
        .stat-mini { text-align: center; padding: 0.5rem; }
        .stat-mini .number { font-size: 1.5rem; font-weight: 800; color: var(--dark); }
        .stat-mini .label  { font-size: 0.75rem; color: var(--gray); }
    </style>
</head>
<body>
    <!-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?瀵艰埅鏍?鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?-->
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/index">
                <i class="fas fa-palette"></i> 娴锋姤绔炶禌绯荤粺
            </a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/index"><i class="fas fa-home"></i> 棣栭〉</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/competition?action=list"><i class="fas fa-trophy"></i> 绔炶禌鍒楄〃</a></li>
                    <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/team?action=myTeams"><i class="fas fa-users"></i> 鎴戠殑闃熶紞</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/profile"><i class="fas fa-user-circle"></i> 涓汉涓績</a></li>
                    <li class="nav-item"><a class="nav-link text-danger" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> 閫€鍑?/a></li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container">
        <!-- 闈㈠寘灞?-->
        <nav class="mt-3" aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/team?action=myTeams"><i class="fas fa-users me-1"></i>鎴戠殑闃熶紞</a></li>
                <li class="breadcrumb-item active"><%= team.getTeamName() %></li>
            </ol>
        </nav>

        <!-- 鎻愮ず娑堟伅 -->
        <% String msg = request.getParameter("msg"); %>
        <% if ("invite_success".equals(msg)) { %>
            <div class="alert alert-success alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i>閭€璇峰彂閫佹垚鍔燂紒<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
        <% } else if ("remove_success".equals(msg)) { %>
            <div class="alert alert-success alert-dismissible fade show"><i class="fas fa-check-circle me-2"></i>绉婚櫎鎴愬姛锛?button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
        <% } %>
        <% String error = request.getParameter("error"); %>
        <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show"><i class="fas fa-exclamation-circle me-2"></i><%= error %><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
        <% } %>

        <!-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?灏侀潰妯箙 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?-->
        <div class="cover-banner">
            <div class="cover-content">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="team-logo">
                        <i class="fas fa-users"></i>
                    </div>
                    <div>
                        <h2 class="mb-1"><%= team.getTeamName() %></h2>
                        <div class="cover-meta">
                            <i class="fas fa-trophy me-1"></i><%= competitionName != null ? competitionName : "鏈寚瀹氱珵璧? %>
                            <span class="mx-2">路</span>
                            <i class="fas fa-layer-group me-1"></i><%= categoryName != null ? categoryName : "鏈寚瀹氬瓙绫? %>
                        </div>
                    </div>
                    <div class="ms-auto text-end">
                        <% if (team.getStatus() == 1) { %>
                            <span class="badge bg-warning text-dark fs-6">缁勫缓涓?/span>
                        <% } else if (team.getStatus() == 2) { %>
                            <span class="badge bg-success fs-6">宸叉姤鍚?/span>
                        <% } else { %>
                            <span class="badge bg-secondary fs-6">宸插彇娑?/span>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-3">
            <!-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?宸︿晶涓诲唴瀹?鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?-->
            <div class="col-lg-8">
                <!-- Tab 瀵艰埅 -->
                <div class="tab-nav">
                    <button class="tab-btn active" onclick="switchTab('overview', this)"><i class="fas fa-info-circle me-1"></i>姒傝</button>
                    <button class="tab-btn" onclick="switchTab('members', this)"><i class="fas fa-user-friends me-1"></i>鎴愬憳 (<%= memberCount %>)</button>
                    <button class="tab-btn" onclick="switchTab('works', this)"><i class="fas fa-image me-1"></i>浣滃搧</button>
                </div>

                <!-- Tab: 姒傝 -->
                <div class="tab-panel active" id="tab-overview">
                    <div class="info-card mb-3">
                        <h6 class="mb-3">闃熶紞淇℃伅</h6>
                        <div class="row g-3">
                            <div class="col-6 col-md-3">
                                <div class="stat-mini">
                                    <div class="number" style="color:var(--primary)"><%= memberCount %></div>
                                    <div class="label">鎴愬憳浜烘暟</div>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="stat-mini">
                                    <div class="number" style="color:#00CEC9"><%= team.getStatus() == 1 ? "缁勫缓涓? : team.getStatus() == 2 ? "宸叉姤鍚? : "宸插彇娑? %></div>
                                    <div class="label">闃熶紞鐘舵€?/div>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="stat-mini">
                                    <div class="number" style="color:#F39C12">0</div>
                                    <div class="label">鎻愪氦浣滃搧</div>
                                </div>
                            </div>
                            <div class="col-6 col-md-3">
                                <div class="stat-mini">
                                    <div class="number" style="color:#FD79A8">0</div>
                                    <div class="label">鑾峰緱鐐硅禐</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="info-card mb-3">
                        <h6 class="mb-3">鍩烘湰淇℃伅</h6>
                        <div class="info-item">
                            <div class="info-icon" style="background:#EDE9FE; color:var(--primary)"><i class="fas fa-crown"></i></div>
                            <div>
                                <div class="small text-muted">闃熼暱</div>
                                <strong><%= leaderName != null ? leaderName : "鐢ㄦ埛 #" + team.getLeaderId() %></strong>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon" style="background:#E8F8F5; color:#00CEC9"><i class="fas fa-trophy"></i></div>
                            <div>
                                <div class="small text-muted">鍙傝禌绔炶禌</div>
                                <strong><%= competitionName != null ? competitionName : "鏈寚瀹? %></strong>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon" style="background:#FEF3E2; color:#F39C12"><i class="fas fa-layer-group"></i></div>
                            <div>
                                <div class="small text-muted">鍙傝禌瀛愮被</div>
                                <strong><%= categoryName != null ? categoryName : "鏈寚瀹? %></strong>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon" style="background:#FCE4EC; color:#FD79A8"><i class="fas fa-calendar-alt"></i></div>
                            <div>
                                <div class="small text-muted">鍒涘缓鏃堕棿</div>
                                <strong><%= team.getCreateTime() != null ? team.getCreateTime().format(dtf) : "鏈煡" %></strong>
                            </div>
                        </div>
                    </div>

                    <div class="info-card mb-3">
                        <h6 class="mb-3">闃熶紞绠€浠?/h6>
                        <p class="text-muted mb-0">
                            <%= team.getTeamDesc() != null && !team.getTeamDesc().isEmpty() ? team.getTeamDesc() : "杩欎釜闃熶紞杩樻病鏈夊～鍐欑畝浠嬶紝蹇幓缂栬緫鍚?鉁? %>
                        </p>
                    </div>
                </div>

                <!-- Tab: 鎴愬憳 -->
                <div class="tab-panel" id="tab-members">
                    <div class="row g-3">
                        <% if (members != null && !members.isEmpty()) {
                            String[] avatarColors = {"#6C5CE7", "#FD79A8", "#00CEC9", "#F39C12", "#E17055", "#74B9FF"};
                            int aIdx = 0;
                            for (TeamMember m : members) {
                                User mu = memberUsers != null ? memberUsers.get(m.getUserId()) : null;
                                String name = mu != null ? mu.getRealName() : "鐢ㄦ埛 #" + m.getUserId();
                                String email = mu != null ? mu.getEmail() : "";
                                String initial = name.substring(0, 1);
                                String color = avatarColors[aIdx % avatarColors.length];
                                boolean isTeamLeader = m.getRole() != null && m.getRole() == 1;
                        %>
                            <div class="col-md-6">
                                <div class="member-grid-card" style="position:relative">
                                    <% if (isTeamLeader) { %>
                                        <span class="crown-badge" style="position:absolute; top:12px; right:16px;">
                                            <i class="fas fa-crown" style="color:#F39C12;" title="闃熼暱"></i>
                                        </span>
                                    <% } %>
                                    <div class="member-grid-avatar" style="background:<%= color %>; position:relative;">
                                        <%= initial %>
                                    </div>
                                    <h6 class="mb-0"><%= name %></h6>
                                    <span class="badge <%= isTeamLeader ? "bg-warning text-dark" : "bg-light text-muted" %> mt-1">
                                        <%= isTeamLeader ? "馃憫 闃熼暱" : "闃熷憳" %>
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
                                <p class="text-muted">鏆傛棤鎴愬憳鏁版嵁</p>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Tab: 浣滃搧 -->
                <div class="tab-panel" id="tab-works">
                    <div class="info-card text-center py-5">
                        <i class="fas fa-image fa-4x mb-3" style="color: #DFE6E9;"></i>
                        <h5 class="text-muted">鏆傛棤浣滃搧</h5>
                        <p class="text-muted">缁勯槦瀹屾垚鍚庡嵆鍙彁浜ゅ弬璧涗綔鍝?/p>
                    </div>
                </div>
            </div>

            <!-- 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?鍙充晶鎿嶄綔闈㈡澘 鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺愨晲鈺?-->
            <div class="col-lg-4">
                <div class="info-card mb-3">
                    <h6 class="mb-3"><i class="fas fa-cog me-2"></i>闃熶紞鎿嶄綔</h6>
                    <% if (isLeader) { %>
                        <div class="d-grid gap-2">
                            <button class="action-btn btn-edit" disabled>
                                <i class="fas fa-edit"></i>缂栬緫闃熶紞淇℃伅
                                <span class="badge bg-white text-dark ms-auto" style="font-size:0.65rem">鍗冲皢寮€鏀?/span>
                            </button>
                            <button class="action-btn btn-invite" disabled>
                                <i class="fas fa-user-plus"></i>閭€璇烽槦鍛?
                                <span class="badge bg-white text-dark ms-auto" style="font-size:0.65rem">鍗冲皢寮€鏀?/span>
                            </button>
                            <button class="action-btn btn-register" disabled>
                                <i class="fas fa-check-circle"></i>鎶ュ悕鍙傝禌
                                <span class="badge bg-white text-dark ms-auto" style="font-size:0.65rem">鍗冲皢寮€鏀?/span>
                            </button>
                            <hr>
                            <a href="${pageContext.request.contextPath}/team?action=delete&id=<%= team.getTeamId() %>"
                               class="action-btn btn-delete text-decoration-none"
                               onclick="return confirm('鈿狅笍 纭畾瑕佽В鏁ｉ槦浼嶃€?%= team.getTeamName() %>銆嶅悧锛焅n\n姝ゆ搷浣滀笉鍙仮澶嶏紝鎵€鏈夋垚鍛樺皢琚Щ闄ゃ€?)">
                                <i class="fas fa-trash-alt"></i>瑙ｆ暎闃熶紞
                            </a>
                        </div>
                    <% } else { %>
                        <p class="text-muted text-center py-3">
                            <i class="fas fa-lock fa-2x d-block mb-2"></i>
                            浠呴槦闀垮彲鎿嶄綔闃熶紞璁剧疆
                        </p>
                    <% } %>
                </div>

                <div class="info-card">
                    <h6 class="mb-3"><i class="fas fa-lightbulb me-2" style="color:#F39C12;"></i>涓嬩竴姝ュ仛浠€涔堬紵</h6>
                    <div class="d-flex flex-column gap-2">
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge rounded-pill" style="background:var(--primary);">1</span>
                            <small>閭€璇烽槦鍛樺姞鍏ラ槦浼?/small>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge rounded-pill" style="background:#B2BEC3;">2</span>
                            <small class="text-muted">瀹屾垚闃熶紞缁勫缓</small>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge rounded-pill" style="background:#B2BEC3;">3</span>
                            <small class="text-muted">鎻愪氦鍙傝禌浣滃搧</small>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge rounded-pill" style="background:#B2BEC3;">4</span>
                            <small class="text-muted">绛夊緟璇勫璇勫垎</small>
                        </div>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/team?action=myTeams" class="btn btn-light w-100 mt-3 rounded-3 py-2 fw-bold" style="border:2px solid #EAEEF2">
                    <i class="fas fa-arrow-left me-2"></i>杩斿洖闃熶紞鍒楄〃
                </a>
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
    </script>
</body>
</html>
