package com.poster.controller;

import com.poster.dao.TeamDAO;
import com.poster.dao.UserDAO;
import com.poster.dao.impl.TeamDAOImpl;
import com.poster.dao.impl.UserDAOImpl;
import com.poster.model.Team;
import com.poster.model.TeamApplication;
import com.poster.model.User;
import com.poster.service.TeamApplicationService;
import com.poster.service.impl.TeamApplicationServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 入队申请Servlet
 * @author Claude
 * @date 2026-07-12
 */
@WebServlet("/application")
public class TeamApplicationServlet extends HttpServlet {
    private TeamApplicationService applicationService = new TeamApplicationServiceImpl();
    private TeamDAO teamDAO = new TeamDAOImpl();
    private UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String action = request.getParameter("action");
        if ("teamApplications".equals(action)) {
            showTeamApplications(request, response);
        } else {
            showMyApplications(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String action = request.getParameter("action");
        if ("apply".equals(action)) {
            apply(request, response);
        } else if ("approve".equals(action)) {
            approve(request, response);
        } else if ("reject".equals(action)) {
            reject(request, response);
        } else if ("cancel".equals(action)) {
            cancel(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/application?action=myApplications");
        }
    }

    private void showMyApplications(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession(false).getAttribute("user");
        List<TeamApplication> applications = applicationService.getApplicationsByApplicantId(user.getUserId());
        request.setAttribute("applications", applications);
        request.setAttribute("teamMap", buildTeamMap(applications));
        request.setAttribute("viewMode", "mine");
        request.getRequestDispatcher("/jsp/application_list.jsp").forward(request, response);
    }

    private void showTeamApplications(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession(false).getAttribute("user");
        Integer teamId = parseInt(request.getParameter("teamId"));
        if (teamId == null) {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams&error=invalid_team");
            return;
        }
        Team team = teamDAO.findById(teamId);
        if (team == null || !user.getUserId().equals(team.getLeaderId())) {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams&error=permission_denied");
            return;
        }
        List<TeamApplication> applications = applicationService.getApplicationsByTeamId(teamId);
        request.setAttribute("applications", applications);
        request.setAttribute("team", team);
        request.setAttribute("userMap", buildUserMap(applications));
        request.setAttribute("viewMode", "team");
        request.getRequestDispatcher("/jsp/application_list.jsp").forward(request, response);
    }

    private void apply(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = (User) request.getSession(false).getAttribute("user");
        Integer teamId = parseInt(request.getParameter("teamId"));
        if (teamId == null) {
            response.sendRedirect(request.getContextPath() + "/competition?action=list&error=invalid_team");
            return;
        }
        String message = request.getParameter("message");
        boolean success = applicationService.applyToTeam(teamId, user.getUserId(), message);
        Team team = teamDAO.findById(teamId);
        Integer competitionId = team != null ? team.getCompetitionId() : null;
        response.sendRedirect(request.getContextPath() + "/competition?action=detail&id=" + (competitionId != null ? competitionId : "") + (success ? "&msg=apply_success" : "&error=apply_failed"));
    }

    private void approve(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = (User) request.getSession(false).getAttribute("user");
        Integer applicationId = parseInt(request.getParameter("applicationId"));
        Integer teamId = parseInt(request.getParameter("teamId"));
        boolean success = applicationService.approveApplication(applicationId, user.getUserId());
        response.sendRedirect(request.getContextPath() + "/application?action=teamApplications&teamId=" + teamId + (success ? "&msg=approve_success" : "&error=approve_failed"));
    }

    private void reject(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = (User) request.getSession(false).getAttribute("user");
        Integer applicationId = parseInt(request.getParameter("applicationId"));
        Integer teamId = parseInt(request.getParameter("teamId"));
        boolean success = applicationService.rejectApplication(applicationId, user.getUserId());
        response.sendRedirect(request.getContextPath() + "/application?action=teamApplications&teamId=" + teamId + (success ? "&msg=reject_success" : "&error=reject_failed"));
    }

    private void cancel(HttpServletRequest request, HttpServletResponse response) throws IOException {
        User user = (User) request.getSession(false).getAttribute("user");
        Integer applicationId = parseInt(request.getParameter("applicationId"));
        boolean success = applicationService.cancelApplication(applicationId, user.getUserId());
        response.sendRedirect(request.getContextPath() + "/application?action=myApplications" + (success ? "&msg=cancel_success" : "&error=cancel_failed"));
    }

    private Integer parseInt(String value) {
        try {
            if (value == null) return null;
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : null;
        } catch (Exception e) {
            return null;
        }
    }

    private Map<Integer, Team> buildTeamMap(List<TeamApplication> applications) {
        Map<Integer, Team> map = new HashMap<>();
        if (applications != null) {
            for (TeamApplication application : applications) {
                if (application.getTeamId() != null && !map.containsKey(application.getTeamId())) {
                    Team team = teamDAO.findById(application.getTeamId());
                    if (team != null) map.put(application.getTeamId(), team);
                }
            }
        }
        return map;
    }

    private Map<Integer, User> buildUserMap(List<TeamApplication> applications) {
        Map<Integer, User> map = new HashMap<>();
        if (applications != null) {
            for (TeamApplication application : applications) {
                if (application.getApplicantId() != null && !map.containsKey(application.getApplicantId())) {
                    User user = userDAO.findById(application.getApplicantId());
                    if (user != null) map.put(application.getApplicantId(), user);
                }
            }
        }
        return map;
    }
}
