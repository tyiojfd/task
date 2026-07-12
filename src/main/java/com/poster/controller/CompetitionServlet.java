package com.poster.controller;

import com.poster.model.Competition;
import com.poster.model.User;
import com.poster.model.Team;
import com.poster.model.CompetitionCategory;
import com.poster.model.TeamApplication;
import com.poster.dao.CategoryDAO;
import com.poster.dao.impl.CategoryDAOImpl;
import com.poster.service.CompetitionService;
import com.poster.service.TeamService;
import com.poster.service.impl.CompetitionServiceImpl;
import com.poster.service.impl.TeamServiceImpl;
import com.poster.service.TeamApplicationService;
import com.poster.service.impl.TeamApplicationServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * 竞赛Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/competition")
public class CompetitionServlet extends HttpServlet {

    private CompetitionService competitionService = new CompetitionServiceImpl();
    private TeamService teamService = new TeamServiceImpl();
    private TeamApplicationService applicationService = new TeamApplicationServiceImpl();
    private CategoryDAO categoryDAO = new CategoryDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null || "list".equals(action)) {
            // 竞赛列表
            listCompetitions(request, response);
        } else if ("detail".equals(action)) {
            // 竞赛详情
            showCompetitionDetail(request, response);
        } else if ("add".equals(action)) {
            // 跳转到添加页面
            request.getRequestDispatcher("/jsp/competition_add.jsp").forward(request, response);
        } else if ("edit".equals(action)) {
            // 跳转到编辑页面（需要先查询数据）
            showEditPage(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/competition?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            // 创建竞赛
            createCompetition(request, response);
        } else if ("update".equals(action)) {
            // 更新竞赛
            updateCompetition(request, response);
        } else if ("delete".equals(action)) {
            // 删除竞赛
            deleteCompetition(request, response);
        } else if ("cancel".equals(action)) {
            // 取消竞赛
            cancelCompetition(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/competition?action=list");
        }
    }

    /**
     * 显示竞赛列表（支持关键词搜索、年度筛选、状态筛选）
     */
    private void listCompetitions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String yearStr = request.getParameter("year");
        String statusStr = request.getParameter("status");

        Integer year = null;
        Integer status = null;
        try {
            if (yearStr != null && !yearStr.isEmpty()) {
                year = Integer.parseInt(yearStr);
            }
        } catch (NumberFormatException ignored) {}
        try {
            if (statusStr != null && !statusStr.isEmpty()) {
                status = Integer.parseInt(statusStr);
            }
        } catch (NumberFormatException ignored) {}

        List<Competition> competitions = competitionService.searchCompetitions(keyword, year, status);

        Map<String, Integer> globalStats = new java.util.HashMap<>();
        int totalTeams = 0;
        int totalWorks = 0;
        for (Competition c : competitions) {
            Map<String, Integer> s = competitionService.getCompetitionStats(c.getCompetitionId());
            totalTeams += s.getOrDefault("teamCount", 0);
            totalWorks += s.getOrDefault("workCount", 0);
        }
        globalStats.put("compCount", competitions != null ? competitions.size() : 0);
        globalStats.put("teamCount", totalTeams);
        globalStats.put("workCount", totalWorks);
        request.setAttribute("globalStats", globalStats);

        request.setAttribute("competitions", competitions);
        request.setAttribute("keyword", keyword);
        request.setAttribute("filterYear", year);
        request.setAttribute("filterStatus", status);
        request.getRequestDispatcher("/jsp/competition_list.jsp").forward(request, response);
    }

    /**
     * 显示竞赛详情
     */
    private void showCompetitionDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                Integer competitionId = Integer.parseInt(idStr);
                Competition competition = competitionService.getCompetitionById(competitionId);

                // 检查用户是否已参加该竞赛
                HttpSession session = request.getSession(false);
                User user = (session != null) ? (User) session.getAttribute("user") : null;
                boolean hasJoined = false;
                Team userTeam = null;

                if (user != null) {
                    // 查询用户在该竞赛中的队伍（无论是队长还是队员）
                    userTeam = teamService.getUserTeamInCompetition(user.getUserId(), competitionId);
                    hasJoined = (userTeam != null);
                }

                // 获取竞赛统计、竞赛方向、可申请队伍
                Map<String, Integer> stats = competitionService.getCompetitionStats(competitionId);
                List<CompetitionCategory> categories = categoryDAO.findByCompetitionId(competitionId);
                List<Team> availableTeams = new java.util.ArrayList<>();
                java.util.Map<Integer, Integer> teamMemberCounts = new java.util.HashMap<>();
                java.util.Set<Integer> appliedTeamIds = new java.util.HashSet<>();

                if (competition != null && competition.getStatus() != null && competition.getStatus() == 1) {
                    List<Team> competitionTeams = teamService.getTeamsByCompetitionId(competitionId);
                    if (competitionTeams != null) {
                        for (Team team : competitionTeams) {
                            if (team.getStatus() != null && team.getStatus() == 1) {
                                availableTeams.add(team);
                                int memberCount = new com.poster.dao.impl.TeamMemberDAOImpl().countByTeamId(team.getTeamId());
                                teamMemberCounts.put(team.getTeamId(), memberCount);
                                if (user != null && applicationService.getPendingApplication(team.getTeamId(), user.getUserId()) != null) {
                                    appliedTeamIds.add(team.getTeamId());
                                }
                            }
                        }
                    }
                }

                request.setAttribute("stats", stats);
                request.setAttribute("categories", categories);
                request.setAttribute("availableTeams", availableTeams);
                request.setAttribute("teamMemberCounts", teamMemberCounts);
                request.setAttribute("appliedTeamIds", appliedTeamIds);

                request.setAttribute("competition", competition);
                request.setAttribute("hasJoined", hasJoined);
                request.setAttribute("userTeam", userTeam);
                request.getRequestDispatcher("/jsp/competition_detail.jsp").forward(request, response);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/competition?action=list");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/competition?action=list");
        }
    }

    /**
     * 显示编辑页面
     */
    private void showEditPage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                Integer id = Integer.parseInt(idStr);
                Competition competition = competitionService.getCompetitionById(id);
                List<CompetitionCategory> categories = categoryDAO.findByCompetitionId(id);
                request.setAttribute("competition", competition);
                request.setAttribute("categories", categories);
                request.getRequestDispatcher("/jsp/competition_edit.jsp").forward(request, response);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/competition?action=list");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/competition?action=list");
        }
    }

    /**
     * 创建竞赛
     */
    private void createCompetition(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Competition competition = extractCompetitionFromRequest(request);

            // 获取当前登录用户ID
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                com.poster.model.User user = (com.poster.model.User) session.getAttribute("user");
                competition.setCreatorId(user.getUserId());
            }

            boolean success = competitionService.createCompetition(competition);

            if (success) {
                // 保存竞赛子类
                saveCategories(request, competition.getCompetitionId());
                response.sendRedirect(request.getContextPath() + "/competition?action=list");
            } else {
                request.setAttribute("error", "创建竞赛失败");
                request.getRequestDispatcher("/jsp/competition_add.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "创建竞赛时发生错误: " + e.getMessage());
            request.getRequestDispatcher("/jsp/competition_add.jsp").forward(request, response);
        }
    }

    /**
     * 更新竞赛
     */
    private void updateCompetition(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            Competition competition = extractCompetitionFromRequest(request);

            String idStr = request.getParameter("competitionId");
            if (idStr != null) {
                competition.setCompetitionId(Integer.parseInt(idStr));
            }

            boolean success = competitionService.updateCompetition(competition);

            if (success) {
                // 处理删除的子类
                String[] deleteIds = request.getParameterValues("deleteCategoryIds");
                if (deleteIds != null) {
                    for (String deleteId : deleteIds) {
                        try {
                            categoryDAO.deleteById(Integer.parseInt(deleteId));
                        } catch (NumberFormatException ignored) {}
                    }
                }
                // 保存新增的子类
                saveCategories(request, competition.getCompetitionId());
                response.sendRedirect(request.getContextPath() + "/competition?action=detail&id=" + competition.getCompetitionId());
            } else {
                request.setAttribute("error", "更新竞赛失败");
                request.setAttribute("competition", competition);
                List<CompetitionCategory> categories = categoryDAO.findByCompetitionId(competition.getCompetitionId());
                request.setAttribute("categories", categories);
                request.getRequestDispatcher("/jsp/competition_edit.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "更新竞赛时发生错误: " + e.getMessage());
            request.getRequestDispatcher("/jsp/competition_edit.jsp").forward(request, response);
        }
    }

    /**
     * 删除竞赛
     */
    private void deleteCompetition(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                Integer id = Integer.parseInt(idStr);
                boolean success = competitionService.deleteCompetition(id);

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/competition?action=list");
                } else {
                    response.sendRedirect(request.getContextPath() + "/competition?action=detail&id=" + id + "&error=delete_failed");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/competition?action=list");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/competition?action=list");
        }
    }

    /**
     * 取消竞赛
     */
    private void cancelCompetition(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                Integer id = Integer.parseInt(idStr);
                boolean success = competitionService.cancelCompetition(id);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/competition?action=detail&id=" + id);
                } else {
                    response.sendRedirect(request.getContextPath() + "/competition?action=detail&id=" + id + "&error=cancel_failed");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/competition?action=list");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/competition?action=list");
        }
    }

    /**
     * 保存竞赛子类（从请求中提取并批量插入）
     */
    private void saveCategories(HttpServletRequest request, Integer competitionId) {
        String[] names = request.getParameterValues("categoryName");
        String[] descs = request.getParameterValues("categoryDesc");

        if (names != null && competitionId != null) {
            for (int i = 0; i < names.length; i++) {
                String name = names[i].trim();
                if (!name.isEmpty()) {
                    CompetitionCategory cat = new CompetitionCategory();
                    cat.setCompetitionId(competitionId);
                    cat.setCategoryName(name);
                    if (descs != null && i < descs.length && descs[i] != null) {
                        cat.setCategoryDesc(descs[i].trim());
                    }
                    categoryDAO.insert(cat);
                }
            }
        }
    }

    /**
     * 从请求中提取竞赛对象
     */
    private Competition extractCompetitionFromRequest(HttpServletRequest request) throws Exception {
        Competition competition = new Competition();

        competition.setYear(Integer.parseInt(request.getParameter("year")));
        competition.setName(request.getParameter("name"));
        competition.setTheme(request.getParameter("theme"));
        competition.setDescription(request.getParameter("description"));

        // 处理截止日期
        String deadlineStr = request.getParameter("submitDeadline");
        if (deadlineStr != null && !deadlineStr.isEmpty()) {
            competition.setSubmitDeadline(java.time.LocalDateTime.parse(deadlineStr));
        }

        competition.setMaxTeamSize(Integer.parseInt(request.getParameter("maxTeamSize")));

        String statusStr = request.getParameter("status");
        if (statusStr != null && !statusStr.isEmpty()) {
            competition.setStatus(Integer.parseInt(statusStr));
        }

        return competition;
    }
}
