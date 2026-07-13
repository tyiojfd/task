package com.poster.filter;

import com.poster.model.Role;
import com.poster.model.User;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Locale;

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
                || relativePath.startsWith("/images/") || isPublicUpload(relativePath)
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

        // 竞赛大厅和详情公开浏览，管理操作仍需管理员权限。
        if (relativePath.equals("/competition")) {
            return action == null || "list".equals(action) || "detail".equals(action);
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
            return "view".equals(action) || "download".equals(action);
        }

        return false;
    }

    private boolean isPublicUpload(String relativePath) {
        if (relativePath == null) {
            return false;
        }
        String lowerPath = relativePath.toLowerCase(Locale.ROOT);
        if (lowerPath.matches("/uploads/avatars/[^/]+\\.(jpg|jpeg|png|gif|webp)")) {
            return true;
        }
        return lowerPath.matches("/uploads/competition_[0-9]+/cover\\.(jpg|jpeg|png)");
    }

    /**
     * 基于路径和action做最小RBAC校验
     */
    private boolean hasPermission(String relativePath, String action, List<Role> roles) {
        boolean isAdmin = hasRole(roles, "管理员");
        boolean isJudge = hasRole(roles, "评委");
        // 角色可以叠加：评委账号如果同时拥有参与者角色，仍可访问自己负责的队伍。
        // 具体队伍的负责人身份由 Team.leaderId/TeamMember.role 再次校验，不能只靠全局角色判断。
        boolean isParticipant = (hasRole(roles, "队员") || hasRole(roles, "队长")) && !isAdmin;

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
            if ("view".equals(action) || "download".equals(action)) {
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
                || relativePath.startsWith("/application") || relativePath.startsWith("/work")) {
            return isParticipant || isAdmin;
        }

        // 这些接口会在Servlet内部基于作品/队伍/竞赛再次做对象级鉴权，
        // 过滤器只负责确保调用者已登录且具备基础角色，否则图片和附件永远到不了业务校验。
        if (relativePath.equals("/image-data") || relativePath.equals("/upload")
                || relativePath.startsWith("/uploads/")) {
            return isParticipant || isJudge || isAdmin;
        }

        if (relativePath.startsWith("/profile")) {
            return true;
        }

        // 未明确列入权限矩阵的新Servlet默认拒绝，避免新增接口意外绕过授权。
        return false;
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
