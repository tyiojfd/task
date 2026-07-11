<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>发布新闻 - 大学生海报设计竞赛系统</title>
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
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
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
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
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
    <%
    request.setAttribute("activeNav", "newsManage");
%>
<%@ include file="includes/navbar.jspf" %>

    <div class="container mt-4 form-container">
        <div class="page-header">
            <h4 class="mb-1"><i class="fas fa-plus-circle me-2"></i>发布新闻公告</h4>
            <p class="mb-0 opacity-75">发布竞赛相关的最新动态和通知</p>
        </div>

        <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-triangle me-1"></i><%= error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="form-card">
            <form action="${pageContext.request.contextPath}/news" method="post">
                <input type="hidden" name="action" value="publish">

                <div class="mb-3">
                    <label for="title" class="form-label">
                        <i class="fas fa-heading me-1"></i>新闻标题 <span class="text-danger">*</span>
                    </label>
                    <input type="text" class="form-control" id="title" name="title"
                           placeholder="请输入新闻标题" required maxlength="200">
                </div>

                <div class="mb-3">
                    <label for="competitionId" class="form-label">
                        <i class="fas fa-trophy me-1"></i>关联竞赛ID（可选）
                    </label>
                    <input type="number" class="form-control" id="competitionId" name="competitionId"
                           placeholder="留空表示通用公告">
                    <div class="form-text">关联竞赛后，该新闻将显示在对应竞赛详情页</div>
                </div>

                <div class="mb-4">
                    <label for="content" class="form-label">
                        <i class="fas fa-align-left me-1"></i>新闻内容 <span class="text-danger">*</span>
                    </label>
                    <textarea class="form-control" id="content" name="content" rows="12"
                              placeholder="请输入新闻内容（支持纯文本）" required></textarea>
                </div>

                <div class="d-flex justify-content-between">
                    <a href="${pageContext.request.contextPath}/news?action=list" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left me-1"></i>返回
                    </a>
                    <button type="submit" class="btn btn-submit">
                        <i class="fas fa-paper-plane me-1"></i>发布新闻
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
