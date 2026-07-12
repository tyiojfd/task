package com.poster.controller;

import com.poster.dao.CompetitionDAO;
import com.poster.dao.WorkDAO;
import com.poster.dao.impl.CompetitionDAOImpl;
import com.poster.dao.impl.WorkDAOImpl;
import com.poster.model.Award;
import com.poster.model.Role;
import com.poster.model.User;
import com.poster.model.Work;
import com.poster.service.AwardService;
import com.poster.service.CertificateService;
import com.poster.service.ScoreService;
import com.poster.service.TeamService;
import com.poster.service.impl.AwardServiceImpl;
import com.poster.service.impl.CertificateServiceImpl;
import com.poster.service.impl.ScoreServiceImpl;
import com.poster.service.impl.TeamServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.*;

/**
 * 获奖Servlet
 * @author 队员C
 * @date 2026-07-08
 */
@WebServlet("/award")
public class AwardServlet extends HttpServlet {

    private AwardService awardService = new AwardServiceImpl();
    private CertificateService certificateService = new CertificateServiceImpl();
    private WorkDAO workDAO = new WorkDAOImpl();
    private CompetitionDAO competitionDAO = new CompetitionDAOImpl();
    private TeamService teamService = new TeamServiceImpl();
    private ScoreService scoreService = new ScoreServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null || "list".equals(action)) {
            // 获奖列表（公开查看）
            showAwardList(request, response);
        } else if ("manage".equals(action)) {
            // 获奖管理（管理员功能）
            showAwardManage(request, response);
        } else if ("detail".equals(action)) {
            // 获奖详情
            showAwardDetail(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/award?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("set".equals(action)) {
            // 设置获奖
            setAward(request, response);
        } else if ("delete".equals(action)) {
            // 删除获奖
            deleteAward(request, response);
        } else if ("publishAnnouncement".equals(action)) {
            // 发布获奖公告
            publishAnnouncement(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/award?action=manage");
        }
    }

    /**
     * 获奖列表（公开查看）
     */
    private void showAwardList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String competitionIdStr = request.getParameter("competitionId");
        List<Award> awards;

        if (competitionIdStr != null && !competitionIdStr.isEmpty()) {
            try {
                Integer competitionId = Integer.parseInt(competitionIdStr);
                awards = awardService.getAwardsByCompetitionId(competitionId);
                request.setAttribute("competition", competitionDAO.findById(competitionId));
            } catch (NumberFormatException e) {
                awards = Collections.emptyList();
            }
        } else {
            // 顶部导航进入获奖名单时展示全站获奖记录，而不是误报“暂无获奖信息”。
            awards = new com.poster.dao.impl.AwardDAOImpl().findAll();
        }

        // 加载每个获奖作品的信息
        Map<Integer, Work> workMap = new HashMap<>();
        Map<Integer, String> teamNameMap = new HashMap<>();
        Map<Integer, Double> avgScoreMap = new HashMap<>();

        for (Award award : awards) {
            Work work = workDAO.findById(award.getWorkId());
            if (work != null) {
                workMap.put(award.getWorkId(), work);
                teamNameMap.put(award.getWorkId(),
                        teamService.getTeamById(work.getTeamId()) != null
                                ? teamService.getTeamById(work.getTeamId()).getTeamName()
                                : "未知队伍");
                Double avg = scoreService.getAverageScore(award.getWorkId());
                avgScoreMap.put(award.getWorkId(), avg != null ? avg : 0.0);
            }
        }

        request.setAttribute("awards", awards);
        request.setAttribute("workMap", workMap);
        request.setAttribute("teamNameMap", teamNameMap);
        request.setAttribute("avgScoreMap", avgScoreMap);
        request.getRequestDispatcher("/jsp/award_list.jsp").forward(request, response);
    }

    /**
     * 获奖管理（管理员功能）
     */
    private void showAwardManage(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 检查管理员权限
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        String competitionIdStr = request.getParameter("competitionId");

        if (competitionIdStr != null && !competitionIdStr.isEmpty()) {
            try {
                Integer competitionId = Integer.parseInt(competitionIdStr);
                // 加载该竞赛下所有已提交的作品
                List<Work> allWorks = workDAO.findAll();
                List<Work> competitionWorks = new ArrayList<>();
                for (Work w : allWorks) {
                    if (w.getCompetitionId() != null && w.getCompetitionId().equals(competitionId)
                            && w.getStatus() != null && w.getStatus() == 2) {
                        competitionWorks.add(w);
                    }
                }

                // 加载已有获奖记录
                List<Award> existingAwards = awardService.getAwardsByCompetitionId(competitionId);
                Set<Integer> awardedWorkIds = new HashSet<>();
                for (Award a : existingAwards) {
                    awardedWorkIds.add(a.getWorkId());
                }

                // 加载每个作品的平均分和队伍名
                Map<Integer, Double> avgScoreMap = new HashMap<>();
                Map<Integer, String> teamNameMap = new HashMap<>();
                for (Work w : competitionWorks) {
                    Double avg = scoreService.getAverageScore(w.getWorkId());
                    avgScoreMap.put(w.getWorkId(), avg != null ? avg : 0.0);
                    teamNameMap.put(w.getWorkId(),
                            teamService.getTeamById(w.getTeamId()) != null
                                    ? teamService.getTeamById(w.getTeamId()).getTeamName()
                                    : "未知队伍");
                }

                request.setAttribute("competition", competitionDAO.findById(competitionId));
                request.setAttribute("works", competitionWorks);
                request.setAttribute("existingAwards", existingAwards);
                request.setAttribute("awardedWorkIds", awardedWorkIds);
                request.setAttribute("avgScoreMap", avgScoreMap);
                request.setAttribute("teamNameMap", teamNameMap);
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        // 加载所有竞赛列表供选择
        request.setAttribute("competitions", competitionDAO.findAll());

        request.getRequestDispatcher("/jsp/award_manage.jsp").forward(request, response);
    }

    /**
     * 获奖详情
     */
    private void showAwardDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String workIdStr = request.getParameter("workId");
        if (workIdStr == null || workIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/award?action=list");
            return;
        }

        try {
            Integer workId = Integer.parseInt(workIdStr);
            Award award = awardService.getAwardByWorkId(workId);
            if (award == null) {
                response.sendRedirect(request.getContextPath() + "/award?action=list");
                return;
            }

            Work work = workDAO.findById(workId);
            request.setAttribute("award", award);
            request.setAttribute("work", work);
            request.setAttribute("team", teamService.getTeamById(work != null ? work.getTeamId() : null));
            request.setAttribute("competition",
                    competitionDAO.findById(award.getCompetitionId()));

            // 查询奖状信息
            request.setAttribute("certificate",
                    certificateService.getCertificateByAwardId(award.getAwardId()));

            request.getRequestDispatcher("/jsp/award_detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/award?action=list");
        }
    }

    /**
     * 检查当前用户是否为管理员
     */
    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        @SuppressWarnings("unchecked")
        List<Role> roles = (List<Role>) session.getAttribute("roles");
        if (roles != null) {
            for (Role role : roles) {
                if ("管理员".equals(role.getRoleName())) return true;
            }
        }
        return false;
    }

    /**
     * 设置获奖（管理员操作）
     */
    private void setAward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            Integer competitionId = Integer.parseInt(request.getParameter("competitionId"));
            Integer workId = Integer.parseInt(request.getParameter("workId"));
            String awardLevel = request.getParameter("awardLevel");
            Double finalScore = Double.parseDouble(request.getParameter("finalScore"));

            Award award = new Award();
            award.setCompetitionId(competitionId);
            award.setWorkId(workId);
            award.setAwardLevel(awardLevel);
            award.setFinalScore(finalScore);
            award.setIssuerId(user.getUserId());

            boolean success = awardService.setAward(award);

            if (success) {
                request.getSession().setAttribute("message", "获奖设置成功！奖状已自动生成。");
            } else {
                request.getSession().setAttribute("error",
                        "获奖设置失败：请确认获奖等级正确、最终得分在0-100之间、作品已提交且属于当前竞赛，并且该作品尚未获奖");
            }
            response.sendRedirect(request.getContextPath()
                    + "/award?action=manage&competitionId=" + competitionId);
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "请输入有效的数据");
            response.sendRedirect(request.getContextPath() + "/award?action=manage");
        }
    }

    /**
     * 删除获奖记录（管理员操作）
     */
    private void deleteAward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        try {
            Integer awardId = Integer.parseInt(request.getParameter("awardId"));
            String competitionIdStr = request.getParameter("competitionId");

            // 通过AwardDAO删除
            com.poster.dao.AwardDAO awardDAO = new com.poster.dao.impl.AwardDAOImpl();
            int result = awardDAO.deleteById(awardId);

            if (result > 0) {
                request.getSession().setAttribute("message", "获奖记录已删除");
            } else {
                request.getSession().setAttribute("error", "删除失败");
            }

            if (competitionIdStr != null && !competitionIdStr.isEmpty()) {
                response.sendRedirect(request.getContextPath()
                        + "/award?action=manage&competitionId=" + competitionIdStr);
            } else {
                response.sendRedirect(request.getContextPath() + "/award?action=manage");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/award?action=manage");
        }
    }

    /**
     * 发布获奖公告（管理员操作）
     */
    private void publishAnnouncement(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        try {
            Integer competitionId = Integer.parseInt(request.getParameter("competitionId"));

            boolean success = awardService.publishAwardAnnouncement(competitionId);

            if (success) {
                request.getSession().setAttribute("message", "获奖公告发布成功！");
            } else {
                request.getSession().setAttribute("error", "获奖公告发布失败，请先设置获奖");
            }
            response.sendRedirect(request.getContextPath()
                    + "/award?action=manage&competitionId=" + competitionId);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/award?action=manage");
        }
    }
}
