package com.poster.controller;

import com.poster.dao.CompetitionDAO;
import com.poster.dao.WorkDAO;
import com.poster.dao.impl.CompetitionDAOImpl;
import com.poster.dao.impl.WorkDAOImpl;
import com.poster.model.Comment;
import com.poster.model.Competition;
import com.poster.model.Role;
import com.poster.model.Score;
import com.poster.model.User;
import com.poster.model.Work;
import com.poster.service.CommentService;
import com.poster.service.ScoreService;
import com.poster.service.TeamService;
import com.poster.service.impl.CommentServiceImpl;
import com.poster.service.impl.ScoreServiceImpl;
import com.poster.service.impl.TeamServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

/**
 * 评分Servlet
 * @author 队员C
 * @date 2026-07-07
 */
@WebServlet("/score")
public class ScoreServlet extends HttpServlet {

    private ScoreService scoreService = new ScoreServiceImpl();
    private CommentService commentService = new CommentServiceImpl();
    private WorkDAO workDAO = new WorkDAOImpl();
    private CompetitionDAO competitionDAO = new CompetitionDAOImpl();
    private TeamService teamService = new TeamServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isJudge(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "仅评委可访问评分功能");
            return;
        }

        String action = request.getParameter("action");

        if (action == null || "list".equals(action)) {
            // 评分工作台 - 展示待评作品列表
            showScoringWorkspace(request, response);
        } else if ("input".equals(action)) {
            // 评分输入页 - 对指定作品进行评分
            showScoreInput(request, response);
        } else if ("myScores".equals(action)) {
            // 我的评分记录
            showMyScores(request, response);
        } else if ("workScores".equals(action)) {
            // 查看某作品的所有评分
            showWorkScores(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isJudge(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "仅评委可提交评分");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("submit".equals(action)) {
            // 提交评分
            submitScore(request, response);
        } else if ("update".equals(action)) {
            // 更新评分
            updateScore(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }

    /**
     * 评分工作台 - 展示所有待评作品
     */
    private void showScoringWorkspace(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Competition> competitions = competitionDAO.findAll();
        request.setAttribute("competitions", competitions);

        Integer selectedCompetitionId = parseInteger(request.getParameter("competitionId"));
        if (selectedCompetitionId == null && competitions != null && !competitions.isEmpty()) {
            selectedCompetitionId = competitions.get(0).getCompetitionId();
        }
        request.setAttribute("selectedCompetitionId", selectedCompetitionId);

        // 评分必须按竞赛查看，避免所有比赛作品混在一起。
        List<Work> sourceWorks = selectedCompetitionId != null
                ? workDAO.findByCompetitionId(selectedCompetitionId)
                : java.util.Collections.emptyList();
        List<Work> submittedWorks = new java.util.ArrayList<>();
        for (Work w : sourceWorks) {
            if (w.getStatus() != null && w.getStatus() == 2) {
                submittedWorks.add(w);
            }
        }
        request.setAttribute("works", submittedWorks);

        // 获取当前评委的评分记录，用于标记已评分的作品
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            List<Score> allMyScores = scoreService.getScoresByJudgeId(user.getUserId());
            List<Score> myScores = new java.util.ArrayList<>();
            if (allMyScores != null) {
                for (Score score : allMyScores) {
                    for (Work work : submittedWorks) {
                        if (score.getWorkId() != null && score.getWorkId().equals(work.getWorkId())) {
                            myScores.add(score);
                            break;
                        }
                    }
                }
            }
            request.setAttribute("myScores", myScores);
        }

        request.getRequestDispatcher("/jsp/score_input.jsp").forward(request, response);
    }

    /**
     * 评分输入页 - 对指定作品评分
     */
    private void showScoreInput(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String workIdStr = request.getParameter("workId");
        if (workIdStr == null || workIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
            return;
        }

        try {
            Integer workId = Integer.parseInt(workIdStr);
            Work work = workDAO.findById(workId);
            Integer competitionId = parseInteger(request.getParameter("competitionId"));
            if (work == null || work.getStatus() == null || work.getStatus() != 2) {
                response.sendRedirect(request.getContextPath() + "/score?action=list" + competitionQuery(competitionId));
                return;
            }
            if (competitionId != null && !competitionId.equals(work.getCompetitionId())) {
                response.sendRedirect(request.getContextPath() + "/score?action=list&competitionId=" + competitionId);
                return;
            }
            if (competitionId == null) {
                competitionId = work.getCompetitionId();
            }

            request.setAttribute("selectedCompetitionId", competitionId);
            request.setAttribute("competitions", competitionDAO.findAll());
            request.setAttribute("work", work);
            request.setAttribute("team", teamService.getTeamById(work.getTeamId()));

            // 加载该作品的所有评语
            List<Comment> comments = commentService.getCommentsByWorkId(workId);
            request.setAttribute("comments", comments);

            // 检查当前评委是否已评分
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                User user = (User) session.getAttribute("user");
                boolean hasScored = scoreService.hasScored(workId, user.getUserId());
                request.setAttribute("hasScored", hasScored);

                if (hasScored) {
                    // 获取已有评分信息用于显示
                    List<Score> scores = scoreService.getScoresByWorkId(workId);
                    for (Score s : scores) {
                        if (s.getJudgeId().equals(user.getUserId())) {
                            request.setAttribute("existingScore", s);
                            break;
                        }
                    }
                }
            }

            request.getRequestDispatcher("/jsp/score_input.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }

    /**
     * 我的评分记录
     */
    private void showMyScores(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        List<Competition> competitions = competitionDAO.findAll();
        Integer selectedCompetitionId = parseInteger(request.getParameter("competitionId"));
        if (selectedCompetitionId == null && competitions != null && !competitions.isEmpty()) {
            selectedCompetitionId = competitions.get(0).getCompetitionId();
        }
        List<Score> allMyScores = scoreService.getScoresByJudgeId(user.getUserId());
        List<Score> myScores = new java.util.ArrayList<>();
        if (allMyScores != null) {
            for (Score score : allMyScores) {
                Work work = workDAO.findById(score.getWorkId());
                if (selectedCompetitionId == null || (work != null && selectedCompetitionId.equals(work.getCompetitionId()))) {
                    myScores.add(score);
                }
            }
        }

        request.setAttribute("competitions", competitions);
        request.setAttribute("selectedCompetitionId", selectedCompetitionId);
        // 加载每个评分对应的作品和队伍信息
        request.setAttribute("myScores", myScores);
        request.setAttribute("workDAO", workDAO);
        request.setAttribute("teamService", teamService);

        request.getRequestDispatcher("/jsp/score_list.jsp").forward(request, response);
    }

    /**
     * 查看某作品的所有评分
     */
    private void showWorkScores(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String workIdStr = request.getParameter("workId");
        if (workIdStr == null || workIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
            return;
        }

        try {
            Integer workId = Integer.parseInt(workIdStr);
            Work work = workDAO.findById(workId);
            if (work == null) {
                response.sendRedirect(request.getContextPath() + "/score?action=list");
                return;
            }

            List<Score> scores = scoreService.getScoresByWorkId(workId);
            Double avgScore = scoreService.getAverageScore(workId);

            request.setAttribute("work", work);
            request.setAttribute("team", teamService.getTeamById(work.getTeamId()));
            request.setAttribute("scores", scores);
            request.setAttribute("avgScore", avgScore);

            request.getRequestDispatcher("/jsp/score_list.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }

    /**
     * 提交评分
     */
    private void submitScore(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            Integer workId = Integer.parseInt(request.getParameter("workId"));
            Integer competitionId = parseInteger(request.getParameter("competitionId"));
            Double scoreValue = Double.parseDouble(request.getParameter("score"));
            Work work = workDAO.findById(workId);
            if (work == null || work.getStatus() == null || work.getStatus() != 2
                    || (competitionId != null && !competitionId.equals(work.getCompetitionId()))
                    || !isCompetitionRunning(work)) {
                response.sendRedirect(request.getContextPath() + "/score?action=list" + competitionQuery(competitionId));
                return;
            }
            if (competitionId == null) {
                competitionId = work.getCompetitionId();
            }

            Score score = new Score();
            score.setWorkId(workId);
            score.setJudgeId(user.getUserId());
            score.setScore(scoreValue);

            boolean success = scoreService.addScore(score);

            if (success) {
                request.getSession().setAttribute("message", "评分提交成功！");
                response.sendRedirect(request.getContextPath() + "/score?action=list&competitionId=" + competitionId);
            } else {
                request.setAttribute("error", "评分提交失败，请检查分数范围（0-100）或是否已评分");
                request.setAttribute("selectedCompetitionId", competitionId);
                request.setAttribute("competitions", competitionDAO.findAll());
                request.setAttribute("work", work);
                request.setAttribute("team", teamService.getTeamById(work.getTeamId()));
                request.getRequestDispatcher("/jsp/score_input.jsp").forward(request, response);
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "请输入有效的分数");
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }

    /**
     * 更新评分
     */
    private void updateScore(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            Integer scoreId = Integer.parseInt(request.getParameter("scoreId"));
            Integer competitionId = parseInteger(request.getParameter("competitionId"));
            Double scoreValue = Double.parseDouble(request.getParameter("score"));
            User user = (User) session.getAttribute("user");
            Score existing = scoreService.getScoreById(scoreId);
            if (existing == null || !user.getUserId().equals(existing.getJudgeId())) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "只能修改自己的评分");
                return;
            }
            Work work = workDAO.findById(existing.getWorkId());
            if (!isCompetitionRunning(work)) {
                response.sendRedirect(request.getContextPath() + "/score?action=list" + competitionQuery(competitionId));
                return;
            }

            Score score = new Score();
            score.setScoreId(scoreId);
            score.setScore(scoreValue);

            boolean success = scoreService.updateScore(score, user.getUserId());

            if (success) {
                request.getSession().setAttribute("message", "评分更新成功！");
                response.sendRedirect(request.getContextPath() + "/score?action=list" + competitionQuery(competitionId));
            } else {
                request.setAttribute("error", "评分更新失败，请检查分数范围（0-100）");
                response.sendRedirect(request.getContextPath() + "/score?action=list");
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "请输入有效的分数");
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }

    private Integer parseInteger(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String competitionQuery(Integer competitionId) {
        return competitionId == null ? "" : "&competitionId=" + competitionId;
    }

    private boolean isCompetitionRunning(Work work) {
        if (work == null || work.getCompetitionId() == null) return false;
        Competition competition = competitionDAO.findById(work.getCompetitionId());
        return competition != null && competition.getStatus() != null && competition.getStatus() == 2;
    }

    private boolean isJudge(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) return false;
        @SuppressWarnings("unchecked")
        List<Role> roles = (List<Role>) session.getAttribute("roles");
        if (roles == null) return false;
        for (Role role : roles) {
            if ("评委".equals(role.getRoleName())) return true;
        }
        return false;
    }
}
