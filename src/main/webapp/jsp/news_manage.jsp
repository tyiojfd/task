<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.News" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    @SuppressWarnings("unchecked")
    List<News> newsList = (List<News>) request.getAttribute("newsList");
    User sessionUser = (User) session.getAttribute("user");
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
    @SuppressWarnings("unchecked")
    List<Role> userRoles = (sessionUser != null) ? (List<Role>) session.getAttribute("roles") : null;
    boolean isAdmin = false;
    boolean isJudge = false;
    if (userRoles != null) {
        for (Role role : userRoles) {
            if ("管理员".equals(role.getRoleName())) isAdmin = true;
            if ("评委".equals(role.getRoleName())) isJudge = true;
        }
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>新闻管理 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #667eea;
            --secondary: #764ba2;
        }
        body { background: #f5f5f5; }
        .navbar-brand { font-weight: bold; }
        .page-header {
            background: linear-gradient(135deg, #434343 0%, #000000 100%);
            color: white;
            border-radius: 15px;
            padding: 30px 40px;
            margin-bottom: 25px;
        }
        .table-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }
        .table { margin-bottom: 0; }
        .table th { border-top: none; font-weight: 600; color: #555; }
        .btn-action { padding: 4px 10px; font-size: 0.85rem; }
        .status-badge { font-size: 0.8rem; }
        .empty-state { text-align: center; padding: 60px 20px; color: #aaa; }
        .empty-state i { font-size: 3rem; margin-bottom: 15px; display: block; }
    </style>
</head>
<body>
    <%
    request.setAttribute("activeNav", "newsManage");
%>
<%@ include file="includes/navbar.jspf" %>

    <div class="container mt-4">
        <div class="page-header d-flex justify-content-between align-items-center">
            <div>
                <h4 class="mb-1"><i class="fas fa-cog me-2"></i>新闻管理</h4>
                <p class="mb-0 opacity-75">管理所有新闻公告（包括已撤回）</p>
            </div>
            <a href="${pageContext.request.contextPath}/news?action=publish" class="btn btn-light">
                <i class="fas fa-plus me-1"></i>发布新闻
            </a>
        </div>

        <div class="table-card">
            <% if (newsList != null && !newsList.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th style="width: 5%">ID</th>
                                <th style="width: 35%">标题</th>
                                <th style="width: 10%">状态</th>
                                <th style="width: 10%">竞赛ID</th>
                                <th style="width: 18%">发布时间</th>
                                <th style="width: 22%">操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (News news : newsList) { %>
                                <tr>
                                    <td><%= news.getNewsId() %></td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= news.getNewsId() %>" class="text-decoration-none">
                                            <%= news.getTitle() %>
                                        </a>
                                    </td>
                                    <td>
                                        <% if (news.getStatus() != null && news.getStatus() == 1) { %>
                                            <span class="badge bg-success status-badge">已发布</span>
                                        <% } else { %>
                                            <span class="badge bg-secondary status-badge">已撤回</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <%= news.getCompetitionId() != null ? news.getCompetitionId() : "-" %>
                                    </td>
                                    <td>
                                        <%= news.getPublishTime() != null ? news.getPublishTime().format(formatter) : "未发布" %>
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <a href="${pageContext.request.contextPath}/news?action=detail&id=<%= news.getNewsId() %>"
                                               class="btn btn-outline-info btn-action" title="查看">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/news?action=edit&id=<%= news.getNewsId() %>"
                                               class="btn btn-outline-warning btn-action" title="编辑">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <button type="button" class="btn btn-outline-danger btn-action"
                                                    title="删除" onclick="confirmDelete(<%= news.getNewsId() %>, '<%= news.getTitle() %>')">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } else { %>
                <div class="empty-state">
                    <i class="far fa-newspaper"></i>
                    <h5>暂无新闻记录</h5>
                    <p>点击右上角"发布新闻"创建第一条新闻</p>
                </div>
            <% } %>
        </div>
    </div>

    <!-- 删除确认表单 -->
    <form id="deleteForm" action="${pageContext.request.contextPath}/news" method="post" style="display:none;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="id" id="deleteId">
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function confirmDelete(newsId, title) {
            if (confirm('确定要删除新闻「' + title + '」吗？此操作不可恢复。')) {
                document.getElementById('deleteId').value = newsId;
                document.getElementById('deleteForm').submit();
            }
        }
    </script>
</body>
</html>
