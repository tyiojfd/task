package com.poster.controller;

import com.poster.model.Work;
import com.poster.service.WorkService;
import com.poster.service.impl.WorkServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

/**
 * 作品Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/work")
public class WorkServlet extends HttpServlet {

    private WorkService workService = new WorkServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现了作品查询逻辑
        // 1. 获取action参数
        // 2. 根据action执行不同操作（list/detail/myWorks）
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现了作品提交/更新/删除逻辑
        // 1. 获取action参数
        // 2. 根据action执行不同操作（submit/update/delete/like/share）
    }
}
