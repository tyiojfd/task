<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.util.FileUploadUtil" %>
<%@ page import="java.util.List" %>
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
    List<Team> teams = (List<Team>) request.getAttribute("teams");
    @SuppressWarnings("unchecked")
    java.util.Set<Integer> submittedTeamIds = (java.util.Set<Integer>) request.getAttribute("submittedTeamIds");
    Work editWork = (Work) request.getAttribute("work");
    boolean isEdit = (editWork != null);
    String error = request.getParameter("error");
    String msg = request.getParameter("msg");
    String placeholderClass = (isEdit && editWork.getImagePath() != null) ? "d-none" : "";
    String previewClass = (isEdit && editWork.getImagePath() != null) ? "" : "d-none";
    String previewImgSrc = (isEdit && editWork.getImagePath() != null) ? request.getContextPath() + "/uploads" + editWork.getImagePath() : "";
    String error = request.getParameter("error");
    String msg = request.getParameter("msg");
    String placeholderClass = (isEdit && editWork.getImagePath() != null) ? "d-none" : "";
    String previewClass = (isEdit && editWork.getImagePath() != null) ? "" : "d-none";
    String previewImgSrc = (isEdit && editWork.getImagePath() != null) ? request.getContextPath() + "/" + com.poster.util.FileUploadUtil.STORAGE_DIR + editWork.getImagePath() : "";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "编辑作品" : "提交作品" %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root { --primary: #6C5CE7; --primary-light: #A29BFE; --dark: #2D3436; --gray: #636E72; }
        body { background: linear-gradient(135deg, #F8F9FA 0%, #E8ECF1 100%); min-height: 100vh; }
        .navbar { background: var(--dark) !important; }
        .navbar-brand { font-weight: 700; }
        .page-header { display: flex; align-items: center; justify-content: space-between; margin: 2rem 0 1.5rem; }
        .page-header h2 { font-weight: 700; color: var(--dark); }
        .form-card { background: white; border-radius: 16px; box-shadow: 0 2px 16px rgba(108,92,231,0.06); padding: 2rem; margin-bottom: 1.5rem; }
        .form-card h5 { font-weight: 700; border-bottom: 2px solid #F0EDFF; padding-bottom: 0.75rem; margin-bottom: 1.25rem; }
        .form-label { font-weight: 600; font-size: 0.9rem; }
        .form-control { border-radius: 10px; border: 2px solid #EAEEF2; padding: 0.6rem 1rem; }
        .form-control:focus { border-color: var(--primary-light); box-shadow: 0 0 0 3px rgba(108,92,231,0.1); }
        .upload-area { border: 2px dashed #DFE6E9; border-radius: 12px; padding: 2rem; text-align: center; cursor: pointer; background: #F8F9FA; position: relative; }
        .upload-area:hover { border-color: var(--primary-light); background: #F0EDFF; }
        .upload-area input[type="file"] { position: absolute; opacity: 0; width: 100%; height: 100%; top: 0; left: 0; cursor: pointer; }
        .preview-container { position: relative; display: inline-block; max-width: 100%; }
        .preview-container img { max-height: 300px; border-radius: 8px; }
        .remove-image { position: absolute; top: -10px; right: -10px; background: #FF6B6B; color: white; border: none; border-radius: 50%; width: 28px; height: 28px; }
        .btn-submit { background: var(--primary); color: white; border: none; border-radius: 10px; padding: 0.6rem 1.5rem; font-weight: 600; }
        .btn-submit:hover { background: #5A4BD1; }
        .btn-cancel { background: #F1F2F6; color: var(--gray); border: none; border-radius: 10px; padding: 0.6rem 1.5rem; }
        .team-card { border: 2px solid #EAEEF2; border-radius: 12px; padding: 1rem; cursor: pointer; margin-bottom: 0.75rem; }
        .team-card:hover { border-color: var(--primary-light); background: #F8F6FF; }
        .team-card.selected { border-color: var(--primary); background: #F0EDFF; }
    </style>
</head>
<body>
<%
    request.setAttribute("activeNav", "works");
%>
<%@ include file="includes/navbar.jspf" %>
<div class="container">
    <div class="page-header">
        <h2><i class="fas fa-plus-circle me-2" style="color:var(--primary)"></i>提交作品</h2>
        <a href="${pageContext.request.contextPath}/work" class="btn btn-cancel"><i class="fas fa-arrow-left me-1"></i>返回列表</a>
    </div>
    <% if (msg != null) { %>
        <div class="alert alert-success mt-3"><%= "submit_success".equals(msg) ? "作品提交成功！" : "update_success".equals(msg) ? "作品已更新" : msg %></div>
    <% } %>
    <% if (error != null) { %>
        <div class="alert alert-danger mt-3"><%= "already_submitted".equals(error) ? "该队伍已提交过作品，每个队伍只能提交一次" : "permission_denied".equals(error) ? "没有操作权限" : "deadline_passed".equals(error) ? "提交已截止" : "no_team".equals(error) ? "请选择队伍" : "no_title".equals(error) ? "请输入作品名称" : "no_image".equals(error) ? "请上传图片" : "upload_failed".equals(error) ? "上传失败" : "submit_failed".equals(error) ? "提交失败，请重试" : error %></div>
    <% } %>
    <form action="${pageContext.request.contextPath}/work" method="post" enctype="multipart/form-data" id="submitForm">
        <input type="hidden" name="action" value="<%= isEdit ? "update" : "submit" %>">
        <% if (isEdit) { %>
        <input type="hidden" name="workId" value="<%= editWork.getWorkId() %>">
        <% } %>
        <div class="row">
            <div class="col-lg-8">
                <div class="form-card">
                    <h5><i class="fas fa-users me-2" style="color:var(--primary)"></i>选择队伍</h5>
                    <% if (teams == null || teams.isEmpty()) { %>
                        <div class="text-center py-4">
                            <i class="fas fa-info-circle" style="font-size:2rem;color:#B2BEC3"></i>
                            <p class="text-muted mt-2">你还没有创建队伍，请先创建队伍。</p>
                            <a href="${pageContext.request.contextPath}/team?action=create" class="btn btn-primary btn-sm"><i class="fas fa-plus me-1"></i>创建队伍</a>
                        </div>
                    <% } else { %>
                        <% for (Team t : teams) { %>
                        <%
                            boolean teamSubmitted = submittedTeamIds != null && submittedTeamIds.contains(t.getTeamId());
                        %>
                        <label class="team-card" style="<%= teamSubmitted ? "opacity:0.6;cursor:not-allowed;" : "" %>">
                            <input type="radio" name="teamId" value="<%= t.getTeamId() %>" style="display:none" <%= teamSubmitted ? "disabled" : "" %>>
                            <div class="d-flex align-items-center">
                                <div class="me-3"><i class="fas fa-users text-primary" style="font-size:1.5rem"></i></div>
                                <div>
                                    <strong><%= t.getTeamName() %></strong>
                                    <% if (teamSubmitted) { %>
                                        <span class="badge bg-secondary">已提交作品</span>
                                    <% } else if (t.getStatus() != null && t.getStatus() == 2) { %>
                                        <span class="badge bg-success">已报名</span>
                                    <% } else { %>
                                        <span class="badge bg-warning text-dark">未报名</span>
                                    <% } %>
                                </div>
                            </div>
                        </label>
                        <% } %>
                    <% } %>
                </div>
                <div class="form-card">
                    <h5><i class="fas fa-info-circle me-2" style="color:var(--primary)"></i>作品信息</h5>
                    <div class="mb-3">
                        <label class="form-label">作品名称 <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="title" placeholder="请输入作品名称" required maxlength="100" value="<%= isEdit && editWork.getTitle() != null ? editWork.getTitle() : "" %>">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">作品描述</label>
                        <textarea class="form-control" name="description" placeholder="请输入作品描述（选填）" maxlength="500"><%= isEdit && editWork.getDescription() != null ? editWork.getDescription() : "" %></textarea>
                    </div>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="form-card">
                    <h5><i class="fas fa-image me-2" style="color:var(--primary)"></i>海报图片</h5>
                    <div class="upload-area" id="uploadArea" onclick="document.getElementById('imageFile').click()">
                        <input type="file" id="imageFile" name="imageFile" accept="image/jpeg,image/png">
                        <div id="uploadPlaceholder" class="<%= placeholderClass %>">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <p class="mt-2"><%= isEdit ? "点击更换海报图片（可选）" : "点击上传海报图片" %></p>
                            <small class="text-muted">支持 JPG/PNG，最大 10MB</small>
                        </div>
                        <div id="previewContainer" class="preview-container <%= previewClass %>">
                            <img id="previewImage" src="<%= previewImgSrc %>" alt="预览">
                            <button type="button" class="remove-image" id="removeImage">&times;</button>
                        </div>
                </div>
            </div>
        </div>
        <div class="d-flex gap-2 justify-content-end mb-4">
            <a href="${pageContext.request.contextPath}/work" class="btn btn-cancel"><i class="fas fa-times me-1"></i>取消</a>
            <button type="submit" class="btn btn-submit" id="submitBtn"><i class="fas fa-paper-plane me-1"></i><%= isEdit ? "保存修改" : "提交作品" %></button>
        </div>
    </form>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('imageFile').addEventListener('change', function(e) {
        var file = e.target.files[0];
        if (file) {
            if (!['image/jpeg','image/png'].includes(file.type)) { alert('仅支持 JPG/PNG'); this.value = ''; return; }
            if (file.size > 10*1024*1024) { alert('图片不能超过 10MB'); this.value = ''; return; }
            var reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('previewImage').src = e.target.result;
                document.getElementById('previewContainer').classList.remove('d-none');
                document.getElementById('uploadPlaceholder').classList.add('d-none');
            };
            reader.readAsDataURL(file);
        }
    });
    document.getElementById('removeImage').addEventListener('click', function(e) {
        e.stopPropagation();
        document.getElementById('imageFile').value = '';
        document.getElementById('previewContainer').classList.add('d-none');
        document.getElementById('uploadPlaceholder').classList.remove('d-none');
    });
    document.getElementById('submitForm').addEventListener('submit', function(e) {
        var title = document.querySelector('input[name="title"]').value.trim();
        if (!title) { alert('请输入作品名称'); e.preventDefault(); return; }
        var team = document.querySelector('input[name="teamId"]:checked');
        if (!team) { alert('请选择队伍'); e.preventDefault(); return; }
        var isEditMode = <%= isEdit %>;
        if (!isEditMode) {
            var file = document.getElementById('imageFile').files[0];
            if (!file) { alert('请上传图片'); e.preventDefault(); return; }
        }
    });
    document.querySelectorAll('.team-card').forEach(function(c) {
        c.addEventListener('click', function() {
            this.querySelector('input[type="radio"]').checked = true;
            document.querySelectorAll('.team-card').forEach(function(x) { x.classList.remove('selected'); });
            this.classList.add('selected');
        });
    });
</script>
</body>
</html>
