<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    @SuppressWarnings("unchecked")
    List<User> users = (List<User>) request.getAttribute("users");
    @SuppressWarnings("unchecked")
    List<Role> allRoles = (List<Role>) request.getAttribute("allRoles");
    @SuppressWarnings("unchecked")
    Map<Integer, List<Role>> userRolesMap = (Map<Integer, List<Role>>) request.getAttribute("userRolesMap");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户管理 - 大学生海报设计竞赛系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<%@ include file="includes/app-shell-assets.jspf" %>
</head>
<body class="app-page app-page-workbench app-page-user-manage">
<%
    request.setAttribute("activeNav", "users");
%>
<%@ include file="includes/navbar.jspf" %>

<div class="page-header">
    <div class="container">
        <h2 class="fw-bold mb-2">用户管理</h2>
        <p class="mb-0">查询用户、启用/禁用账号、分配角色、重置密码</p>
    </div>
</div>

<div class="container mb-5">
    <c:if test="${param.ok == '1'}"><div class="alert alert-success alert-dismissible fade show">操作成功<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>
    <c:if test="${param.err == '1'}"><div class="alert alert-danger alert-dismissible fade show">操作失败<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>

    <div class="card mb-4">
        <div class="card-body">
            <form class="row g-2" action="${pageContext.request.contextPath}/admin/users" method="get">
                <div class="col-md-8">
                    <input type="text" name="keyword" class="form-control" placeholder="按用户名、姓名、邮箱搜索" value="<c:out value='${keyword}' default=''/>">
                </div>
                <div class="col-md-2 d-grid">
                    <button class="btn btn-primary" type="submit">搜索</button>
                </div>
                <div class="col-md-2 d-grid">
                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary">清空</a>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>用户</th>
                        <th>联系方式</th>
                        <th>状态</th>
                        <th>角色</th>
                        <th style="width: 320px;">操作</th>
                    </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${empty users}">
                        <tr><td colspan="5" class="text-center text-muted py-5">暂无用户数据</td></tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="user" items="${users}">
                        <tr>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <span class="avatar-circle"><c:out value="${fn:substring(user.realName, 0, 1)}" default="?"/></span>
                                    <div>
                                        <div class="fw-bold"><c:out value="${user.realName}"/></div>
                                        <div class="text-muted small">@<c:out value="${user.username}"/> · ID ${user.userId}</div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div><c:out value="${user.email}" default="-"/></div>
                                <div class="text-muted small"><c:out value="${user.phone}" default="未填手机号"/></div>
                            </td>
                            <td>
                                <span class="badge bg-${user.status == 1 ? 'success' : 'secondary'}">${user.status == 1 ? '正常' : '禁用'}</span>
                            </td>
                            <td>
                                <c:set var="roles" value="${userRolesMap[user.userId]}"/>
                                <c:choose>
                                    <c:when test="${not empty roles}">
                                        <c:forEach var="r" items="${roles}">
                                            <span class="badge bg-info text-dark role-tag"><c:out value="${r.roleName}"/></span>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise><span class="text-muted small">未分配</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="d-flex flex-wrap gap-1">
                                    <!-- 启用/禁用 -->
                                    <form method="post" action="${pageContext.request.contextPath}/admin/users" style="display:inline">
                                        <input type="hidden" name="action" value="status">
                                        <input type="hidden" name="userId" value="${user.userId}">
                                        <input type="hidden" name="status" value="${user.status == 1 ? 0 : 1}">
                                        <button class="btn btn-sm ${user.status == 1 ? 'btn-outline-danger' : 'btn-outline-success'}" type="submit">${user.status == 1 ? '禁用' : '启用'}</button>
                                    </form>
                                    <!-- 角色管理 -->
                                    <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#roleModal${user.userId}">角色</button>
                                    <!-- 重置密码 -->
                                    <button class="btn btn-sm btn-outline-warning" data-bs-toggle="modal" data-bs-target="#pwdModal${user.userId}">重置密码</button>
                                </div>

                                <!-- 角色 Modal -->
                                <div class="modal fade" id="roleModal${user.userId}" tabindex="-1">
                                    <div class="modal-dialog"><div class="modal-content">
                                        <form method="post" action="${pageContext.request.contextPath}/admin/users">
                                            <div class="modal-header"><h5 class="modal-title">分配角色 - <c:out value="${user.realName}"/></h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                                            <div class="modal-body">
                                                <input type="hidden" name="action" value="roles">
                                                <input type="hidden" name="userId" value="${user.userId}">
                                                <c:forEach var="role" items="${allRoles}">
                                                <div class="form-check mb-2">
                                                    <input class="form-check-input" type="checkbox" name="roleIds" value="${role.roleId}" id="r${user.userId}_${role.roleId}"
                                                        <c:forEach var="ur" items="${userRolesMap[user.userId]}"><c:if test="${ur.roleId == role.roleId}">checked</c:if></c:forEach>>
                                                    <label class="form-check-label" for="r${user.userId}_${role.roleId}"><c:out value="${role.roleName}"/> <span class="text-muted"><c:out value="${role.roleDesc}" default=""/></span></label>
                                                </div>
                                                </c:forEach>
                                            </div>
                                            <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button><button type="submit" class="btn btn-primary">保存</button></div>
                                        </form>
                                    </div></div>
                                </div>

                                <!-- 重置密码 Modal -->
                                <div class="modal fade" id="pwdModal${user.userId}" tabindex="-1">
                                    <div class="modal-dialog"><div class="modal-content">
                                        <form method="post" action="${pageContext.request.contextPath}/admin/users">
                                            <div class="modal-header"><h5 class="modal-title">重置密码 - <c:out value="${user.realName}"/></h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                                            <div class="modal-body">
                                                <input type="hidden" name="action" value="resetPwd">
                                                <input type="hidden" name="userId" value="${user.userId}">
                                                <div class="mb-3"><label class="form-label">新密码（至少6位）</label><input type="password" name="newPassword" class="form-control" minlength="6" required></div>
                                            </div>
                                            <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button><button type="submit" class="btn btn-warning">重置</button></div>
                                        </form>
                                    </div></div>
                                </div>
                            </td>
                        </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
