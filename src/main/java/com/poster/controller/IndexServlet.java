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
import java.util.Map;
import java.util.HashMap;

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
        HttpSession session = request.getSession(true);

        // 获取当前登录用户（可能为null）
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 加载所有竞赛数据
        List<Competition> competitions = competitionService.getAllCompetitions();

        // 全局统计
        Map<String, Integer> globalStats = new HashMap<>();
        int totalTeams = 0;
        int totalWorks = 0;
        if (competitions != null) {
            for (Competition c : competitions) {
                Map<String, Integer> s = competitionService.getCompetitionStats(c.getCompetitionId());
                totalTeams += s.getOrDefault("teamCount", 0);
                totalWorks += s.getOrDefault("workCount", 0);
            }
        }
        globalStats.put("compCount", competitions != null ? competitions.size() : 0);
        globalStats.put("teamCount", totalTeams);
        globalStats.put("workCount", totalWorks);

        // 统计进行中的竞赛（status=2）
        int activeCount = 0;
        if (competitions != null) {
            for (Competition c : competitions) {
                if (c.getStatus() != null && c.getStatus() == 2) {
                    activeCount++;
                }
            }
        }
        globalStats.put("activeCount", activeCount);

        // 传递数据到JSP
        request.setAttribute("currentUser", user);
        request.setAttribute("competitions", competitions);
        request.setAttribute("globalStats", globalStats);

        // 转发到首页
        request.getRequestDispatcher("/jsp/index.jsp").forward(request, response);
    }
}
