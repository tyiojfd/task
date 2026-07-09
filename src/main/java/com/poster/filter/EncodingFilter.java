package com.poster.filter;

import javax.servlet.*;
import java.io.IOException;

/**
 * 字符编码过滤器（通过web.xml注册，不使用注解避免双重注册）
 * @author 团队共建
 * @date 2026-07-04
 */
public class EncodingFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        // ❌ 移除 setContentType — 否则会强制 JS/CSS/图片等静态资源也返回 text/html，
        // 导致浏览器拒绝执行 ES module 脚本 (Strict MIME type checking)。
        // Tomcat 的默认 Servlet 会根据文件扩展名自动设置正确的 Content-Type。
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
