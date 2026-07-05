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
        } else {
            response.sendRedirect(request.getContextPath() + "/competition?action=list");
        }
    }

    /**
     * 显示竞赛列表
     */
    private void listCompetitions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Competition> competitions = competitionService.getAllCompetitions();
        request.setAttribute("competitions", competitions);
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
                Integer id = Integer.parseInt(idStr);
                Competition competition = competitionService.getCompetitionById(id);
                request.setAttribute("competition", competition);
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
                request.setAttribute("competition", competition);
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
                response.sendRedirect(request.getContextPath() + "/competition?action=detail&id=" + competition.getCompetitionId());
            } else {
                request.setAttribute("error", "更新竞赛失败");
                request.setAttribute("competition", competition);
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
