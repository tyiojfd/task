<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>发布竞赛 - 大学生海报设计竞赛系统</title>
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
                        <h4 class="mb-0">发布竞赛</h4>
                    </div>
                    <div class="card-body">
                        <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
                        <% } %>

                        <form action="${pageContext.request.contextPath}/competition?action=create" method="post">
                            <div class="mb-3">
                                <label class="form-label">年度 *</label>
                                <input type="number" class="form-control" name="year" min="2020" max="2030" value="2026" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">竞赛名称 *</label>
                                <input type="text" class="form-control" name="name" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">竞赛主题</label>
                                <input type="text" class="form-control" name="theme">
                            </div>

                            <div class="mb-3">
                                <label class="form-label">竞赛描述</label>
                                <textarea class="form-control" name="description" rows="4"></textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">提交截止时间 *</label>
                                <input type="datetime-local" class="form-control" name="submitDeadline" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">最大队伍人数 *</label>
                                <input type="number" class="form-control" name="maxTeamSize" min="1" max="10" value="5" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">竞赛状态 *</label>
                                <select class="form-select" name="status" required>
                                    <option value="1" selected>报名中</option>
                                    <option value="2">进行中</option>
                                    <option value="3">已结束</option>
                                </select>
                            </div>

                            <!-- 竞赛子类管理 -->
                            <div class="mb-3">
                                <label class="form-label">竞赛子类 <small class="text-muted">（至少添加一个参赛方向）</small></label>
                                <div id="categoriesContainer">
                                    <div class="row g-2 mb-2 category-row">
                                        <div class="col-md-5">
                                            <input type="text" class="form-control" name="categoryName"
                                                   placeholder="子类名称，如：海报设计类" required>
                                        </div>
                                        <div class="col-md-5">
                                            <input type="text" class="form-control" name="categoryDesc"
                                                   placeholder="子类描述（可选）">
                                        </div>
                                        <div class="col-md-2">
                                            <button type="button" class="btn btn-outline-danger btn-sm w-100 remove-category" disabled>
                                                <i class="fas fa-trash"></i> 删除
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                <button type="button" class="btn btn-outline-primary btn-sm mt-2" id="addCategoryBtn">
                                    <i class="fas fa-plus"></i> 添加子类
                                </button>
                            </div>

                            <div class="d-flex justify-content-between">
                                <a href="${pageContext.request.contextPath}/competition?action=list" class="btn btn-secondary">取消</a>
                                <button type="submit" class="btn btn-primary">发布竞赛</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 动态添加子类行
        document.getElementById('addCategoryBtn').addEventListener('click', function() {
            var container = document.getElementById('categoriesContainer');
            var row = document.createElement('div');
            row.className = 'row g-2 mb-2 category-row';
            row.innerHTML = `
                <div class="col-md-5">
                    <input type="text" class="form-control" name="categoryName"
                           placeholder="子类名称，如：插画设计类" required>
                </div>
                <div class="col-md-5">
                    <input type="text" class="form-control" name="categoryDesc"
                           placeholder="子类描述（可选）">
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-outline-danger btn-sm w-100 remove-category">
                        <i class="fas fa-trash"></i> 删除
                    </button>
                </div>
            `;
            container.appendChild(row);
            updateRemoveButtons();
        });

        // 委托删除按钮事件
        document.getElementById('categoriesContainer').addEventListener('click', function(e) {
            if (e.target.closest('.remove-category')) {
                var rows = document.querySelectorAll('.category-row');
                if (rows.length > 1) {
                    e.target.closest('.category-row').remove();
                    updateRemoveButtons();
                }
            }
        });

        // 只剩一行时禁用删除按钮
        function updateRemoveButtons() {
            var rows = document.querySelectorAll('.category-row');
            rows.forEach(function(row) {
                var btn = row.querySelector('.remove-category');
                btn.disabled = rows.length <= 1;
            });
        }

        // 表单提交前清除空子类行
        document.querySelector('form').addEventListener('submit', function(e) {
            var nameInputs = document.querySelectorAll('input[name="categoryName"]');
            var hasValid = false;
            nameInputs.forEach(function(input) {
                if (input.value.trim() !== '') {
                    hasValid = true;
                }
            });
            if (!hasValid) {
                e.preventDefault();
                alert('请至少填写一个竞赛子类名称');
            }
        });
    </script>
</body>
</html>
