package com.poster.filter;

import com.poster.model.Role;
import com.poster.model.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * 登录与角色权限验证过滤器（需在web.xml中配置，确保在EncodingFilter之后执行）
 * @author 团队共建
 * @date 2026-07-04
 */
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path = req.getRequestURI();
        String contextPath = req.getContextPath();
        String relativePath = path.substring(contextPath.length());

        // 公开资源，不需要登录
        if (isPublicResource(relativePath)) {
            chain.doFilter(request, response);
            return;
        }

        // 检查登录状态
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(contextPath + "/login");
            return;
        }

        @SuppressWarnings("unchecked")
        List<Role> roles = (List<Role>) session.getAttribute("roles");

        if (!hasPermission(relativePath, req.getParameter("action"), roles)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无权限访问该功能");
            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * 判断是否为公开资源（不需要登录即可访问）
     */
    private boolean isPublicResource(String relativePath) {
        if (relativePath.startsWith("/css/") || relativePath.startsWith("/js/")
                || relativePath.startsWith("/images/") || relativePath.startsWith("/uploads/")) {
            return true;
        }

        if (relativePath.startsWith("/login") || relativePath.startsWith("/register")
                || relativePath.startsWith("/logout")) {
            return true;
        }

        if (relativePath.startsWith("/api/public/")) {
            return true;
        }

        if (relativePath.equals("/") || relativePath.equals("/index") || relativePath.equals("")) {
            return true;
        }

        // 新闻公开仅限列表和详情
        return relativePath.equals("/news") || relativePath.startsWith("/news?action=list")
                || relativePath.startsWith("/news?action=detail");
    }

    /**
     * 基于路径和action做最小RBAC校验
     */
    private boolean hasPermission(String relativePath, String action, List<Role> roles) {
        boolean isAdmin = hasRole(roles, "管理员");
        boolean isJudge = hasRole(roles, "评委");
        boolean isParticipant = !isAdmin && !isJudge;

        if (relativePath.startsWith("/competition")) {
            if (action == null || "list".equals(action) || "detail".equals(action)) {
                return true;
            }
            return isAdmin;
        }

        if (relativePath.startsWith("/news")) {
            if (action == null || "list".equals(action) || "detail".equals(action)) {
                return true;
            }
            return isAdmin;
        }

        if (relativePath.startsWith("/score")) {
            return isJudge;
        }

        if (relativePath.startsWith("/award")) {
            return isAdmin;
        }

        if (relativePath.startsWith("/team") || relativePath.startsWith("/invitation")
                || relativePath.startsWith("/work")) {
            return isParticipant;
        }

        if (relativePath.startsWith("/profile")) {
            return true;
        }

        return true;
    }

    private boolean hasRole(List<Role> roles, String roleName) {
        if (roles == null) {
            return false;
        }
        for (Role role : roles) {
            if (roleName.equals(role.getRoleName())) {
                return true;
            }
        }
        return false;
    }

    @Override
    public void destroy() {
    }
}
