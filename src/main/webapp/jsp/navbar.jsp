<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.poster.model.User" %>
<%@ page import="com.poster.model.Role" %>
<%@ page import="java.util.List" %>
<%
/**
 * 统一导航栏组件 — 全部JSP页面共用
 * 使用方式：<% request.setAttribute("activePage", "home"); %> <%@ include file="navbar.jsp" %>
 * activePage 可选值: "home" | "competitionList" | "myTeams" | "myWorks" | "invitation" | "scoreManage" | "newsList" | "profile"
 * 注意：所有内部变量使用 _nav 前缀，避免与父页面变量冲突（JSP静态include共享作用域）
 *
 * @author 队员C（统一整合）
 * @date 2026-07-07
 */

User _navUser = (User) session.getAttribute("user");
boolean _navLoggedIn = (_navUser != null);

boolean _navAdmin = false;
boolean _navJudge = false;
if (_navLoggedIn) {
    @SuppressWarnings("unchecked")
    List<Role> roles = (List<Role>) session.getAttribute("roles");
    if (roles != null) {
        for (Role r : roles) {
            if ("管理员".equals(r.getRoleName())) _navAdmin = true;
            if ("评委".equals(r.getRoleName())) _navJudge = true;
        }
    }
}

String _navActive = (String) request.getAttribute("activePage");
if (_navActive == null) _navActive = "";
%>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/index">
            <i class="fas fa-palette me-2"></i>海报竞赛系统
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarMain">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link<%= "home".equals(_navActive) ? " active" : "" %>" href="${pageContext.request.contextPath}/index">
                        <i class="fas fa-home me-1"></i>首页
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link<%= "competitionList".equals(_navActive) ? " active" : "" %>" href="${pageContext.request.contextPath}/competition?action=list">
                        <i class="fas fa-trophy me-1"></i>竞赛列表
                    </a>
                </li>
                <% if (_navLoggedIn) { %>
                <li class="nav-item">
                    <a class="nav-link<%= "myTeams".equals(_navActive) ? " active" : "" %>" href="${pageContext.request.contextPath}/team?action=myTeams">
                        <i class="fas fa-users me-1"></i>我的队伍
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link<%= "myWorks".equals(_navActive) ? " active" : "" %>" href="${pageContext.request.contextPath}/work?action=myWorks">
                        <i class="fas fa-image me-1"></i>我的作品
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link<%= "invitation".equals(_navActive) ? " active" : "" %>" href="${pageContext.request.contextPath}/invitation">
                        <i class="fas fa-envelope me-1"></i>邀请通知
                    </a>
                </li>
                <% if (_navJudge) { %>
                <li class="nav-item">
                    <a class="nav-link<%= "scoreManage".equals(_navActive) ? " active" : "" %>" href="${pageContext.request.contextPath}/score?action=list">
                        <i class="fas fa-star me-1"></i>评分管理
                    </a>
                </li>
                <% } %>
                <% if (_navAdmin) { %>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="fas fa-cog me-1"></i>管理中心
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/competition?action=list"><i class="fas fa-trophy me-2"></i>竞赛管理</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/award?action=manage"><i class="fas fa-medal me-2"></i>获奖管理</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/news?action=manage"><i class="fas fa-newspaper me-2"></i>新闻管理</a></li>
                    </ul>
                </li>
                <% } %>
                <li class="nav-item">
                    <a class="nav-link<%= "newsList".equals(_navActive) ? " active" : "" %>" href="${pageContext.request.contextPath}/news?action=list">
                        <i class="fas fa-bullhorn me-1"></i>新闻公告
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle<%= "profile".equals(_navActive) ? " active" : "" %>" href="#" role="button" data-bs-toggle="dropdown">
                        <i class="fas fa-user-circle me-1"></i><%= _navUser.getRealName() != null ? _navUser.getRealName() : _navUser.getUsername() %>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile"><i class="fas fa-id-card me-2"></i>个人中心</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt me-2"></i>退出登录</a></li>
                    </ul>
                </li>
                <% } else { %>
                <li class="nav-item">
                    <a class="nav-link<%= "newsList".equals(_navActive) ? " active" : "" %>" href="${pageContext.request.contextPath}/news?action=list">
                        <i class="fas fa-bullhorn me-1"></i>新闻公告
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/login"><i class="fas fa-sign-in-alt me-1"></i>登录</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/register" style="background:rgba(255,255,255,0.15);border-radius:8px;padding:0.4rem 1rem;"><i class="fas fa-user-plus me-1"></i>注册</a>
                </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>
