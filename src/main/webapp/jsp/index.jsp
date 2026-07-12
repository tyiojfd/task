<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%!
    private String html(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String textOr(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value;
    }

    private String brief(String value, int maxLength) {
        String text = textOr(value, "主办方暂未填写详细介绍。");
        return text.length() <= maxLength ? text : text.substring(0, maxLength) + "...";
    }

    private String statusText(Integer status) {
        if (status != null && status == 1) return "报名中";
        if (status != null && status == 2) return "进行中";
        if (status != null && status == 3) return "已结束";
        return "已取消";
    }

    private String statusClass(Integer status) {
        if (status != null && status == 1) return "status-open";
        if (status != null && status == 2) return "status-live";
        if (status != null && status == 3) return "status-ended";
        return "status-closed";
    }

    private String displayName(User user) {
        if (user == null) return "";
        return textOr(user.getRealName(), textOr(user.getUsername(), "同学"));
    }
%>
<%
    User sessionUser = (User) session.getAttribute("user");
    @SuppressWarnings("unchecked")
    List<Role> userRoles = (sessionUser != null) ? (List<Role>) session.getAttribute("roles") : null;
    @SuppressWarnings("unchecked")
    List<Competition> competitions = (List<Competition>) request.getAttribute("competitions");
    @SuppressWarnings("unchecked")
    Map<String, Integer> globalStats = (Map<String, Integer>) request.getAttribute("globalStats");

    boolean isAdmin = false;
    boolean isJudge = false;
    boolean hasParticipantRole = false;
    if (userRoles != null) {
        for (Role role : userRoles) {
            if ("管理员".equals(role.getRoleName())) isAdmin = true;
            if ("评委".equals(role.getRoleName())) isJudge = true;
            if ("队员".equals(role.getRoleName()) || "队长".equals(role.getRoleName())) hasParticipantRole = true;
        }
    }
    boolean isParticipant = sessionUser != null && hasParticipantRole && !isAdmin && !isJudge;

    int compCount = globalStats != null && globalStats.get("compCount") != null ? globalStats.get("compCount") : (competitions != null ? competitions.size() : 0);
    int teamCount = globalStats != null && globalStats.get("teamCount") != null ? globalStats.get("teamCount") : 0;
    int workCount = globalStats != null && globalStats.get("workCount") != null ? globalStats.get("workCount") : 0;
    int activeCount = globalStats != null && globalStats.get("activeCount") != null ? globalStats.get("activeCount") : 0;
    String contextPath = request.getContextPath();
    String teamHref = isParticipant ? contextPath + "/team?action=myTeams" : contextPath + "/competition?action=list";
    String workHref = isParticipant ? contextPath + "/work?action=myWorks" : contextPath + "/competition?action=list";
    String scoreHref = sessionUser != null && isJudge ? contextPath + "/score?action=list" : contextPath + "/award?action=list";
    String certificateHref = isAdmin ? contextPath + "/certificate?action=list" : (isParticipant ? contextPath + "/certificate?action=myCertificates" : contextPath + "/award?action=list");
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy.MM.dd");
    String assetVersion = "20260709-clear3";
    String[] fallbackCovers = {
            contextPath + "/images/home/poster-1.png",
            contextPath + "/images/home/poster-2.png",
            contextPath + "/images/home/poster-3.png",
            contextPath + "/images/home/poster-4.png",
            contextPath + "/images/home/poster-5.png",
            contextPath + "/images/home/poster-6.png",
            contextPath + "/images/home/hero-1.png",
            contextPath + "/images/home/hero-2.png",
            contextPath + "/images/home/hero-3.png"
    };
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/home.css?v=<%= assetVersion %>" rel="stylesheet">
</head>
<body class="home-page">
    <%
    request.setAttribute("activeNav", "home");
%>
<%@ include file="includes/navbar.jspf" %>

    <main>
        <section class="hero-carousel" aria-label="赛事推荐轮播">
            <div class="hero-slide is-active" style="--hero-img: url('${pageContext.request.contextPath}/images/home/hero-1.png')">
                <div class="hero-content">
                    <p class="kicker">POSTER DESIGN COMPETITION</p>
                    <h1>发现正在报名的<br>海报设计竞赛</h1>
                    <p>精选赛题、投稿截止、获奖公示集中呈现，直接进入竞赛详情报名。</p>
                    <div class="hero-links">
                        <a href="${pageContext.request.contextPath}/competition?action=list">浏览全部竞赛 <i class="fa-solid fa-arrow-right"></i></a>
                        <% if (isParticipant) { %>
                            <a href="${pageContext.request.contextPath}/team?action=myTeams">我的参赛队伍</a>
                        <% } %>
                    </div>
                </div>
            </div>
            <div class="hero-slide" style="--hero-img: url('${pageContext.request.contextPath}/images/home/hero-2.png')">
                <div class="hero-content">
                    <p class="kicker">CAMPUS SHOWCASE</p>
                    <h1>优秀作品正在<br>被更多人看见</h1>
                    <p>从创作、提交到评审结果，所有作品沉淀为可浏览的校园创意档案。</p>
                    <div class="hero-links">
                        <a href="<%= workHref %>">查看作品入口 <i class="fa-solid fa-arrow-right"></i></a>
                        <a href="${pageContext.request.contextPath}/award?action=list">往届获奖</a>
                    </div>
                </div>
            </div>
            <div class="hero-slide" style="--hero-img: url('${pageContext.request.contextPath}/images/home/hero-3.png')">
                <div class="hero-content">
                    <p class="kicker">AWARD & CERTIFICATE</p>
                    <h1>赛题、评审、荣誉<br>清晰可追踪</h1>
                    <p>评委评分、获奖名单、电子奖状与新闻公告都围绕赛事内容展开。</p>
                    <div class="hero-links">
                        <a href="${pageContext.request.contextPath}/award?action=list">查看获奖 <i class="fa-solid fa-arrow-right"></i></a>
                        <a href="<%= certificateHref %>">奖状入口</a>
                    </div>
                </div>
            </div>

            <div class="carousel-dots" aria-label="轮播控制">
                <button class="is-active" type="button" aria-label="第 1 张"></button>
                <button type="button" aria-label="第 2 张"></button>
                <button type="button" aria-label="第 3 张"></button>
            </div>
        </section>

        <section class="content-section competitions-section" id="competitions">
            <div class="section-head reveal">
                <div>
                    <p class="kicker">OPEN EVENTS</p>
                    <h2>正在发生的赛题</h2>
                </div>
                <a class="section-link" href="${pageContext.request.contextPath}/competition?action=list">全部竞赛 <i class="fa-solid fa-arrow-right"></i></a>
            </div>

            <% if (competitions != null && !competitions.isEmpty()) { %>
                <div class="competition-strip">
                    <%
                        int shown = 0;
                        for (Competition comp : competitions) {
                            if (shown >= 6) break;
                            shown++;
                            String theme = textOr(comp.getTheme(), "海报设计");
                            String deadline = comp.getSubmitDeadline() != null ? comp.getSubmitDeadline().format(dateFormatter) : "待公布";
                            String fallback = fallbackCovers[(shown - 1) % fallbackCovers.length];
                            String uploadedCover = contextPath + "/uploads/competition_" + comp.getCompetitionId() + "/cover.jpg";
                    %>
                        <article class="event-card reveal">
                            <a class="event-cover" href="${pageContext.request.contextPath}/competition?action=detail&id=<%= comp.getCompetitionId() %>">
                                <img src="<%= uploadedCover %>" alt="<%= html(comp.getName()) %>" onerror="this.onerror=null;this.src='<%= fallback %>';">
                                <span class="status <%= statusClass(comp.getStatus()) %>"><%= statusText(comp.getStatus()) %></span>
                            </a>
                            <div class="event-body">
                                <small><%= comp.getYear() != null ? comp.getYear() + " 年" : "年度待定" %> / <%= html(theme) %></small>
                                <h3><a href="${pageContext.request.contextPath}/competition?action=detail&id=<%= comp.getCompetitionId() %>"><%= html(textOr(comp.getName(), "未命名竞赛")) %></a></h3>
                                <p><%= html(brief(comp.getDescription(), 54)) %></p>
                                <div class="event-meta">
                                    <span>截止 <%= html(deadline) %></span>
                                    <a href="${pageContext.request.contextPath}/competition?action=detail&id=<%= comp.getCompetitionId() %>">报名/详情</a>
                                </div>
                            </div>
                        </article>
                    <% } %>
                </div>
            <% } else { %>
                <div class="empty-state reveal">
                    <h3>暂无竞赛信息</h3>
                    <p>管理员发布竞赛后，这里会显示赛题封面、状态与报名入口。</p>
                    <% if (isAdmin) { %>
                        <a class="start-btn" href="${pageContext.request.contextPath}/competition?action=add">发布第一个竞赛</a>
                    <% } %>
                </div>
            <% } %>
        </section>

        <section class="content-section posters-section">
            <div class="section-head reveal">
                <div>
                    <p class="kicker">POPULAR POSTERS</p>
                    <h2>往届热门海报</h2>
                </div>
                <a class="section-link" href="${pageContext.request.contextPath}/award?action=list">往届获奖 <i class="fa-solid fa-arrow-right"></i></a>
            </div>

            <div class="poster-gallery">
                <article class="poster-card reveal">
                    <img src="${pageContext.request.contextPath}/images/home/poster-1.png" alt="往届热门海报 1">
                    <div><strong>城市视觉更新</strong><span>金奖作品</span></div>
                </article>
                <article class="poster-card reveal">
                    <img src="${pageContext.request.contextPath}/images/home/poster-2.png" alt="往届热门海报 2">
                    <div><strong>未来校园节</strong><span>人气作品</span></div>
                </article>
                <article class="poster-card reveal">
                    <img src="${pageContext.request.contextPath}/images/home/poster-3.png" alt="往届热门海报 3">
                    <div><strong>绿色设计周</strong><span>优秀作品</span></div>
                </article>
                <article class="poster-card reveal">
                    <img src="${pageContext.request.contextPath}/images/home/poster-4.png" alt="往届热门海报 4">
                    <div><strong>青年创想季</strong><span>评委推荐</span></div>
                </article>
                <article class="poster-card reveal">
                    <img src="${pageContext.request.contextPath}/images/home/poster-5.png" alt="往届热门海报 5">
                    <div><strong>蓝色行动</strong><span>入围作品</span></div>
                </article>
                <article class="poster-card reveal">
                    <img src="${pageContext.request.contextPath}/images/home/poster-6.png" alt="往届热门海报 6">
                    <div><strong>创意字体实验</strong><span>特别展示</span></div>
                </article>
            </div>
        </section>

        <section class="content-section quick-section">
            <a class="quick-card reveal" href="${pageContext.request.contextPath}/competition?action=list">
                <span><%= compCount %></span>
                <strong><%= isAdmin ? "竞赛管理" : "竞赛大厅" %></strong>
                <small><%= isAdmin ? "管理赛题与报名状态" : "查看赛题与报名状态" %></small>
            </a>
            <% if (isAdmin) { %>
                <a class="quick-card reveal" href="${pageContext.request.contextPath}/admin/users">
                    <span><%= teamCount %></span>
                    <strong>用户与队伍</strong>
                    <small>进入后台管理参赛数据</small>
                </a>
                <a class="quick-card reveal" href="${pageContext.request.contextPath}/award?action=manage">
                    <span><%= workCount %></span>
                    <strong>获奖管理</strong>
                    <small>设置奖项并生成证书</small>
                </a>
            <% } else if (isJudge) { %>
                <a class="quick-card reveal" href="${pageContext.request.contextPath}/score?action=list">
                    <span><%= workCount %></span>
                    <strong>评分工作台</strong>
                    <small>查看待评作品并评分</small>
                </a>
                <a class="quick-card reveal" href="${pageContext.request.contextPath}/score?action=myScores">
                    <span><%= activeCount %></span>
                    <strong>我的评分</strong>
                    <small>查看已提交评分记录</small>
                </a>
            <% } else { %>
                <a class="quick-card reveal" href="<%= teamHref %>">
                    <span><%= teamCount %></span>
                    <strong>参赛队伍</strong>
                    <small><%= isParticipant ? "创建或管理你的队伍" : "登录后创建或加入队伍" %></small>
                </a>
                <a class="quick-card reveal" href="<%= workHref %>">
                    <span><%= workCount %></span>
                    <strong>作品提交</strong>
                    <small><%= isParticipant ? "进入作品管理入口" : "登录后提交参赛作品" %></small>
                </a>
            <% } %>
            <a class="quick-card reveal" href="<%= scoreHref %>">
                <span><%= activeCount %></span>
                <strong>评审与获奖</strong>
                <small>查看评分、名单和奖状</small>
            </a>
        </section>
    </main>

    <footer class="home-footer">
        <div class="footer-inner">
            <p class="footer-note">我们会根据你访问的竞赛、报名状态与账号角色，展示更适合你的赛事入口、队伍入口与作品管理入口。</p>
            <div class="footer-path">
                <span class="footer-mark"><i class="fa-solid fa-palette"></i></span>
                <i class="fa-solid fa-chevron-right"></i>
                <span>大学生海报设计竞赛系统</span>
            </div>

            <div class="footer-columns">
                <section>
                    <h3><%= isAdmin ? "后台入口" : (isJudge ? "评审入口" : "选赛与参赛") %></h3>
                    <a href="${pageContext.request.contextPath}/index">首页</a>
                    <a href="${pageContext.request.contextPath}/competition?action=list"><%= isAdmin ? "竞赛管理" : "竞赛大厅" %></a>
                    <% if (isAdmin) { %>
                        <a href="${pageContext.request.contextPath}/admin/users">用户管理</a>
                        <a href="${pageContext.request.contextPath}/certificate?action=list">证书管理</a>
                    <% } else if (isJudge) { %>
                        <a href="${pageContext.request.contextPath}/score?action=list">评分工作台</a>
                        <a href="${pageContext.request.contextPath}/score?action=myScores">我的评分</a>
                    <% } else { %>
                        <a href="<%= teamHref %>">我的队伍</a>
                        <a href="<%= workHref %>">作品提交</a>
                    <% } %>
                    <a href="${pageContext.request.contextPath}/award?action=list">往届获奖</a>
                </section>
                <section>
                    <h3>账号</h3>
                    <% if (sessionUser != null) { %>
                        <a href="${pageContext.request.contextPath}/profile">个人中心</a>
                        <% if (isParticipant) { %>
                            <a href="${pageContext.request.contextPath}/certificate?action=myCertificates">我的奖状</a>
                        <% } %>
                        <a href="${pageContext.request.contextPath}/logout">退出登录</a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login">登录</a>
                        <a href="${pageContext.request.contextPath}/register">注册参赛</a>
                    <% } %>
                </section>
                <section>
                    <% if (isAdmin) { %>
                        <h3>后台管理</h3>
                        <a href="${pageContext.request.contextPath}/admin/users">用户管理</a>
                        <a href="${pageContext.request.contextPath}/competition?action=add">发布竞赛</a>
                        <a href="${pageContext.request.contextPath}/award?action=manage">获奖管理</a>
                        <a href="${pageContext.request.contextPath}/news?action=manage">新闻管理</a>
                    <% } else if (isJudge) { %>
                        <h3>评审工作</h3>
                        <a href="${pageContext.request.contextPath}/score?action=list">评分工作台</a>
                        <a href="${pageContext.request.contextPath}/score?action=myScores">我的评分</a>
                        <a href="${pageContext.request.contextPath}/award?action=list">往届获奖</a>
                    <% } else if (isParticipant) { %>
                        <h3>我的参赛</h3>
                        <a href="${pageContext.request.contextPath}/team?action=myTeams">我的队伍</a>
                        <a href="${pageContext.request.contextPath}/invitation">邀请通知</a>
                        <a href="${pageContext.request.contextPath}/work?action=myWorks">我的作品</a>
                        <a href="${pageContext.request.contextPath}/certificate?action=myCertificates">我的奖状</a>
                    <% } else { %>
                        <h3>参赛入口</h3>
                        <a href="${pageContext.request.contextPath}/login">登录账号</a>
                        <a href="${pageContext.request.contextPath}/register">注册参赛</a>
                        <a href="${pageContext.request.contextPath}/competition?action=list">查看竞赛</a>
                    <% } %>
                </section>
                <section>
                    <h3>公告与结果</h3>
                    <a href="${pageContext.request.contextPath}/news?action=list">公告中心</a>
                    <a href="${pageContext.request.contextPath}/award?action=list">获奖公示</a>
                    <a href="<%= certificateHref %>"><%= (isAdmin || isParticipant) ? "电子奖状" : "获奖公示" %></a>
                    <a href="${pageContext.request.contextPath}/competition?action=list">截止提醒</a>
                </section>
                <section>
                    <h3>关于平台</h3>
                    <a href="${pageContext.request.contextPath}/news?action=list">使用通知</a>
                    <a href="${pageContext.request.contextPath}/competition?action=list">报名说明</a>
                    <a href="${pageContext.request.contextPath}/award?action=list">评审结果</a>
                    <a href="${pageContext.request.contextPath}/profile">联系管理员</a>
                </section>
            </div>

            <p class="footer-help">更多参赛方式：<a href="${pageContext.request.contextPath}/competition?action=list">浏览全部竞赛</a>，或查看公告获取最新赛程安排。</p>
            <div class="footer-bottom">
                <span>Copyright © 2026 大学生海报设计竞赛系统。保留所有权利。</span>
                <div>
                    <a href="${pageContext.request.contextPath}/news?action=list">公告</a>
                    <a href="${pageContext.request.contextPath}/award?action=list">获奖</a>
                    <a href="${pageContext.request.contextPath}/competition?action=list">网站地图</a>
                </div>
                <span>校园竞赛平台</span>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/home.js?v=<%= assetVersion %>"></script>
</body>
</html>
