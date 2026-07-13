<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
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
    Map<Integer, Team> teamMap = (Map<Integer, Team>) request.getAttribute("teamMap");
    Map<Integer, Integer> likeCountMap = (Map<Integer, Integer>) request.getAttribute("likeCountMap");
    Map<Integer, Integer> shareCountMap = (Map<Integer, Integer>) request.getAttribute("shareCountMap");
    Map<Integer, Boolean> likedMap = (Map<Integer, Boolean>) request.getAttribute("likedMap");
    Set<Integer> leaderTeamIds = (Set<Integer>) request.getAttribute("leaderTeamIds");
    String keyword = (String) request.getAttribute("keyword");
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
    int workCount = works == null ? 0 : works.size();
    boolean canSubmitWork = Boolean.TRUE.equals(request.getAttribute("canSubmitWork"));
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>作品墙 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-gallery app-page-submission-list">
<%
    request.setAttribute("activeNav", "works");
%>
<%@ include file="includes/navbar.jspf" %>
<main class="container mt-4">
    <header class="app-page-head">
        <div>
            <p class="app-page-kicker">作品目录</p>
            <h1>作品墙</h1>
            <p class="app-page-summary">按队伍和作品浏览提交记录，先看作品，再决定下一步动作。</p>
        </div>
        <div class="app-page-count"><strong><%= workCount %></strong><span>件作品</span></div>
        <div class="d-flex gap-2 align-items-center">
            <form class="search-box d-flex" method="get" action="${pageContext.request.contextPath}/work">
                <input type="hidden" name="action" value="myWorks">
                <div class="input-group">
                    <input type="text" class="form-control" name="keyword" placeholder="搜索作品..." value="<%= HtmlEscaper.escape(keyword) %>">
                    <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i></button>
                </div>
            </form>
            <% if (canSubmitWork) { %>
                <a href="${pageContext.request.contextPath}/work?action=add" class="btn btn-primary"><i class="fas fa-plus me-1"></i>提交作品</a>
            <% } else { %>
                <span class="btn btn-secondary" style="opacity:0.6;cursor:not-allowed;" title="当前没有处于进行中的可提交赛事"><i class="fas fa-lock me-1"></i>暂不可提交</span>
            <% } %>
        </div>
    </header>

    <div class="app-toolbar">
        <form class="row g-2 align-items-end w-100" method="get" action="${pageContext.request.contextPath}/work">
            <div class="col-md-8 toolbar-field toolbar-field-wide">
                <label for="workKeyword">搜索作品</label>
                <input id="workKeyword" type="text" class="form-control" name="keyword" placeholder="队伍名称或作品名称" value="<%= HtmlEscaper.escape(keyword == null ? "" : keyword) %>">
            </div>
            <div class="col-md-4 d-flex gap-2 toolbar-field">
                <button type="submit" class="btn btn-primary"><i class="fas fa-search me-1"></i>搜索</button>
                <a href="${pageContext.request.contextPath}/work?action=myWorks" class="btn btn-light">清除筛选</a>
            </div>
        </form>
    </div>

    <% if (msg != null) { %>
        <div class="alert alert-success mb-4"><%= "submit_success".equals(msg) ? "作品提交成功！" : "delete_success".equals(msg) ? "作品已删除" : "update_success".equals(msg) ? "作品已更新" : HtmlEscaper.escape(msg) %></div>
    <% } %>
    <% if (error != null) { %>
        <div class="alert alert-danger mb-4"><%= "not_found".equals(error) ? "作品不存在" : "permission_denied".equals(error) ? "没有操作权限" : "delete_failed".equals(error) ? "删除失败" : "share_failed".equals(error) ? "分享失败" : HtmlEscaper.escape(error) %></div>
    <% } %>

    <% if (works == null || works.isEmpty()) { %>
        <section class="app-empty">
            <i class="fas fa-images"></i>
            <h2><%= (keyword != null && !keyword.isEmpty()) ? "没有找到匹配的作品" : "还没有提交任何作品" %></h2>
            <p><%= (keyword != null && !keyword.isEmpty()) ? "换一个关键词试试" : "提交第一件作品，让创意进入竞赛现场" %></p>
        </section>
    <% } else { %>
        <section class="app-art-grid" aria-label="作品列表">
            <% for (Work work : works) {
                Team team = teamMap != null ? teamMap.get(work.getTeamId()) : null;
                boolean isLeader = team != null && leaderTeamIds != null && leaderTeamIds.contains(work.getTeamId());
                int likeCount = likeCountMap != null ? likeCountMap.getOrDefault(work.getWorkId(), 0) : 0;
                int shareCount = shareCountMap != null ? shareCountMap.getOrDefault(work.getWorkId(), 0) : 0;
                boolean liked = likedMap != null && likedMap.getOrDefault(work.getWorkId(), false);
                String imgUrl = request.getContextPath() + "/image-data?workId=" + work.getWorkId() + "&type=thumb";
            %>
                <article class="work-card app-art-card">
                    <a class="app-art-media" href="${pageContext.request.contextPath}/work?action=detail&id=<%= work.getWorkId() %>">
                        <img src="<%= imgUrl %>" alt="<%= HtmlEscaper.escape(work.getTitle() != null ? work.getTitle() : "未命名作品") %>">
                        <span class="app-art-index">WORK <%= work.getWorkId() %></span>
                    </a>
                    <div class="work-body app-art-info">
                        <div class="work-title"><a href="${pageContext.request.contextPath}/work?action=detail&id=<%= work.getWorkId() %>"><%= HtmlEscaper.escape(work.getTitle() != null ? work.getTitle() : "未命名作品") %></a></div>
                        <div class="work-meta app-art-meta">
                            <div><i class="fas fa-users me-1"></i><%= HtmlEscaper.escape(team != null ? team.getTeamName() : "未知队伍") %></div>
                            <% if (work.getSubmitTime() != null) { %><div><i class="far fa-clock me-1"></i><%= work.getSubmitTime().format(dtf) %></div><% } %>
                            <div><i class="far fa-heart me-1"></i><%= likeCount %> 赞 <span class="mx-1">·</span> <i class="fas fa-share-alt me-1"></i><%= shareCount %> 分享</div>
                        </div>
                    </div>
                    <div class="work-actions app-art-actions">
                        <form action="${pageContext.request.contextPath}/work" method="post">
                            <input type="hidden" name="action" value="<%= liked ? "unlike" : "like" %>">
                            <input type="hidden" name="workId" value="<%= work.getWorkId() %>">
                            <button type="submit" class="btn btn-sm btn-like <%= liked ? "liked" : "" %>"><i class="fas fa-thumbs-up me-1"></i><%= liked ? "已赞" : "点赞" %></button>
                        </form>
                        <form action="${pageContext.request.contextPath}/work" method="post">
                            <input type="hidden" name="action" value="share">
                            <input type="hidden" name="workId" value="<%= work.getWorkId() %>">
                            <input type="hidden" name="platform" value="link">
                            <button type="submit" class="btn btn-sm"><i class="fas fa-share-alt me-1"></i>分享</button>
                        </form>
                        <% if (isLeader) { %>
                            <a href="${pageContext.request.contextPath}/work?action=edit&id=<%= work.getWorkId() %>" class="btn btn-sm btn-edit"><i class="fas fa-edit me-1"></i>编辑</a>
                            <form action="${pageContext.request.contextPath}/work" method="post" onsubmit="return confirm('确定删除？')">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<%= work.getWorkId() %>">
                                <button type="submit" class="btn btn-sm btn-delete"><i class="fas fa-trash me-1"></i>删除</button>
                            </form>
                        <% } %>
                        <a href="${pageContext.request.contextPath}/work?action=detail&id=<%= work.getWorkId() %>" class="btn btn-sm btn-light ms-auto"><i class="fas fa-arrow-up-right-from-square me-1"></i>查看</a>
                    </div>
                </article>
            <% } %>
        </section>
    <% } %>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
