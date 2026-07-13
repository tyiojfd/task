<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.util.FileUploadUtil" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
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
    @SuppressWarnings("unchecked")
    java.util.Set<Integer> ineligibleTeamIds = (java.util.Set<Integer>) request.getAttribute("ineligibleTeamIds");
    @SuppressWarnings("unchecked")
    java.util.Map<Integer, String> ineligibleReasonMap = (java.util.Map<Integer, String>) request.getAttribute("ineligibleReasonMap");
    Team editTeam = (Team) request.getAttribute("team");
    Work editWork = (Work) request.getAttribute("work");
    boolean isEdit = (editWork != null);
    String error = request.getParameter("error");
    String msg = request.getParameter("msg");
    String placeholderClass = (isEdit && editWork.getImagePath() != null) ? "d-none" : "";
    String previewClass = (isEdit && editWork.getImagePath() != null) ? "" : "d-none";
    String previewImgSrc = (isEdit && editWork.getWorkId() != null) ? request.getContextPath() + "/image-data?workId=" + editWork.getWorkId() + "&type=original" : "";
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
        .page-header { display: flex; align-items: center; justify-content: space-between; margin: 2rem 0 1.5rem; }
        .page-header h2 { font-weight: 700; color: var(--app-ink); }
        .form-card { background: var(--app-surface); border-radius: 12px; border: 1px solid var(--app-rule); padding: 2rem; margin-bottom: 1.5rem; }
        .form-card h5 { font-weight: 700; border-bottom: 2px solid var(--app-rule); padding-bottom: 0.75rem; margin-bottom: 1.25rem; color: var(--app-ink); }
        .form-label { font-weight: 600; font-size: 0.9rem; }
        .form-control { border-radius: 8px; border: 2px solid var(--app-rule); padding: 0.6rem 1rem; }
        .form-control:focus { border-color: var(--app-blue); box-shadow: 0 0 0 3px rgba(23,105,170,0.1); }
        .upload-area { border: 2px dashed var(--app-rule-strong); border-radius: 12px; padding: 2rem; text-align: center; cursor: pointer; background: var(--app-surface-soft); position: relative; }
        .upload-area:hover { border-color: var(--app-blue); background: var(--app-surface-soft); }
        .upload-area input[type="file"] { position: absolute; opacity: 0; width: 100%; height: 100%; top: 0; left: 0; cursor: pointer; }
        .preview-container { position: relative; display: inline-block; max-width: 100%; }
        .preview-container img { max-height: 300px; border-radius: 8px; }
        .remove-image { position: absolute; top: -10px; right: -10px; background: #c44e63; color: white; border: none; border-radius: 50%; width: 28px; height: 28px; }
        .btn-submit { background: var(--app-blue); color: white; border: none; border-radius: 8px; padding: 0.6rem 1.5rem; font-weight: 600; }
        .btn-submit:hover { background: var(--app-blue-deep); }
        .btn-cancel { background: var(--app-surface-soft); color: var(--app-muted); border: none; border-radius: 8px; padding: 0.6rem 1.5rem; }
        .team-card { border: 2px solid var(--app-rule); border-radius: 10px; padding: 1rem; cursor: pointer; margin-bottom: 0.75rem; background: var(--app-surface); }
        .team-card:hover { border-color: var(--app-blue); background: var(--app-surface-soft); }
        .team-card.selected { border-color: var(--app-blue); background: var(--app-surface-soft); }
    </style>
    <%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-workbench app-page-submission-form">
<%
    request.setAttribute("activeNav", "works");
%>
<%@ include file="includes/navbar.jspf" %>
<div class="container">
    <div class="page-header">
        <h2><i class="fas fa-plus-circle me-2 text-primary"></i>提交作品</h2>
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
        <div class="app-workbench">
            <div class="row">
            <div class="col-lg-8">
                <div class="form-card">
                    <h5><i class="fas fa-users me-2" style="color:var(--app-blue)"></i><%= isEdit ? "所属队伍" : "选择队伍" %></h5>
                    <% if (isEdit) { %>
                        <div class="team-card selected" style="cursor:default;">
                            <div class="d-flex align-items-center">
                                <div class="me-3"><i class="fas fa-users text-primary" style="font-size:1.5rem"></i></div>
                                <div>
                                    <strong><%= HtmlEscaper.escape(editTeam != null ? editTeam.getTeamName() : "原队伍") %></strong>
                                    <span class="badge bg-info">编辑时不可更换队伍</span>
                                </div>
                            </div>
                        </div>
                    <% } else if (teams == null || teams.isEmpty()) { %>
                        <div class="text-center py-4">
                            <i class="fas fa-info-circle" style="font-size:2rem;color:#B2BEC3"></i>
                            <p class="text-muted mt-2">你还没有可提交作品的队伍，请先创建并报名队伍。</p>
                            <a href="${pageContext.request.contextPath}/team?action=create" class="btn btn-primary btn-sm"><i class="fas fa-plus me-1"></i>创建队伍</a>
                        </div>
                    <% } else { %>
                        <% for (Team t : teams) { %>
                        <%
                            boolean teamSubmitted = submittedTeamIds != null && submittedTeamIds.contains(t.getTeamId());
                            boolean ineligible = ineligibleTeamIds != null && ineligibleTeamIds.contains(t.getTeamId());
                            String reason = ineligibleReasonMap != null ? ineligibleReasonMap.get(t.getTeamId()) : null;
                        %>
                        <label class="team-card" style="<%= ineligible ? "opacity:0.6;cursor:not-allowed;" : "" %>">
                            <input type="radio" name="teamId" value="<%= t.getTeamId() %>" style="display:none" <%= ineligible ? "disabled" : "" %>>
                            <div class="d-flex align-items-center">
                                <div class="me-3"><i class="fas fa-users text-primary" style="font-size:1.5rem"></i></div>
                                <div>
                                    <strong><%= HtmlEscaper.escape(t.getTeamName()) %></strong>
                                    <% if (teamSubmitted) { %>
                                        <span class="badge bg-secondary">已提交作品</span>
                                    <% } else if (t.getStatus() != null && t.getStatus() == 2 && !ineligible) { %>
                                        <span class="badge bg-success">可提交</span>
                                    <% } else { %>
                                        <span class="badge bg-warning text-dark"><%= reason != null ? reason : "不可提交" %></span>
                                    <% } %>
                                </div>
                            </div>
                        </label>
                        <% } %>
                    <% } %>
                </div>
                <div class="form-card">
                    <h5><i class="fas fa-info-circle me-2" style="color:var(--app-blue)"></i>作品信息</h5>
                    <div class="mb-3">
                        <label class="form-label">作品名称 <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" name="title" placeholder="请输入作品名称" required maxlength="100" value="<%= HtmlEscaper.escape(isEdit && editWork.getTitle() != null ? editWork.getTitle() : "") %>">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">作品描述</label>
                        <textarea class="form-control" name="description" placeholder="请输入作品描述（选填）" maxlength="500"><%= HtmlEscaper.escape(isEdit && editWork.getDescription() != null ? editWork.getDescription() : "") %></textarea>
                    </div>
                </div>
            </div>
            <div class="col-lg-4">
                <div class="form-card">
                    <h5><i class="fas fa-image me-2" style="color:var(--app-blue)"></i>海报图片</h5>
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
        var isEditMode = <%= isEdit %>;
        if (!isEditMode) {
            var team = document.querySelector('input[name="teamId"]:checked');
            if (!team) { alert('请选择可提交作品的队伍'); e.preventDefault(); return; }
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
