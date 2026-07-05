package com.poster.controller;

import com.poster.service.NewsService;
import com.poster.service.impl.NewsServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

/**
 * 新闻Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/news")
public class NewsServlet extends HttpServlet {

    private NewsService newsService = new NewsServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现新闻查询逻辑
        // 1. 获取action参数
        // 2. 根据action执行不同操作（list/detail）
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现新闻发布/更新/删除逻辑
        // 1. 获取action参数
        // 2. 根据action执行不同操作（publish/update/delete）
    }
}
