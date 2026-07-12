<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.util.FileUploadUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    @SuppressWarnings("unchecked")
    List<Role> userRoles = (List<Role>) session.getAttribute("roles");
    boolean isAdmin = false, isJudge = false;
    if (userRoles != null) for (Role role : userRoles) {
        if ("管理员".equals(role.getRoleName())) isAdmin = true;
        if ("评委".equals(role.getRoleName())) isJudge = true;
    }
    @SuppressWarnings("unchecked")
    List<Work> works = (List<Work>) request.getAttribute("works");
    Map<Integer, Team> teamMap = (Map<Integer, Team>) request.getAttribute("teamMap");
    Map<Integer, Integer> likeCountMap = (Map<Integer, Integer>) request.getAttribute("likeCountMap");
    Map<Integer, Boolean> likedMap = (Map<Integer, Boolean>) request.getAttribute("likedMap");
    Set<Integer> leaderTeamIds = (Set<Integer>) request.getAttribute("leaderTeamIds");
    String keyword = (String) request.getAttribute("keyword");
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>已提交的作品</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root { --primary: #6C5CE7; --dark: #2D3436; --gray: #636E72; }
        body { background: #f5f5f5; min-height: 100vh; }
        .navbar { background: var(--dark) !important; }
        .page-header { display: flex; align-items: center; justify-content: space-between; margin: 2rem 0 1.5rem; flex-wrap: wrap; gap: 1rem; }
        .page-header h2 { font-weight: 700; color: var(--dark); margin: 0; }
        .work-card { background: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); overflow: hidden; margin-bottom: 1.5rem; transition: transform 0.2s; }
        .work-card:hover { transform: translateY(-2px); }
        .work-body { padding: 1rem; }
        .work-title { font-weight: 700; margin-bottom: 0.5rem; }
        .work-title a { color: #333; text-decoration: none; }
        .work-title a:hover { color: var(--primary); }
        .work-meta { font-size: 0.85rem; color: var(--gray); }
        .work-actions { padding: 0.75rem 1rem; background: #FAFBFC; border-top: 1px solid #eee; display: flex; gap: 0.5rem; align-items: center; }
        .btn-sm { padding: 0.25rem 0.75rem; font-size: 0.8rem; border-radius: 8px; border: none; cursor: pointer; }
        .btn-like { background: #FFF0F0; color: #FF6B6B; }
        .btn-like.liked { background: #FF6B6B; color: white; }
        .btn-edit { background: #F0EDFF; color: var(--primary); }
        .btn-delete { background: #FFF0F0; color: #FF6B6B; }
        .search-box .input-group { border-radius: 10px; overflow: hidden; border: 2px solid #EAEEF2; }
        .search-box input { border: none; padding: 0.5rem 1rem; }
        .search-box input:focus { box-shadow: none; }
        .search-box button { background: var(--primary); color: white; border: none; padding: 0.5rem 1rem; }
        .btn-add-work { background: var(--primary); color: white; border: none; border-radius: 10px; padding: 0.6rem 1.5rem; font-weight: 600; text-decoration: none; display: inline-block; }
        .btn-add-work:hover { color: white; }
        .empty-state { text-align: center; padding: 4rem 2rem; }
        .empty-state i { font-size: 4rem; color: #DFE6E9; }
    </style>
</head>
<body>
<%
    request.setAttribute("activeNav", "works");
%>
<%@ include file="includes/navbar.jspf" %>
<div class="container">
    <div class="page-header">
        <h2><i class="fas fa-images me-2" style="color:var(--primary)"></i>已提交的作品</h2>
        <div class="d-flex gap-2">
            <form class="search-box" method="get" action="${pageContext.request.contextPath}/work">
                <div class="input-group">
                    <input type="text" class="form-control" name="keyword" placeholder="搜索队伍名称或作品名称..." value="<%= keyword != null ? keyword : "" %>">
                    <button type="submit"><i class="fas fa-search"></i></button>
                </div>
            </form>
            <a href="${pageContext.request.contextPath}/work?action=add" class="btn-add-work"><i class="fas fa-plus me-1"></i>提交作品</a>
        </div>
    </div>
    <% if (msg != null) { %>
        <div class="alert alert-success"><%= "submit_success".equals(msg) ? "作品提交成功！" : "delete_success".equals(msg) ? "作品已删除" : "update_success".equals(msg) ? "作品已更新" : msg %></div>
    <% } %>
    <% if (error != null) { %>
        <div class="alert alert-danger"><%= "not_found".equals(error) ? "作品不存在" : "permission_denied".equals(error) ? "没有操作权限" : "delete_failed".equals(error) ? "删除失败" : error %></div>
    <% } %>
    <% if (works == null || works.isEmpty()) { %>
        <div class="empty-state">
            <i class="fas fa-images"></i>
            <h4><%= (keyword != null && !keyword.isEmpty()) ? "没有找到匹配的作品" : "还没有提交任何作品" %></h4>
            <p class="text-muted"><%= (keyword != null && !keyword.isEmpty()) ? "试试其他关键词搜索" : "点击上方\"提交作品\"按钮开始提交" %></p>
        </div>
    <% } else { %>
        <div class="row">
            <% for (Work work : works) {
                Team team = teamMap != null ? teamMap.get(work.getTeamId()) : null;
                boolean isLeader = team != null && leaderTeamIds != null && leaderTeamIds.contains(work.getTeamId());
                int likeCount = likeCountMap != null ? likeCountMap.getOrDefault(work.getWorkId(), 0) : 0;
                boolean liked = likedMap != null && likedMap.getOrDefault(work.getWorkId(), false);
                String imgUrl = (work.getImagePath() != null && !work.getImagePath().isEmpty()) ? request.getContextPath() + "/uploads" + work.getImagePath() : "";
            %>
            <div class="col-md-6 col-lg-4">
                <div class="work-card">
                    <div style="height:180px;background:#F1F2F6;display:flex;align-items:center;justify-content:center;overflow:hidden;">
                        <% if (!imgUrl.isEmpty()) { %>
                            <img src="<%= imgUrl %>" alt="<%= work.getTitle() %>" style="width:100%;height:100%;object-fit:cover;">
                        <% } else { %>
                            <i class="fas fa-image" style="font-size:3rem;color:#DFE6E9"></i>
                        <% } %>
                    </div>
                    <div class="work-body">
                        <div class="work-title"><a href="${pageContext.request.contextPath}/work?action=detail&id=<%= work.getWorkId() %>"><%= work.getTitle() != null ? work.getTitle() : "未命名作品" %></a></div>
                        <div class="work-meta">
                            <div><i class="fas fa-users"></i> <%= team != null ? team.getTeamName() : "未知" %></div>
                            <% if (work.getSubmitTime() != null) { %><div><i class="fas fa-clock"></i> <%= work.getSubmitTime().format(dtf) %></div><% } %>
                            <div><i class="fas fa-heart"></i> <%= likeCount %> 赞</div>
                        </div>
                    </div>
                    <div class="work-actions">
                        <form action="${pageContext.request.contextPath}/work" method="post" style="margin:0">
                            <input type="hidden" name="action" value="<%= liked ? "unlike" : "like" %>">
                            <input type="hidden" name="workId" value="<%= work.getWorkId() %>">
                            <button type="submit" class="btn-sm btn-like <%= liked ? "liked" : "" %>"><i class="fas fa-thumbs-up"></i> <%= liked ? "已赞" : "点赞" %></button>
                        </form>
                        <% if (isLeader) { %>
                            <a href="${pageContext.request.contextPath}/work?action=edit&id=<%= work.getWorkId() %>" class="btn-sm btn-edit"><i class="fas fa-edit"></i> 编辑</a>
                            <a href="${pageContext.request.contextPath}/work?action=delete&id=<%= work.getWorkId() %>" class="btn-sm" style="background:#FFF0F0;color:#FF6B6B;" onclick="return confirm('确定删除？')"><i class="fas fa-trash"></i> 删除</a>
                        <% } %>
                        <a href="${pageContext.request.contextPath}/work?action=detail&id=<%= work.getWorkId() %>" class="btn-sm" style="background:#F1F2F6;color:var(--gray);margin-left:auto;"><i class="fas fa-eye"></i> 查看</a>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    <% } %>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
