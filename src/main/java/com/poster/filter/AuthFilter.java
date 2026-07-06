package com.poster.filter;

import com.poster.model.User;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 登录权限验证过滤器（需在web.xml中配置，确保在EncodingFilter之后执行）
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

        // 公开资源，不需要登录
        if (isPublicResource(path, contextPath)) {
            chain.doFilter(request, response);
            return;
        }

        // 检查登录状态
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            // 未登录，跳转到登录页
            resp.sendRedirect(contextPath + "/login");
        } else {
            chain.doFilter(request, response);
        }
    }

    /**
     * 判断是否为公开资源（不需要登录即可访问）
     */
    private boolean isPublicResource(String path, String contextPath) {
        // 去除上下文路径
        String relativePath = path.substring(contextPath.length());

        // 静态资源
        if (relativePath.startsWith("/css/") || relativePath.startsWith("/js/")
                || relativePath.startsWith("/images/") || relativePath.startsWith("/uploads/")) {
            return true;
        }

        // 公开页面和接口
        if (relativePath.startsWith("/login") || relativePath.startsWith("/register")
                || relativePath.startsWith("/logout")) {
            return true;
        }

        // 公开API
        if (relativePath.startsWith("/api/public/")) {
            return true;
        }

        // 首页公开
        if (relativePath.equals("/") || relativePath.equals("/index") || relativePath.equals("")) {
            return true;
        }

        // 新闻公告公开（列表和详情不需要登录）
        if (relativePath.startsWith("/news")) {
            return true;
        }

        return false;
    }

    @Override
    public void destroy() {
    }
}
