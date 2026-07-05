package com.poster.controller;

import com.poster.model.Competition;
import com.poster.service.CompetitionService;
import com.poster.service.impl.CompetitionServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

/**
 * 竞赛Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/competition")
public class CompetitionServlet extends HttpServlet {

    private CompetitionService competitionService = new CompetitionServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现竞赛查询逻辑
        // 1. 获取action参数
        // 2. 根据action执行不同操作（list/detail/add/edit）
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现竞赛创建/更新/删除逻辑
        // 1. 获取action参数
        // 2. 根据action执行不同操作（create/update/delete）
    }
}
