package com.poster.controller;

import com.poster.service.ScoreService;
import com.poster.service.impl.ScoreServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

/**
 * 评分Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/score")
public class ScoreServlet extends HttpServlet {

    private ScoreService scoreService = new ScoreServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现评分查询逻辑
        // 1. 获取action参数
        // 2. 根据action执行不同操作（list/workScores）
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现评分提交逻辑
        // 1. 获取评分数据
        // 2. 调用Service添加评分
        // 3. 返回结果
    }
}
