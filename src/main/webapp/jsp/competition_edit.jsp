<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.Competition" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    Competition competition = (Competition) request.getAttribute("competition");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>编辑竞赛 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/index">海报竞赛系统</a>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0">编辑竞赛</h4>
                    </div>
                    <div class="card-body">
                        <% if (request.getAttribute("error") != null) { %>
                            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
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
                                           value="<%= competition.getName() %>" required>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">竞赛主题</label>
                                    <input type="text" class="form-control" name="theme"
                                           value="<%= competition.getTheme() != null ? competition.getTheme() : "" %>">
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">竞赛描述</label>
                                    <textarea class="form-control" name="description" rows="4"><%= competition.getDescription() != null ? competition.getDescription() : "" %></textarea>
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
                                    </select>
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
</body>
</html>
