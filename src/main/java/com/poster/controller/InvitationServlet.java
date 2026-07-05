package com.poster.controller;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

/**
 * 邀请Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/invitation")
public class InvitationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现邀请查询逻辑
        // 1. 获取当前用户的邀请列表
        // 2. 转发到邀请页面
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现邀请操作逻辑
        // 1. 获取action参数
        // 2. 根据action执行不同操作（accept/reject）
    }
}
