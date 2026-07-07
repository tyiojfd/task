<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Work" %>
<%@ page import="com.poster.model.Team" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.model.CompetitionCategory" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    Team team = (Team) request.getAttribute("team");
    Competition competition = (Competition) request.getAttribute("competition");
    @SuppressWarnings("unchecked")
    List<CompetitionCategory> categories = (List<CompetitionCategory>) request.getAttribute("categories");
    Work existingWork = (Work) request.getAttribute("existingWork");
    String error = (String) request.getAttribute("error");

    boolean isEdit = false;
    Work editWork = (Work) request.getAttribute("work");
    if (editWork != null) {
        isEdit = true;
        existingWork = editWork;
    }

    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy年MM月dd日 HH:mm");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "编辑作品" : "提交作品" %> - 大学生海报设计竞赛系统</title>
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

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin: 2rem 0 1.5rem;
        }
        .page-header h2 { font-weight: 700; color: var(--dark); margin: 0; }
        .page-header h2 i { color: var(--primary); }

        .form-card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 2px 16px rgba(108, 92, 231, 0.06);
            padding: 2rem;
            margin-bottom: 1.5rem;
        }

        .form-card h5 {
            font-weight: 700;
            color: var(--dark);
            padding-bottom: 0.75rem;
            border-bottom: 2px solid #F0EDFF;
            margin-bottom: 1.25rem;
        }

        .form-label { font-weight: 600; color: var(--dark); font-size: 0.9rem; }
        .form-control, .form-select {
            border-radius: 10px;
            border: 2px solid #EAEEF2;
            padding: 0.6rem 1rem;
            transition: border-color 0.2s;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--primary-light);
            box-shadow: 0 0 0 3px rgba(108, 92, 231, 0.1);
        }
        textarea.form-control { min-height: 100px; resize: vertical; }

        .upload-area {
            border: 2px dashed #DFE6E9;
            border-radius: 12px;
            padding: 2rem;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            background: #F8F9FA;
            position: relative;
        }
        .upload-area:hover { border-color: var(--primary-light); background: #F0EDFF; }
        .upload-area.has-image {
            border-color: var(--primary);
            background: #F8F9FA;
            padding: 1rem;
        }
        .upload-area i { font-size: 3rem; color: #B2BEC3; }
        .upload-area p { color: var(--gray); margin: 0; }
        .upload-area input[type="file"] {
            position: absolute; opacity: 0; width: 100%; height: 100%; top: 0; left: 0; cursor: pointer;
        }

        .preview-container {
            position: relative;
            display: inline-block;
            max-width: 100%;
        }
        .preview-container img {
            max-height: 300px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .preview-container .remove-btn {
            position: absolute;
            top: -10px; right: -10px;
            width: 28px; height: 28px;
            border-radius: 50%;
            background: #FF6B6B;
            color: white;
            border: 2px solid white;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 0.8rem;
            transition: all 0.2s;
        }
        .preview-container .remove-btn:hover { transform: scale(1.1); }

        .btn-submit {
            background: linear-gradient(135deg, var(--primary) 0%, #8B7CF6 100%);
            border: none; border-radius: 12px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            color: white;
            transition: all 0.3s;
            box-shadow: 0 4px 14px rgba(108, 92, 231, 0.3);
        }
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(108, 92, 231, 0.45);
            color: white;
        }

        .btn-cancel {
            border-radius: 12px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            border: 2px solid #EAEEF2;
            color: var(--gray);
            transition: all 0.2s;
        }
        .btn-cancel:hover { background: #F8F9FA; border-color: #DFE6E9; }

        .team-info-bar {
            background: linear-gradient(135deg, #F0EDFF 0%, #E8ECF1 100%);
            border-radius: 12px;
            padding: 1rem 1.5rem;
            margin-bottom: 1.5rem;
        }
        .team-info-bar .label { font-size: 0.8rem; color: var(--gray); }
        .team-info-bar .value { font-weight: 600; color: var(--dark); }

        .deadline-warning {
            background: #FFF3CD;
            border: 1px solid #FFEAA7;
            border-radius: 10px;
            padding: 0.75rem 1rem;
            margin-bottom: 1rem;
            color: #856404;
            font-size: 0.9rem;
        }
        .deadline-warning i { margin-right: 6px; }
    </style>
</head>
<body>
    <!-- 导航栏 -->
    <% request.setAttribute("activePage", "myWorks"); %>
    <%@ include file="navbar.jsp" %>

    <div class="container">
        <div class="page-header">
            <h2><i class="fas fa-<%= isEdit ? "edit" : "plus-circle" %> me-2"></i><%= isEdit ? "编辑作品" : "提交作品" %></h2>
            <a href="${pageContext.request.contextPath}/work?action=myWorks" class="btn btn-cancel">
                <i class="fas fa-arrow-left me-1"></i>返回作品列表
            </a>
        </div>

        <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i><%= error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <!-- 队伍和竞赛信息 -->
        <div class="team-info-bar">
            <div class="row align-items-center">
                <div class="col-md-3">
                    <div class="label">队伍名称</div>
                    <div class="value"><%= team != null ? team.getTeamName() : "" %></div>
                </div>
                <div class="col-md-3">
                    <div class="label">参赛竞赛</div>
                    <div class="value"><%= competition != null ? competition.getName() : "" %></div>
                </div>
                <div class="col-md-3">
                    <div class="label">竞赛主题</div>
                    <div class="value"><%= competition != null ? competition.getTheme() : "" %></div>
                </div>
                <div class="col-md-3">
                    <div class="label">提交截止</div>
                    <div class="value"><%= competition != null && competition.getSubmitDeadline() != null ? competition.getSubmitDeadline().format(dtf) : "" %></div>
                </div>
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/work" method="post" enctype="multipart/form-data" id="submitForm">
            <input type="hidden" name="action" value="<%= isEdit ? "update" : "submit" %>">
            <input type="hidden" name="teamId" value="<%= team != null ? team.getTeamId() : "" %>">
            <input type="hidden" name="competitionId" value="<%= team != null ? team.getCompetitionId() : "" %>">
            <% if (isEdit) { %>
                <input type="hidden" name="workId" value="<%= editWork.getWorkId() %>">
                <input type="hidden" name="existingImagePath" value="<%= editWork.getImagePath() != null ? editWork.getImagePath() : "" %>">
            <% } %>

            <div class="row">
                <!-- 左侧：图片上传 -->
                <div class="col-lg-6">
                    <div class="form-card">
                        <h5><i class="fas fa-upload me-2" style="color:var(--primary)"></i>上传海报图片</h5>

                        <div class="mb-3">
                            <label class="form-label">海报图片 <span class="text-danger">*</span></label>
                            <label class="form-label text-muted" style="font-weight:400;font-size:0.8rem;">支持 JPG/PNG，最大 10MB</label>

                            <div class="upload-area" id="uploadArea">
                                <input type="file" name="imageFile" id="imageFile" accept="image/jpeg,image/png"
                                    <%= isEdit ? "" : "required" %>>
                                <div id="uploadPlaceholder" class="<%= isEdit && editWork.getImagePath() != null ? "d-none" : "" %>">
                                    <i class="fas fa-cloud-upload-alt mb-2"></i>
                                    <p><strong>点击选择图片</strong></p>
                                    <p class="small">或将图片拖拽到此区域</p>
                                </div>
                                <div id="previewContainer" class="preview-container <%= isEdit && editWork.getImagePath() != null ? "" : "d-none" %>">
                                    <img id="previewImage" src="<%= isEdit && editWork.getImagePath() != null ? request.getContextPath() + editWork.getImagePath() : "" %>" alt="海报预览">
                                    <span class="remove-btn" id="removeImage" title="移除图片"><i class="fas fa-times"></i></span>
                                </div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">作品分类</label>
                            <select name="categoryId" class="form-select">
                                <option value="">请选择分类（可选）</option>
                                <% if (categories != null) {
                                    for (CompetitionCategory cat : categories) {
                                        boolean selected = isEdit && editWork.getCategoryId() != null && editWork.getCategoryId().equals(cat.getCategoryId());
                                %>
                                    <option value="<%= cat.getCategoryId() %>" <%= selected ? "selected" : "" %>><%= cat.getCategoryName() %></option>
                                <%  }
                                } %>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- 右侧：作品信息 -->
                <div class="col-lg-6">
                    <div class="form-card">
                        <h5><i class="fas fa-info-circle me-2" style="color:var(--primary)"></i>作品信息</h5>

                        <div class="mb-3">
                            <label class="form-label">作品标题 <span class="text-danger">*</span></label>
                            <input type="text" name="title" class="form-control" placeholder="请输入作品标题"
                                value="<%= isEdit ? editWork.getTitle() : "" %>" required maxlength="100">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">作品描述</label>
                            <textarea name="description" class="form-control" placeholder="请描述你的作品创意、设计理念等（可选）" maxlength="500"><%= isEdit ? (editWork.getDescription() != null ? editWork.getDescription() : "") : "" %></textarea>
                            <div class="text-muted small mt-1"><span id="descCount">0</span>/500</div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">提交状态</label>
                            <div>
                                <span class="badge bg-success" style="font-size:0.85rem;">
                                    <i class="fas fa-check-circle me-1"></i><%= isEdit ? "等待更新" : "立即提交" %>
                                </span>
                            </div>
                        </div>

                        <% if (competition != null && competition.getSubmitDeadline() != null) { %>
                            <div class="deadline-warning">
                                <i class="fas fa-clock"></i>
                                提交截止日期：<strong><%= competition.getSubmitDeadline().format(dtf) %></strong>
                            </div>
                        <% } %>
                    </div>

                    <div class="d-flex gap-2 justify-content-end">
                        <a href="${pageContext.request.contextPath}/work?action=myWorks" class="btn btn-cancel">
                            <i class="fas fa-times me-1"></i>取消
                        </a>
                        <button type="submit" class="btn btn-submit" id="submitBtn">
                            <i class="fas fa-paper-plane me-1"></i><%= isEdit ? "保存修改" : "提交作品" %>
                        </button>
                    </div>
                </div>
            </div>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 图片预览
        const imageFile = document.getElementById('imageFile');
        const previewImage = document.getElementById('previewImage');
        const previewContainer = document.getElementById('previewContainer');
        const uploadPlaceholder = document.getElementById('uploadPlaceholder');
        const removeBtn = document.getElementById('removeImage');
        const uploadArea = document.getElementById('uploadArea');
        const descTextarea = document.querySelector('textarea[name="description"]');
        const descCount = document.getElementById('descCount');

        imageFile.addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                // 校验文件类型
                const validTypes = ['image/jpeg', 'image/png'];
                if (!validTypes.includes(file.type)) {
                    alert('仅支持 JPG/PNG 格式的图片');
                    this.value = '';
                    return;
                }
                // 校验文件大小
                if (file.size > 10 * 1024 * 1024) {
                    alert('图片大小不能超过 10MB');
                    this.value = '';
                    return;
                }

                const reader = new FileReader();
                reader.onload = function(e) {
                    previewImage.src = e.target.result;
                    previewContainer.classList.remove('d-none');
                    uploadPlaceholder.classList.add('d-none');
                    uploadArea.classList.add('has-image');
                };
                reader.readAsDataURL(file);
            }
        });

        removeBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            imageFile.value = '';
            previewImage.src = '';
            previewContainer.classList.add('d-none');
            uploadPlaceholder.classList.remove('d-none');
            uploadArea.classList.remove('has-image');
        });

        // 描述字数统计
        descTextarea.addEventListener('input', function() {
            descCount.textContent = this.value.length;
            if (this.value.length > 500) {
                this.value = this.value.substring(0, 500);
                descCount.textContent = 500;
            }
        });

        // 初始字数统计
        if (descTextarea.value) {
            descCount.textContent = descTextarea.value.length;
        }

        // 表单提交确认
        document.getElementById('submitForm').addEventListener('submit', function(e) {
            const title = document.querySelector('input[name="title"]').value.trim();
            if (!title) {
                alert('请输入作品标题');
                e.preventDefault();
                return;
            }
            // 如果是新建，检查是否有图片
            const action = document.querySelector('input[name="action"]').value;
            if (action === 'submit') {
                const file = imageFile.files[0];
                const existingPath = document.querySelector('input[name="existingImagePath"]');
                if (!file && (!existingPath || !existingPath.value)) {
                    alert('请上传海报图片');
                    e.preventDefault();
                    return;
                }
            }
        });
    </script>
</body>
</html>
