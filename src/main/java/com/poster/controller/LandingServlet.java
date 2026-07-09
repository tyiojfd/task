package com.poster.controller;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * 动态进入页控制器 — 映射到根路径，直接提供 React 落地页。
 * 使用空字符串 URL pattern（精确匹配上下文根路径），避免
 * welcome-file 302 重定向触发 AuthFilter 拦截。
 *
 * @author 洪振博
 * @date 2026-07-08
 */
@WebServlet(value = {""}, loadOnStartup = 1)
public class LandingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // 精确匹配上下文根路径，forward 到 React index.html，不改变 URL
        req.getRequestDispatcher("/index.html").forward(req, resp);
    }
}
