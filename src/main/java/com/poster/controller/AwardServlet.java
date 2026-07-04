package com.poster.controller;

import com.poster.service.AwardService;
import com.poster.service.impl.AwardServiceImpl;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

/**
 * 获奖Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/award")
public class AwardServlet extends HttpServlet {

    private AwardService awardService = new AwardServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现获奖查询逻辑
        // 1. 获取action参数。
        // 2. 根据action执行不同操作（list/detail）..
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现设置获奖逻辑
        // 1. 获取获奖数据
        // 2. 调用Service设置获奖
        // 3. 生成电子奖状
    }
}
