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
                                    <button class="btn btn-sm btn-outline-primary btn-role-trigger" type="button"
                                            data-userid="${user.userId}"
                                            data-realname="<c:out value='${user.realName}'/>">角色</button>
                                    <!-- 重置密码 -->
                                    <button class="btn btn-sm btn-outline-warning btn-pwd-trigger" type="button"
                                            data-userid="${user.userId}"
                                            data-realname="<c:out value='${user.realName}'/>">重置密码</button>
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

<!-- ═══════════ 共享角色 Modal ═══════════ -->
<div class="modal fade" id="sharedRoleModal" tabindex="-1">
    <div class="modal-dialog"><div class="modal-content">
        <form method="post" action="${pageContext.request.contextPath}/admin/users">
            <div class="modal-header">
                <h5 class="modal-title" id="roleModalTitle">分配角色</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="roleModalBody">
                <input type="hidden" name="action" value="roles">
                <input type="hidden" name="userId" id="roleUserId">
                <div id="roleChecks"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button type="submit" class="btn btn-primary">保存</button>
            </div>
        </form>
    </div></div>
</div>

<!-- ═══════════ 共享重置密码 Modal ═══════════ -->
<div class="modal fade" id="sharedPwdModal" tabindex="-1">
    <div class="modal-dialog"><div class="modal-content">
        <form method="post" action="${pageContext.request.contextPath}/admin/users">
            <div class="modal-header">
                <h5 class="modal-title" id="pwdModalTitle">重置密码</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" name="action" value="resetPwd">
                <input type="hidden" name="userId" id="pwdUserId">
                <div class="mb-3">
                    <label class="form-label">新密码（至少6位）</label>
                    <input type="password" name="newPassword" class="form-control" minlength="6" required>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">取消</button>
                <button type="submit" class="btn btn-warning">重置</button>
            </div>
        </form>
    </div></div>
</div>

<script>
// 所有角色数据（服务端渲染到 JS 变量）
var _allRoles = [
    <c:forEach var="r" items="${allRoles}" varStatus="st">
    {roleId: ${r.roleId}, roleName: '<c:out value="${r.roleName}"/>', roleDesc: '<c:out value="${r.roleDesc}" default=""/>'}<c:if test="${!st.last}">,</c:if>
    </c:forEach>
];
// 每个用户的角色ID集合 { userId: [roleId, ...] }
var _userRoleIds = {
    <c:forEach var="entry" items="${userRolesMap}" varStatus="st">
    ${entry.key}: [<c:forEach var="ur" items="${entry.value}" varStatus="st2">${ur.roleId}<c:if test="${!st2.last}">,</c:if></c:forEach>]<c:if test="${!st.last}">,</c:if>
    </c:forEach>
};

// 获取 Bootstrap modal 实例（带缓存）
var _roleModal = null, _pwdModal = null;
function getRoleModal() {
    if (!_roleModal) _roleModal = new bootstrap.Modal(document.getElementById('sharedRoleModal'));
    return _roleModal;
}
function getPwdModal() {
    if (!_pwdModal) _pwdModal = new bootstrap.Modal(document.getElementById('sharedPwdModal'));
    return _pwdModal;
}

// 角色按钮点击
document.querySelectorAll('.btn-role-trigger').forEach(function(btn) {
    btn.addEventListener('click', function() {
        var userId = parseInt(this.dataset.userid);
        var realName = this.dataset.realname;
        document.getElementById('roleModalTitle').textContent = '分配角色 - ' + realName;
        document.getElementById('roleUserId').value = userId;

        // 生成角色复选框
        var roleIds = _userRoleIds[userId] || [];
        var html = '';
        _allRoles.forEach(function(r) {
            var checked = roleIds.indexOf(r.roleId) >= 0 ? ' checked' : '';
            html += '<div class="form-check mb-2">';
            html += '<input class="form-check-input" type="checkbox" name="roleIds" value="' + r.roleId + '" id="r_' + userId + '_' + r.roleId + '"' + checked + '>';
            html += '<label class="form-check-label" for="r_' + userId + '_' + r.roleId + '">' + r.roleName + ' <span class="text-muted">' + (r.roleDesc || '') + '</span></label>';
            html += '</div>';
        });
        document.getElementById('roleChecks').innerHTML = html;
        getRoleModal().show();
    });
});

// 密码重置按钮点击
document.querySelectorAll('.btn-pwd-trigger').forEach(function(btn) {
    btn.addEventListener('click', function() {
        var userId = parseInt(this.dataset.userid);
        var realName = this.dataset.realname;
        document.getElementById('pwdModalTitle').textContent = '重置密码 - ' + realName;
        document.getElementById('pwdUserId').value = userId;
        getPwdModal().show();
    });
});
</script>
</body>
</html>
