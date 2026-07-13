<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.util.FileUploadUtil" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
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
    Work work = (Work) request.getAttribute("work");
    Team team = (Team) request.getAttribute("team");
    Competition comp = (Competition) request.getAttribute("competition");
    Integer likeCount = (Integer) request.getAttribute("likeCount");
    Boolean liked = (Boolean) request.getAttribute("liked");
    Boolean isLeader = (Boolean) request.getAttribute("isLeader");
    Boolean readOnlyView = (Boolean) request.getAttribute("readOnlyView");
    if (work == null) { response.sendRedirect(request.getContextPath() + "/work?error=not_found"); return; }
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy\u5e74MM\u6708dd\u65e5 HH:mm");
    String imgUrl = request.getContextPath() + "/image-data?workId=" + work.getWorkId() + "&type=original";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= work.getTitle() != null ? work.getTitle() : "作品详情" %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
                :root { --primary: #6C5CE7; --dark: #2D3436; --gray: #636E72; }
        body { background: #f5f5f5; min-height: 100vh; }
        .navbar { background: var(--dark) !important; }
        .detail-card { background: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); overflow: hidden; }
        .detail-image { width: 100%; max-height: 500px; object-fit: contain; background: #F8F9FA; }
        .detail-body { padding: 2rem; }
        .detail-title { font-weight: 700; font-size: 1.5rem; margin-bottom: 1rem; }
        .detail-meta { font-size: 0.9rem; color: var(--gray); margin-bottom: 1.5rem; }
        .detail-meta i { width: 18px; color: var(--primary); margin-right: 6px; }
        .action-bar { padding: 1rem 2rem; background: #FAFBFC; border-top: 1px solid #eee; display: flex; gap: 0.75rem; flex-wrap: wrap; align-items: center; }
        .btn-action { padding: 0.5rem 1.2rem; border-radius: 10px; border: none; font-weight: 600; font-size: 0.9rem; text-decoration: none; display: inline-block; cursor: pointer; }
        .btn-like { background: #FFF0F0; color: #FF6B6B; }
        .btn-like.liked { background: #FF6B6B; color: white; }
        .btn-primary-custom { background: var(--primary); color: white; }
        .btn-primary-custom:hover { background: #5A4BD1; color: white; }
        .btn-danger-custom { background: #FF6B6B; color: white; }
        .btn-back { background: #F1F2F6; color: var(--gray); }
        .btn-outline { background: transparent; color: var(--primary); border: 2px solid var(--primary); }
        .btn-outline:hover { background: var(--primary); color: white; }
        /* 大图预览Modal */
        .modal-fullscreen-img { max-height: 85vh; object-fit: contain; width: 100%; }
        .img-wrapper { position: relative; display: inline-block; width: 100%; }
        .img-overlay-icons { position: absolute; top: 12px; right: 12px; display: flex; gap: 8px; opacity: 0; transition: opacity 0.3s; }
        .img-wrapper:hover .img-overlay-icons { opacity: 1; }
        .img-overlay-icons a { width: 40px; height: 40px; border-radius: 50%; background: rgba(0,0,0,0.5); color: white; display: flex; align-items: center; justify-content: center; text-decoration: none; font-size: 1.1rem; }
        .img-overlay-icons a:hover { background: var(--primary); }
    </style>
</head>
<body>
<%
    request.setAttribute("activeNav", "works");
%>
<%@ include file="includes/navbar.jspf" %>
<div class="container py-4">
    <div class="mb-3">
        <a href="${pageContext.request.contextPath}/work" class="btn-action btn-back"><i class="fas fa-arrow-left me-1"></i>返回</a>
    </div>
    <div class="row">
        <div class="col-lg-7">
            <div class="detail-card mb-4">
                <div class="img-wrapper">
                    <img src="<%= imgUrl %>" alt="<%= work.getTitle() %>" class="detail-image" style="cursor:pointer" data-bs-toggle="modal" data-bs-target="#imageModal">
                    <div class="img-overlay-icons">
                        <a href="javascript:void(0)" onclick="showFullImage()" title="查看大图"><i class="fas fa-expand"></i></a>
                        <a href="<%= imgUrl %>" title="下载图片"><i class="fas fa-download"></i></a>
                    </div>
                </div>
            </div>
            </div>  <!-- /col-lg-7 -->
            <div class="col-lg-5">
                <div class="detail-card">
                    <div class="detail-body">
                        <h3 class="detail-title"><%= work.getTitle() != null ? work.getTitle() : "未命名" %></h3>
                        <div class="detail-meta">
                            <div><i class="fas fa-users"></i><strong>队伍：</strong><%= team != null ? team.getTeamName() : "未知" %></div>
                            <% if (comp != null) { %><div><i class="fas fa-flag"></i><strong>竞赛：</strong><%= comp.getName() %></div><% } %>
                            <% if (work.getSubmitTime() != null) { %><div><i class="fas fa-clock"></i><strong>提交：</strong><%= work.getSubmitTime().format(dtf) %></div><% } %>
                            <div><i class="fas fa-heart"></i><strong>点赞：</strong><%= likeCount != null ? likeCount : 0 %></div>
                        </div>
                        <% if (work.getDescription() != null && !work.getDescription().isEmpty()) { %>
                            <hr><h6 style="font-weight:700;">作品描述</h6>
                            <p style="white-space:pre-wrap;"><%= work.getDescription() %></p>
                        <% } %>
                    </div>  <!-- /detail-body -->
                <div class="action-bar">
                    <form action="${pageContext.request.contextPath}/work" method="post" style="margin:0">
                        <input type="hidden" name="action" value="<%= liked != null && liked ? "unlike" : "like" %>">
                        <input type="hidden" name="workId" value="<%= work.getWorkId() %>">
                        <button type="submit" class="btn-action btn-like <%= liked != null && liked ? "liked" : "" %>"><i class="fas fa-thumbs-up"></i> <%= liked != null && liked ? "已赞" : "点赞" %> <span class="like-count"><%= likeCount != null ? likeCount : 0 %></span></button>
                    </form>
                    <a href="<%= imgUrl %>" class="btn-action btn-outline" title="下载原图"><i class="fas fa-download me-1"></i>下载</a>
                    <% if (isLeader != null && isLeader) { %>
                        <a href="${pageContext.request.contextPath}/work?action=edit&id=<%= work.getWorkId() %>" class="btn-action btn-primary-custom"><i class="fas fa-edit me-1"></i>编辑</a>
                        <form action="${pageContext.request.contextPath}/work" method="post" style="margin:0" onsubmit="return confirm('确定删除？')">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= work.getWorkId() %>">
                            <button type="submit" class="btn-action btn-danger-custom border-0"><i class="fas fa-trash me-1"></i>删除</button>
                        </form>
                    <% } else if (readOnlyView != null && readOnlyView) { %>
                        <span class="text-muted small align-self-center"><i class="fas fa-lock me-1"></i>比赛已结束，作品仅供查看</span>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<!-- 大图预览 Modal -->
<div class="modal fade" id="imageModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content" style="background:rgba(0,0,0,0.85);border:none;border-radius:12px;">
            <div class="modal-header border-0" style="padding:0.75rem 1rem;">
                <span style="color:white;font-weight:600;"><i class="fas fa-image me-2"></i>作品大图</span>
                <div class="d-flex gap-2">
                    <a href="<%= imgUrl %>" class="btn btn-sm btn-light"><i class="fas fa-download me-1"></i>下载</a>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
            </div>
            <div class="modal-body text-center p-2">
                <img src="<%= imgUrl %>" alt="<%= work.getTitle() %>" class="modal-fullscreen-img">
            </div>
        </div>
    </div>
</div>

<script>
function showFullImage() {
    var modal = new bootstrap.Modal(document.getElementById('imageModal'));
    modal.show();
}
</script>
</body>
</html>


