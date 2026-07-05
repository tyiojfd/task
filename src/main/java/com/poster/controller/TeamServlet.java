package com.poster.controller;

import com.poster.model.Team;
import com.poster.model.User;
import com.poster.model.Competition;
import com.poster.model.CompetitionCategory;
import com.poster.model.TeamMember;
import com.poster.dao.TeamMemberDAO;
import com.poster.dao.UserDAO;
import com.poster.dao.CategoryDAO;
import com.poster.dao.impl.TeamMemberDAOImpl;
import com.poster.dao.impl.UserDAOImpl;
import com.poster.dao.impl.CategoryDAOImpl;
import com.poster.service.TeamService;
import com.poster.service.CompetitionService;
import com.poster.service.impl.TeamServiceImpl;
import com.poster.service.impl.CompetitionServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

/**
 * 队伍Servlet
 * @author 杨祥博
 * @date 2026-07-05
 */
@WebServlet("/team")
public class TeamServlet extends HttpServlet {

    private TeamService teamService = new TeamServiceImpl();
    private CompetitionService competitionService = new CompetitionServiceImpl();
    private TeamMemberDAO teamMemberDAO = new TeamMemberDAOImpl();
    private UserDAO userDAO = new UserDAOImpl();
    private CategoryDAO categoryDAO = new CategoryDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            // 加载竞赛列表和子类列表供选择
            List<Competition> competitions = competitionService.getAllCompetitions();
            List<CompetitionCategory> categories = categoryDAO.findAll();
            request.setAttribute("competitions", competitions);
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/jsp/team_create.jsp").forward(request, response);
        } else if ("detail".equals(action)) {
            showTeamDetail(request, response);
        } else if ("myTeams".equals(action) || action == null || "list".equals(action)) {
            listMyTeams(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            createTeam(request, response);
        } else if ("update".equals(action)) {
            updateTeam(request, response);
        } else if ("delete".equals(action)) {
            deleteTeam(request, response);
        } else if ("invite".equals(action)) {
            inviteMember(request, response);
        } else if ("remove".equals(action)) {
            removeMember(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams");
        }
    }

    /**
     * 显示"我的队伍"列表（带竞赛名和成员数）
     */
    private void listMyTeams(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        List<Team> myTeams = teamService.getTeamsByLeaderId(user.getUserId());

        // 为每个队伍加载竞赛名称和成员数量
        Map<Integer, String> competitionNames = new HashMap<>();
        Map<Integer, Integer> memberCounts = new HashMap<>();
        Map<Integer, List<TeamMember>> teamMembers = new HashMap<>();

        for (Team team : myTeams) {
            Competition comp = competitionService.getCompetitionById(team.getCompetitionId());
            if (comp != null) {
                competitionNames.put(team.getTeamId(), comp.getName());
            }
            int count = teamMemberDAO.countByTeamId(team.getTeamId());
            memberCounts.put(team.getTeamId(), count);
            List<TeamMember> members = teamMemberDAO.findByTeamId(team.getTeamId());
            teamMembers.put(team.getTeamId(), members);
        }

        // 加载成员用户名映射
        Map<Integer, String> userNames = new HashMap<>();
        for (List<TeamMember> members : teamMembers.values()) {
            for (TeamMember member : members) {
                if (!userNames.containsKey(member.getUserId())) {
                    User memberUser = userDAO.findById(member.getUserId());
                    if (memberUser != null) {
                        userNames.put(memberUser.getUserId(), memberUser.getRealName());
                    }
                }
            }
        }

        request.setAttribute("myTeams", myTeams);
        request.setAttribute("competitionNames", competitionNames);
        request.setAttribute("memberCounts", memberCounts);
        request.setAttribute("teamMembers", teamMembers);
        request.setAttribute("userNames", userNames);
        request.getRequestDispatcher("/jsp/team_list.jsp").forward(request, response);
    }

    /**
     * 显示队伍详情（含成员、竞赛、子类信息）
     */
    private void showTeamDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams");
            return;
        }

        try {
            Integer teamId = Integer.parseInt(idStr);
            Team team = teamService.getTeamById(teamId);

            if (team == null) {
                response.sendRedirect(request.getContextPath() + "/team?action=myTeams");
                return;
            }

            // 加载竞赛名称
            Competition competition = competitionService.getCompetitionById(team.getCompetitionId());
            String competitionName = competition != null ? competition.getName() : "未知竞赛";

            // 加载子类名称
            CompetitionCategory category = categoryDAO.findById(team.getCategoryId());
            String categoryName = category != null ? category.getCategoryName() : "未知子类";

            // 加载队长信息
            User leader = userDAO.findById(team.getLeaderId());
            String leaderName = leader != null ? leader.getRealName() : "未知";

            // 加载队伍成员
            List<TeamMember> members = teamMemberDAO.findByTeamId(teamId);

            // 加载成员用户信息
            Map<Integer, User> memberUsers = new HashMap<>();
            for (TeamMember member : members) {
                User memberUser = userDAO.findById(member.getUserId());
                if (memberUser != null) {
                    memberUsers.put(member.getUserId(), memberUser);
                }
            }

            request.setAttribute("team", team);
            request.setAttribute("competitionName", competitionName);
            request.setAttribute("categoryName", categoryName);
            request.setAttribute("leaderName", leaderName);
            request.setAttribute("members", members);
            request.setAttribute("memberUsers", memberUsers);
            request.getRequestDispatcher("/jsp/team_detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams");
        }
    }

    /**
     * 创建队伍
     */
    private void createTeam(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            User user = (User) session.getAttribute("user");
            Team team = extractTeamFromRequest(request);

            boolean success = teamService.createTeam(team, user.getUserId());

            if (success) {
                response.sendRedirect(request.getContextPath() + "/team?action=myTeams");
            } else {
                request.setAttribute("error", "创建队伍失败，请检查队伍名称是否填写完整");
                List<Competition> competitions = competitionService.getAllCompetitions();
                List<CompetitionCategory> categories = categoryDAO.findAll();
                request.setAttribute("competitions", competitions);
                request.setAttribute("categories", categories);
                request.getRequestDispatcher("/jsp/team_create.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "创建队伍时发生错误: " + e.getMessage());
            List<Competition> competitions = competitionService.getAllCompetitions();
            List<CompetitionCategory> categories = categoryDAO.findAll();
            request.setAttribute("competitions", competitions);
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/jsp/team_create.jsp").forward(request, response);
        }
    }

    /**
     * 更新队伍信息
     */
    private void updateTeam(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            Team team = extractTeamFromRequest(request);
            String idStr = request.getParameter("teamId");
            if (idStr != null) {
                team.setTeamId(Integer.parseInt(idStr));
            }

            boolean success = teamService.updateTeam(team);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/team?action=detail&id=" + team.getTeamId());
            } else {
                request.setAttribute("error", "更新队伍信息失败");
                request.setAttribute("team", team);
                request.getRequestDispatcher("/jsp/team_detail.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "更新队伍时发生错误: " + e.getMessage());
            request.getRequestDispatcher("/jsp/team_detail.jsp").forward(request, response);
        }
    }

    /**
     * 解散队伍
     */
    private void deleteTeam(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String idStr = request.getParameter("id");

        if (idStr != null) {
            try {
                Integer teamId = Integer.parseInt(idStr);
                boolean success = teamService.deleteTeam(teamId, user.getUserId());

                if (success) {
                    response.sendRedirect(request.getContextPath() + "/team?action=myTeams");
                } else {
                    response.sendRedirect(request.getContextPath() + "/team?action=detail&id=" + teamId + "&error=delete_failed");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/team?action=myTeams");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams");
        }
    }

    /**
     * 邀请队员
     */
    private void inviteMember(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            Integer teamId = Integer.parseInt(request.getParameter("teamId"));
            Integer inviteeId = Integer.parseInt(request.getParameter("inviteeId"));

            boolean success = teamService.inviteMember(teamId, user.getUserId(), inviteeId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/team?action=detail&id=" + teamId + "&msg=invite_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/team?action=detail&id=" + teamId + "&error=invite_failed");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams&error=invite_error");
        }
    }

    /**
     * 移除队员
     */
    private void removeMember(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            Integer teamId = Integer.parseInt(request.getParameter("teamId"));
            Integer memberId = Integer.parseInt(request.getParameter("memberId"));

            boolean success = teamService.removeMember(teamId, user.getUserId(), memberId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/team?action=detail&id=" + teamId + "&msg=remove_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/team?action=detail&id=" + teamId + "&error=remove_failed");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams&error=remove_error");
        }
    }

    /**
     * 从请求中提取Team对象
     */
    private Team extractTeamFromRequest(HttpServletRequest request) throws Exception {
        Team team = new Team();

        String teamName = request.getParameter("teamName");
        if (teamName != null) {
            team.setTeamName(teamName.trim());
        }

        String competitionIdStr = request.getParameter("competitionId");
        if (competitionIdStr != null && !competitionIdStr.isEmpty()) {
            team.setCompetitionId(Integer.parseInt(competitionIdStr));
        }

        String categoryIdStr = request.getParameter("categoryId");
        if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            team.setCategoryId(Integer.parseInt(categoryIdStr));
        }

        String teamDesc = request.getParameter("teamDesc");
        if (teamDesc != null) {
            team.setTeamDesc(teamDesc.trim());
        }

        return team;
    }
}
