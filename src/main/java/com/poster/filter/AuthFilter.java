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

        String action = req.getParameter("action");

        // 公开资源，不需要登录
        if (isPublicResource(relativePath, action)) {
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

        if (!hasPermission(relativePath, action, roles)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "无权限访问该功能");
            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * 判断是否为公开资源（不需要登录即可访问）
     */
    private boolean isPublicResource(String relativePath, String action) {
        if (relativePath.startsWith("/css/") || relativePath.startsWith("/js/")
                || relativePath.startsWith("/images/") || relativePath.startsWith("/uploads/")
                || relativePath.startsWith("/assets/") || relativePath.equals("/index.html")) {
            return true;
        }

        if (relativePath.startsWith("/login") || relativePath.startsWith("/register")
                || relativePath.startsWith("/logout") || relativePath.startsWith("/forgot-password")) {
            return true;
        }

        if (relativePath.startsWith("/api/public/")) {
            return true;
        }

        if (relativePath.equals("/") || relativePath.equals("/index") || relativePath.equals("")) {
            return true;
        }

        // 新闻公开仅限列表和详情。URI 不包含 query string，必须使用 action 参数判断。
        if (relativePath.equals("/news")) {
            return action == null || "list".equals(action) || "detail".equals(action);
        }

        // 获奖名单和获奖详情公开；获奖管理必须登录并由管理员访问。
        if (relativePath.equals("/award")) {
            return action == null || "list".equals(action) || "detail".equals(action);
        }

        // 奖状详情可公开查看；我的奖状和证书管理需要登录后再做角色校验。
        if (relativePath.equals("/certificate")) {
            return "view".equals(action);
        }

        return false;
    }

    /**
     * 基于路径和action做最小RBAC校验
     */
    private boolean hasPermission(String relativePath, String action, List<Role> roles) {
        boolean isAdmin = hasRole(roles, "管理员");
        boolean isJudge = hasRole(roles, "评委");
        boolean isParticipant = (hasRole(roles, "队员") || hasRole(roles, "队长")) && !isAdmin && !isJudge;

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

        if (relativePath.startsWith("/score") || relativePath.startsWith("/comment")) {
            return isJudge;
        }

        if (relativePath.startsWith("/award")) {
            // 获奖名单和详情公开查看，管理操作仅限管理员
            if ("list".equals(action) || "detail".equals(action) || action == null) {
                return true;
            }
            return isAdmin;
        }

        if (relativePath.startsWith("/certificate")) {
            if ("view".equals(action)) {
                return true;
            }
            if ("myCertificates".equals(action)) {
                return isParticipant;
            }
            if ("list".equals(action)) {
                return isAdmin;
            }
            return isAdmin;
        }

        if (relativePath.startsWith("/admin/")) {
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
