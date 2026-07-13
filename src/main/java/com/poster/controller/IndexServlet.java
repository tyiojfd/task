package com.poster.controller;

import com.poster.dao.WorkDAO;
import com.poster.dao.impl.WorkDAOImpl;
import com.poster.model.Competition;
import com.poster.model.Role;
import com.poster.model.Score;
import com.poster.model.User;
import com.poster.model.Work;
import com.poster.service.CompetitionService;
import com.poster.service.ScoreService;
import com.poster.service.UserService;
import com.poster.service.impl.CompetitionServiceImpl;
import com.poster.service.impl.ScoreServiceImpl;
import com.poster.service.impl.UserServiceImpl;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 首页Servlet - 展示竞赛列表
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/index")
public class IndexServlet extends HttpServlet {

    private CompetitionService competitionService = new CompetitionServiceImpl();
    private WorkDAO workDAO = new WorkDAOImpl();
    private ScoreService scoreService = new ScoreServiceImpl();
    private UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(true);

        // 获取当前登录用户（可能为null）
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        @SuppressWarnings("unchecked")
        List<Role> roles = (session != null) ? (List<Role>) session.getAttribute("roles") : null;

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

        List<Work> pendingWorks = Collections.emptyList();
        List<Score> myScores = Collections.emptyList();
        int userCount = 0;
        if (hasRole(roles, "评委")) {
            List<Work> allWorks = workDAO.findAll();
            pendingWorks = new ArrayList<>();
            if (allWorks != null) {
                for (Work work : allWorks) {
                    if (work != null && Integer.valueOf(2).equals(work.getStatus())) {
                        pendingWorks.add(work);
                    }
                }
            }
            myScores = user == null ? Collections.emptyList() : scoreService.getScoresByJudgeId(user.getUserId());
            if (myScores == null) {
                myScores = Collections.emptyList();
            }
        }
        if (hasRole(roles, "管理员")) {
            List<User> users = userService.getAllUsers();
            userCount = users == null ? 0 : users.size();
        }

        // 传递数据到JSP
        request.setAttribute("currentUser", user);
        request.setAttribute("competitions", competitions);
        request.setAttribute("globalStats", globalStats);
        request.setAttribute("pendingWorks", pendingWorks);
        request.setAttribute("myScores", myScores);
        request.setAttribute("userCount", userCount);

        // 按角色进入对应首页；普通用户和未登录用户保留现有队员首页。
        request.getRequestDispatcher(resolveHomeView(roles)).forward(request, response);
    }

    private String resolveHomeView(List<Role> roles) {
        if (roles != null) {
            for (Role role : roles) {
                if (role != null && "管理员".equals(role.getRoleName())) {
                    return "/jsp/admin_home.jsp";
                }
            }
            for (Role role : roles) {
                if (role != null && "评委".equals(role.getRoleName())) {
                    return "/jsp/judge_home.jsp";
                }
            }
        }
        return "/jsp/index.jsp";
    }

    private boolean hasRole(List<Role> roles, String roleName) {
        if (roles == null) {
            return false;
        }
        for (Role role : roles) {
            if (role != null && roleName.equals(role.getRoleName())) {
                return true;
            }
        }
        return false;
    }
}
