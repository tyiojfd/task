<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.News" %>
<%@ page import="com.poster.model.User" %>
<%
    News news = (News) request.getAttribute("news");
    User sessionUser = (User) session.getAttribute("user");
    String error = (String) request.getAttribute("error");

    if (news == null) {
        response.sendRedirect(request.getContextPath() + "/news?action=manage");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>编辑新闻 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #667eea;
            --secondary: #764ba2;
        }
        body { background: #f5f5f5; }
        .navbar-brand { font-weight: bold; }
        .form-container { max-width: 800px; margin: 0 auto; }
        .page-header {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            border-radius: 15px;
            padding: 30px 40px;
            margin-bottom: 25px;
        }
        .form-card {
            background: white;
            border-radius: 15px;
            padding: 35px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }
        .form-label { font-weight: 500; color: #444; }
        .btn-submit {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            border: none;
            border-radius: 8px;
            padding: 10px 30px;
            font-size: 1rem;
            transition: opacity 0.3s;
        }
        .btn-submit:hover { opacity: 0.9; color: white; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/index">
                <i class="fas fa-paint-brush me-2"></i>海报竞赛系统
            </a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/index">首页</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/news?action=list">新闻公告</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container mt-4 form-container">
        <div class="page-header">
            <h4 class="mb-1"><i class="fas fa-edit me-2"></i>编辑新闻</h4>
            <p class="mb-0 opacity-75">修改新闻内容和状态</p>
        </div>

        <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle me-1"></i><%= error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="form-card">
            <form action="${pageContext.request.contextPath}/news" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="newsId" value="<%= news.getNewsId() %>">

                <div class="mb-3">
                    <label for="title" class="form-label">
                        <i class="fas fa-heading me-1"></i>新闻标题 <span class="text-danger">*</span>
                    </label>
                    <input type="text" class="form-control" id="title" name="title"
                           value="<%= news.getTitle() != null ? news.getTitle() : "" %>"
                           required maxlength="200">
                </div>

                <div class="mb-3">
                    <label for="competitionId" class="form-label">
                        <i class="fas fa-trophy me-1"></i>关联竞赛ID（可选）
                    </label>
                    <input type="number" class="form-control" id="competitionId" name="competitionId"
                           value="<%= news.getCompetitionId() != null ? news.getCompetitionId() : "" %>">
                </div>

                <div class="mb-3">
                    <label for="content" class="form-label">
                        <i class="fas fa-align-left me-1"></i>新闻内容 <span class="text-danger">*</span>
                    </label>
                    <textarea class="form-control" id="content" name="content" rows="12"
                              required><%= news.getContent() != null ? news.getContent() : "" %></textarea>
                </div>

                <div class="mb-4">
                    <label for="status" class="form-label">
                        <i class="fas fa-toggle-on me-1"></i>状态
                    </label>
                    <select class="form-select" id="status" name="status">
                        <option value="1" <%= news.getStatus() != null && news.getStatus() == 1 ? "selected" : "" %>>已发布</option>
                        <option value="0" <%= news.getStatus() != null && news.getStatus() == 0 ? "selected" : "" %>>已撤回</option>
                    </select>
                </div>

                <div class="d-flex justify-content-between">
                    <a href="${pageContext.request.contextPath}/news?action=manage" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left me-1"></i>返回管理
                    </a>
                    <button type="submit" class="btn btn-submit">
                        <i class="fas fa-save me-1"></i>保存修改
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
