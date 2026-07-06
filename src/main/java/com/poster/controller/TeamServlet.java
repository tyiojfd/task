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
import com.poster.service.WorkService;
import com.poster.service.impl.WorkServiceImpl;
import com.poster.model.Work;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

/**
 * 闃熶紞Servlet
 * @author 鏉ㄧゥ鍗?
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
            // 鍔犺浇绔炶禌鍒楄〃鍜屽瓙绫诲垪琛ㄤ緵閫夋嫨
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
     * 鏄剧ず"鎴戠殑闃熶紞"鍒楄〃锛堝甫绔炶禌鍚嶅拰鎴愬憳鏁帮級
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

        // 涓烘瘡涓槦浼嶅姞杞界珵璧涘悕绉板拰鎴愬憳鏁伴噺
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

        // 鍔犺浇鎴愬憳鐢ㄦ埛鍚嶆槧灏?
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
     * 鏄剧ず闃熶紞璇︽儏锛堝惈鎴愬憳銆佺珵璧涖€佸瓙绫讳俊鎭級
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

            // 鍔犺浇绔炶禌鍚嶇О
            Competition competition = competitionService.getCompetitionById(team.getCompetitionId());
            String competitionName = competition != null ? competition.getName() : "鏈煡绔炶禌";

            // 鍔犺浇瀛愮被鍚嶇О
            CompetitionCategory category = categoryDAO.findById(team.getCategoryId());
            String categoryName = category != null ? category.getCategoryName() : "鏈煡瀛愮被";

            // 鍔犺浇闃熼暱淇℃伅
            User leader = userDAO.findById(team.getLeaderId());
            String leaderName = leader != null ? leader.getRealName() : "鏈煡";

            // 鍔犺浇闃熶紞鎴愬憳
            List<TeamMember> members = teamMemberDAO.findByTeamId(teamId);

            // 鍔犺浇鎴愬憳鐢ㄦ埛淇℃伅
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
     * 鍒涘缓闃熶紞
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
            request.setAttribute("error", "鍒涘缓闃熶紞鏃跺彂鐢熼敊璇? " + e.getMessage());
            List<Competition> competitions = competitionService.getAllCompetitions();
            List<CompetitionCategory> categories = categoryDAO.findAll();
            request.setAttribute("competitions", competitions);
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/jsp/team_create.jsp").forward(request, response);
        }
    }

    /**
     * 鏇存柊闃熶紞淇℃伅
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
                request.setAttribute("error", "鏇存柊闃熶紞淇℃伅澶辫触");
                request.setAttribute("team", team);
                request.getRequestDispatcher("/jsp/team_detail.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "鏇存柊闃熶紞鏃跺彂鐢熼敊璇? " + e.getMessage());
            request.getRequestDispatcher("/jsp/team_detail.jsp").forward(request, response);
        }
    }

    /**
     * 瑙ｆ暎闃熶紞
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
     * 閭€璇烽槦鍛?
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
     * 绉婚櫎闃熷憳
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
     * 浠庤姹備腑鎻愬彇Team瀵硅薄
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
