package com.poster.controller;

import com.poster.model.Team;
import com.poster.service.TeamService;
import com.poster.service.impl.TeamServiceImpl;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

/**
 * 队伍Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/team")
public class TeamServlet extends HttpServlet {

    private TeamService teamService = new TeamServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现队伍查询逻辑
        // 1. 获取action参数
        // 2. 根据action执行不同操作（list/detail/myTeams）
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现队伍创建/更新/删除逻辑
        // 1. 获取action参数
        // 2. 根据action执行不同操作（create/update/delete/invite/remove）
    }
}
