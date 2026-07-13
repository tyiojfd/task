<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="com.poster.model.CompetitionCategory" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="com.poster.util.HtmlEscaper" %>
<%
    Competition competition = (Competition) request.getAttribute("competition");
    @SuppressWarnings("unchecked")
    List<CompetitionCategory> categories = (List<CompetitionCategory>) request.getAttribute("categories");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>编辑竞赛 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>
<body>
    <%
    request.setAttribute("activeNav", "competitions");
%>
<%@ include file="includes/navbar.jspf" %>

    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0">编辑竞赛</h4>
                    </div>
                    <div class="card-body">
                        <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger"><%= HtmlEscaper.escape(String.valueOf(request.getAttribute("error"))) %></div>
                        <% } %>

                        <% if (competition != null) { %>
                            <form action="${pageContext.request.contextPath}/competition?action=update" method="post">
                                <input type="hidden" name="competitionId" value="<%= competition.getCompetitionId() %>">

                                <div class="mb-3">
                                    <label class="form-label">年度 *</label>
                                    <input type="number" class="form-control" name="year" min="2020" max="2030"
                                           value="<%= competition.getYear() %>" required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">竞赛名称 *</label>
                                    <input type="text" class="form-control" name="name"
                                           value="<%= HtmlEscaper.escape(competition.getName()) %>" required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">竞赛主题</label>
                                    <input type="text" class="form-control" name="theme"
                                           value="<%= HtmlEscaper.escape(competition.getTheme() != null ? competition.getTheme() : "") %>">
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">竞赛描述</label>
                                    <textarea class="form-control" name="description" rows="4"><%= HtmlEscaper.escape(competition.getDescription() != null ? competition.getDescription() : "") %></textarea>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">提交截止时间 *</label>
                                    <input type="datetime-local" class="form-control" name="submitDeadline"
                                           value="<%= competition.getSubmitDeadline() != null ? competition.getSubmitDeadline().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")) : "" %>" required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">最大队伍人数 *</label>
                                    <input type="number" class="form-control" name="maxTeamSize" min="1" max="10"
                                           value="<%= competition.getMaxTeamSize() %>" required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">竞赛状态 *</label>
                                    <select class="form-select" name="status" required>
                                        <option value="1" <%= competition.getStatus() == 1 ? "selected" : "" %>>报名中</option>
                                        <option value="2" <%= competition.getStatus() == 2 ? "selected" : "" %>>进行中</option>
                                        <option value="3" <%= competition.getStatus() == 3 ? "selected" : "" %>>已结束</option>
                                        <option value="0" <%= competition.getStatus() != null && competition.getStatus() == 0 ? "selected" : "" %>>已取消</option>
                                    </select>
                                </div>

                                <!-- 已有子类管理 -->
                                <div class="mb-3">
                                    <label class="form-label">已有子类</label>
                                    <div id="existingCategories">
                                        <% if (categories != null && !categories.isEmpty()) {
                                            for (CompetitionCategory cat : categories) { %>
                                                <div class="d-flex align-items-center mb-2 p-2 border rounded existing-cat-row">
                                                    <input type="hidden" name="deleteCategoryIds" value="" disabled>
                                                    <span class="me-2 flex-grow-1">
                                                        <strong><%= HtmlEscaper.escape(cat.getCategoryName()) %></strong>
                                                        <% if (cat.getCategoryDesc() != null && !cat.getCategoryDesc().isEmpty()) { %>
                                                            <small class="text-muted"> — <%= HtmlEscaper.escape(cat.getCategoryDesc()) %></small>
                                                        <% } %>
                                                    </span>
                                                    <button type="button" class="btn btn-outline-danger btn-sm delete-existing"
                                                            data-cat-id="<%= cat.getCategoryId() %>">
                                                        <i class="fas fa-trash"></i> 删除
                                                    </button>
                                                </div>
                                        <%  }
                                        } else { %>
                                            <p class="text-muted" id="noCategoryHint">暂无子类，请在下方添加</p>
                                        <% } %>
                                    </div>
                                </div>

                                <!-- 新增子类 -->
                                <div class="mb-3">
                                    <label class="form-label">新增子类</label>
                                    <div id="newCategoriesContainer">
                                        <div class="row g-2 mb-2 new-category-row">
                                            <div class="col-md-5">
                                                <input type="text" class="form-control" name="categoryName"
                                                       placeholder="子类名称，如：海报设计类">
                                            </div>
                                            <div class="col-md-5">
                                                <input type="text" class="form-control" name="categoryDesc"
                                                       placeholder="子类描述（可选）">
                                            </div>
                                            <div class="col-md-2">
                                                <button type="button" class="btn btn-outline-danger btn-sm w-100 remove-new-category" disabled>
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <button type="button" class="btn btn-outline-primary btn-sm mt-2" id="addNewCategoryBtn">
                                        <i class="fas fa-plus"></i> 添加子类
                                    </button>
                                </div>

                                <div class="d-flex justify-content-between">
                                    <a href="${pageContext.request.contextPath}/competition?action=detail&id=<%= competition.getCompetitionId() %>" class="btn btn-secondary">取消</a>
                                    <button type="submit" class="btn btn-primary">保存修改</button>
                                </div>
                            </form>
                        <% } else { %>
                            <div class="alert alert-danger">竞赛不存在</div>
                            <a href="${pageContext.request.contextPath}/competition?action=list" class="btn btn-primary">返回列表</a>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 标记已删除的子类ID（通过隐藏input提交）
        var deletedIds = [];

        // 删除已有子类
        document.getElementById('existingCategories').addEventListener('click', function(e) {
            var btn = e.target.closest('.delete-existing');
            if (!btn) return;

            if (!confirm('确定要删除该子类吗？')) return;

            var catId = btn.getAttribute('data-cat-id');
            deletedIds.push(catId);

            // 在表单中添加隐藏字段
            var hidden = document.createElement('input');
            hidden.type = 'hidden';
            hidden.name = 'deleteCategoryIds';
            hidden.value = catId;
            document.querySelector('form').appendChild(hidden);

            // 移除显示行
            var row = btn.closest('.existing-cat-row');
            row.remove();

            // 如果全部删完，显示提示
            if (document.querySelectorAll('.existing-cat-row').length === 0) {
                var hint = document.getElementById('noCategoryHint');
                if (!hint) {
                    hint = document.createElement('p');
                    hint.id = 'noCategoryHint';
                    hint.className = 'text-muted';
                    hint.textContent = '已全部删除，请在下方添加新子类';
                    document.getElementById('existingCategories').appendChild(hint);
                }
            }
        });

        // 新增子类行
        document.getElementById('addNewCategoryBtn').addEventListener('click', function() {
            var container = document.getElementById('newCategoriesContainer');
            var row = document.createElement('div');
            row.className = 'row g-2 mb-2 new-category-row';
            row.innerHTML = `
                <div class="col-md-5">
                    <input type="text" class="form-control" name="categoryName" placeholder="子类名称">
                </div>
                <div class="col-md-5">
                    <input type="text" class="form-control" name="categoryDesc" placeholder="子类描述（可选）">
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-outline-danger btn-sm w-100 remove-new-category">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            `;
            container.appendChild(row);
            updateNewRemoveButtons();
        });

        // 删除新增子类行
        document.getElementById('newCategoriesContainer').addEventListener('click', function(e) {
            if (e.target.closest('.remove-new-category')) {
                var rows = document.querySelectorAll('.new-category-row');
                if (rows.length > 1) {
                    e.target.closest('.new-category-row').remove();
                    updateNewRemoveButtons();
                }
            }
        });

        function updateNewRemoveButtons() {
            var rows = document.querySelectorAll('.new-category-row');
            rows.forEach(function(row) {
                var btn = row.querySelector('.remove-new-category');
                btn.disabled = rows.length <= 1;
            });
        }
    </script>
</body>
</html>
