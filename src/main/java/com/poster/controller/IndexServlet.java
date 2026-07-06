package com.poster.controller;

import com.poster.model.User;
import com.poster.model.Competition;
import com.poster.service.CompetitionService;
import com.poster.service.impl.CompetitionServiceImpl;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

/**
 * 首页Servlet - 展示竞赛列表
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/index")
public class IndexServlet extends HttpServlet {

    private CompetitionService competitionService = new CompetitionServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 获取当前登录用户（可能为null）
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 加载所有竞赛数据
        List<Competition> competitions = competitionService.getAllCompetitions();

        // 传递数据到JSP
        request.setAttribute("currentUser", user);
        request.setAttribute("competitions", competitions);

        // 转发到首页
        request.getRequestDispatcher("/jsp/index.jsp").forward(request, response);
    }
}
