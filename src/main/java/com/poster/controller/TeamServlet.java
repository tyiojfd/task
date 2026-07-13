package com.poster.controller;

import com.poster.model.Team;
import com.poster.model.User;
import com.poster.model.Competition;
import com.poster.model.CompetitionCategory;
import com.poster.model.TeamMember;
import com.poster.dao.TeamMemberDAO;
import com.poster.dao.UserDAO;
import com.poster.dao.CategoryDAO;
import com.poster.dao.WorkLikeDAO;
import com.poster.dao.impl.TeamMemberDAOImpl;
import com.poster.dao.impl.UserDAOImpl;
import com.poster.dao.impl.CategoryDAOImpl;
import com.poster.dao.impl.WorkLikeDAOImpl;
import com.poster.service.TeamService;
import com.poster.service.CompetitionService;
import com.poster.service.impl.TeamServiceImpl;
import com.poster.service.impl.CompetitionServiceImpl;
import com.poster.service.WorkService;
import com.poster.service.TeamApplicationService;
import com.poster.service.impl.WorkServiceImpl;
import com.poster.service.impl.TeamApplicationServiceImpl;
import com.poster.model.Work;
import com.poster.model.TeamApplication;

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
    private WorkService workService = new WorkServiceImpl();
    private TeamApplicationService applicationService = new TeamApplicationServiceImpl();
    private TeamMemberDAO teamMemberDAO = new TeamMemberDAOImpl();
    private UserDAO userDAO = new UserDAOImpl();
    private CategoryDAO categoryDAO = new CategoryDAOImpl();
    private WorkLikeDAO workLikeDAO = new WorkLikeDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            // 只加载报名中的竞赛供创建队伍
            List<Competition> allCompetitions = competitionService.getAllCompetitions();
            List<Competition> competitions = new ArrayList<>();
            if (allCompetitions != null) {
                for (Competition competition : allCompetitions) {
                    if (competition.getStatus() != null && competition.getStatus() == 1) {
                        competitions.add(competition);
                    }
                }
            }
            List<CompetitionCategory> categories = categoryDAO.findAll();
            request.setAttribute("competitions", competitions);
            request.setAttribute("categories", categories);
            request.setAttribute("selectedCompetitionId", request.getParameter("competitionId"));
            request.getRequestDispatcher("/jsp/team_create.jsp").forward(request, response);
        } else if ("detail".equals(action)) {
            showTeamDetail(request, response);
        } else if ("searchTeam".equals(action)) {
            searchTeamForJoin(request, response);
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
        } else if ("register".equals(action)) {
            registerCompetition(request, response);
        } else if ("cancel".equals(action)) {
            cancelRegistration(request, response);
        } else if ("searchUser".equals(action)) {
            searchUserForInvite(request, response);
        } else if ("searchTeam".equals(action)) {
            searchTeamForJoin(request, response);
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

        // 获取我创建的队伍（我是队长）
        List<Team> myTeams = teamService.getTeamsByLeaderId(user.getUserId());
        if (myTeams == null) {
            myTeams = new ArrayList<>();
        }

        // 获取我作为队员加入的队伍（通过邀请接受后加入的）
        List<TeamMember> myMemberships = teamMemberDAO.findByUserId(user.getUserId());
        if (myMemberships != null) {
            for (TeamMember tm : myMemberships) {
                // 只处理队员角色（队长已在上面获取）
                if (tm.getRole() != null && tm.getRole() == 2) {
                    Team joinedTeam = teamService.getTeamById(tm.getTeamId());
                    if (joinedTeam != null && joinedTeam.getStatus() != null && joinedTeam.getStatus() != 0) {
                        // 避免重复（如果用户同时是该队的队长和队员记录）
                        boolean alreadyInList = false;
                        for (Team t : myTeams) {
                            if (t.getTeamId().equals(joinedTeam.getTeamId())) {
                                alreadyInList = true;
                                break;
                            }
                        }
                        if (!alreadyInList) {
                            myTeams.add(joinedTeam);
                        }
                    }
                }
            }
        }

        // 涓烘瘡涓槦浼嶅姞杞界珵璧涘悕绉板拰鎴愬憳鏁伴噺
        Map<Integer, String> competitionNames = new HashMap<>();
        Map<Integer, Integer> memberCounts = new HashMap<>();
        Map<Integer, List<TeamMember>> teamMembers = new HashMap<>();
        Map<Integer, Integer> myTeamRoles = new HashMap<>(); // 1=队长, 2=队员

        for (Team team : myTeams) {
            Competition comp = competitionService.getCompetitionById(team.getCompetitionId());
            if (comp != null) {
                competitionNames.put(team.getTeamId(), comp.getName());
            }
            int count = teamMemberDAO.countByTeamId(team.getTeamId());
            memberCounts.put(team.getTeamId(), count);
            List<TeamMember> members = teamMemberDAO.findByTeamId(team.getTeamId());
            teamMembers.put(team.getTeamId(), members);
            // 判断当前用户在该队伍中的角色
            myTeamRoles.put(team.getTeamId(), team.getLeaderId().equals(user.getUserId()) ? 1 : 2);
        }

        // 鍔犺浇鎴愬憳鐢ㄦ埛鍚嶆槧灏?
        Map<Integer, String> userNames = new HashMap<>();
        Map<Integer, String> userAvatars = new HashMap<>();
        for (List<TeamMember> members : teamMembers.values()) {
            for (TeamMember member : members) {
                if (!userNames.containsKey(member.getUserId())) {
                    User memberUser = userDAO.findById(member.getUserId());
                    if (memberUser != null) {
                        userNames.put(memberUser.getUserId(), memberUser.getRealName());
                        userAvatars.put(memberUser.getUserId(), memberUser.getAvatar());
                    }
                }
            }
        }

        request.setAttribute("myTeams", myTeams);
        request.setAttribute("competitionNames", competitionNames);
        request.setAttribute("memberCounts", memberCounts);
        request.setAttribute("teamMembers", teamMembers);
        request.setAttribute("userNames", userNames);
        request.setAttribute("userAvatars", userAvatars);
        request.setAttribute("myTeamRoles", myTeamRoles);
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

            HttpSession session = request.getSession(false);
            User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
            if (currentUser == null || !teamService.isUserMemberOfTeam(currentUser.getUserId(), teamId)) {
                response.sendRedirect(request.getContextPath() + "/team?action=myTeams&error=permission_denied");
                return;
            }

            // 鍔犺浇绔炶禌鍚嶇О
            Competition competition = competitionService.getCompetitionById(team.getCompetitionId());
            String competitionName = competition != null ? competition.getName() : "鏈煡绔炶禌";
            Integer maxTeamSize = (competition != null && competition.getMaxTeamSize() != null && competition.getMaxTeamSize() > 0)
                    ? competition.getMaxTeamSize() : 5;

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

            // 加载队伍作品列表
            List<Work> works = workService.getWorksByTeamId(teamId);
            Map<Integer, Integer> likeCounts = new HashMap<>();
            int totalLikes = 0;
            if (works != null) {
                for (Work w : works) {
                    int likes = workLikeDAO.countByWorkId(w.getWorkId());
                    likeCounts.put(w.getWorkId(), likes);
                    totalLikes += likes;
                }
            }
            int workCount = works != null ? works.size() : 0;

            // 加载竞赛和子类列表（供编辑弹窗使用）
            List<Competition> competitions = competitionService.getAllCompetitions();
            List<CompetitionCategory> categories = categoryDAO.findAll();


            request.setAttribute("team", team);
            request.setAttribute("competition", competition);
            request.setAttribute("competitionName", competitionName);
            request.setAttribute("maxTeamSize", maxTeamSize);
            request.setAttribute("categoryName", categoryName);
            request.setAttribute("leaderName", leaderName);
            request.setAttribute("members", members);
            request.setAttribute("memberUsers", memberUsers);
            request.setAttribute("competitions", competitions);
            request.setAttribute("categories", categories);
            request.setAttribute("works", works);
            request.setAttribute("likeCounts", likeCounts);
            request.setAttribute("workCount", workCount);
            List<TeamApplication> pendingApplications = applicationService.getPendingApplicationsByTeamId(teamId);
            request.setAttribute("pendingApplications", pendingApplications);
            request.setAttribute("pendingApplicationCount", pendingApplications != null ? pendingApplications.size() : 0);
            request.setAttribute("totalLikes", totalLikes);
            request.getRequestDispatcher("/jsp/team_detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams&error=" + e.getClass().getSimpleName());
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
                request.setAttribute("error", "创建队伍失败。请检查：队伍名称是否填写完整、是否已在该竞赛中创建或加入了其他队伍（同一竞赛只能加入一支队伍）");
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

            User user = (User) session.getAttribute("user");
            Team team = extractTeamFromRequest(request);
            String idStr = request.getParameter("teamId");
            if (idStr != null) {
                team.setTeamId(Integer.parseInt(idStr));
            }

            if (team.getTeamId() == null || !teamService.isUserLeaderOfTeam(user.getUserId(), team.getTeamId())) {
                response.sendRedirect(request.getContextPath() + "/team?action=myTeams&error=permission_denied");
                return;
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
        boolean isAjax = "true".equals(request.getParameter("ajax"));

        try {
            Integer teamId = Integer.parseInt(request.getParameter("teamId"));
            Integer inviteeId = Integer.parseInt(request.getParameter("inviteeId"));

            // 逐一精确校验，提供具体错误提示
            Team team = teamService.getTeamById(teamId);
            if (team == null) {
                writeJson(response, isAjax, teamId, false, "队伍不存在");
                return;
            }

            // 1. 验证队长身份
            if (!team.getLeaderId().equals(user.getUserId())) {
                writeJson(response, isAjax, teamId, false, "只有队长才能邀请队员");
                return;
            }

            // 2. 不能邀请自己
            if (user.getUserId().equals(inviteeId)) {
                writeJson(response, isAjax, teamId, false, "不能邀请自己");
                return;
            }

            // 3. 检查是否已是队员
            if (teamService.isUserMemberOfTeam(inviteeId, teamId)) {
                writeJson(response, isAjax, teamId, false, "该用户已在队伍中");
                return;
            }

            // 4. 检查队伍人数
            int memberCount = teamMemberDAO.countByTeamId(teamId);
            Competition comp = competitionService.getCompetitionById(team.getCompetitionId());
            int maxSize = (comp != null && comp.getMaxTeamSize() != null && comp.getMaxTeamSize() > 0)
                    ? comp.getMaxTeamSize() : 5;
            if (memberCount >= maxSize) {
                writeJson(response, isAjax, teamId, false,
                        "队伍已满（" + memberCount + "/" + maxSize + "人），无法再邀请新成员");
                return;
            }

            // 5. 检查被邀请人是否已在同竞赛的其他队伍中
            Team joinedTeam = teamService.getUserTeamInCompetition(inviteeId, team.getCompetitionId());
            if (joinedTeam != null) {
                writeJson(response, isAjax, teamId, false,
                        "该用户已在同竞赛的队伍「" + joinedTeam.getTeamName() + "」中，同一竞赛只能加入一支队伍");
                return;
            }

            // 通过所有校验，执行邀请
            boolean success = teamService.inviteMember(teamId, user.getUserId(), inviteeId);

            if (success) {
                writeJson(response, isAjax, teamId, true, null);
            } else {
                writeJson(response, isAjax, teamId, false, "已向该用户发送过邀请，请等待对方回复");
            }
        } catch (Exception e) {
            writeJson(response, isAjax, null, false, "系统错误：" + e.getMessage());
        }
    }

    /**
     * 统一响应：AJAX返回JSON，普通请求重定向
     */
    private void writeJson(HttpServletResponse response, boolean isAjax, Integer teamId,
                           boolean success, String message) throws IOException {
        if (isAjax) {
            response.setContentType("application/json;charset=UTF-8");
            if (success) {
                response.getWriter().write("{\"success\":true}");
            } else {
                String escapedMsg = message != null ? message.replace("\\", "\\\\").replace("\"", "\\\"") : "";
                response.getWriter().write("{\"success\":false,\"message\":\"" + escapedMsg + "\"}");
            }
        } else if (teamId != null) {
            if (success) {
                response.sendRedirect("team?action=detail&id=" + teamId + "&msg=invite_success");
            } else {
                response.sendRedirect("team?action=detail&id=" + teamId + "&error=invite_failed");
            }
        } else {
            response.sendRedirect("team?action=myTeams&error=invite_error");
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
     * 报名参赛
     */
    private void registerCompetition(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            Integer teamId = Integer.parseInt(request.getParameter("teamId"));
            Team team = teamService.getTeamById(teamId);

            if (team == null) {
                response.sendRedirect(request.getContextPath() + "/team?action=myTeams&error=team_not_found");
                return;
            }

            // 验证是否为队长
            if (!team.getLeaderId().equals(user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/team?action=detail&id=" + teamId + "&error=not_leader");
                return;
            }

            boolean success = teamService.registerCompetition(teamId, team.getCompetitionId(), team.getCategoryId());

            if (success) {
                response.sendRedirect(request.getContextPath() + "/team?action=detail&id=" + teamId + "&msg=register_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/team?action=detail&id=" + teamId + "&error=register_failed");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams&error=register_error");
        }
    }

    /**
     * 取消报名
     */
    private void cancelRegistration(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            Integer teamId = Integer.parseInt(request.getParameter("teamId"));

            boolean success = teamService.cancelRegistration(teamId, user.getUserId());

            if (success) {
                response.sendRedirect(request.getContextPath() + "/team?action=detail&id=" + teamId + "&msg=cancel_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/team?action=detail&id=" + teamId + "&error=cancel_failed");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/team?action=myTeams&error=cancel_error");
        }
    }

    /**
     * 搜索用户（用于邀请队员弹窗）
     */
    private void searchUserForInvite(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("[]");
            return;
        }

        String keyword = request.getParameter("keyword");
        response.setContentType("application/json;charset=UTF-8");

        if (keyword == null || keyword.trim().isEmpty()) {
            response.getWriter().write("[]");
            return;
        }

        List<User> users = userDAO.searchInviteEligibleUsers(keyword.trim());
        User currentUser = (User) session.getAttribute("user");

        // 手动构建JSON数组
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        for (User u : users) {
            // 排除当前用户自己
            if (u.getUserId().equals(currentUser.getUserId())) {
                continue;
            }
            if (!first) json.append(",");
            json.append("{");
            json.append("\"userId\":").append(u.getUserId()).append(",");
            json.append("\"realName\":\"").append(escapeJson(u.getRealName())).append("\",");
            json.append("\"username\":\"").append(escapeJson(u.getUsername())).append("\"");
            json.append("}");
            first = false;
        }
        json.append("]");

        response.getWriter().write(json.toString());
    }

    /**
     * 搜索队伍（用于入队申请弹窗，按队名模糊匹配）
     */
    private void searchTeamForJoin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("[]");
            return;
        }

        String keyword = request.getParameter("keyword");
        String competitionIdStr = request.getParameter("competitionId");
        response.setContentType("application/json;charset=UTF-8");

        if (keyword == null || keyword.trim().isEmpty()) {
            response.getWriter().write("[]");
            return;
        }

        List<Team> teams = teamService.searchTeams(keyword.trim());
        Integer competitionId = null;
        if (competitionIdStr != null && !competitionIdStr.isEmpty()) {
            try {
                competitionId = Integer.parseInt(competitionIdStr);
            } catch (NumberFormatException ignored) {
            }
        }

        // 构建JSON：含队名、竞赛名、成员数、最大人数
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        for (Team t : teams) {
            // 如果指定了竞赛ID，则只返回该竞赛的队伍（状态为组建中）
            if (competitionId != null && !competitionId.equals(t.getCompetitionId())) {
                continue;
            }
            // 只显示组建中的队伍
            if (t.getStatus() == null || t.getStatus() != 1) {
                continue;
            }
            Competition comp = competitionService.getCompetitionById(t.getCompetitionId());
            int memberCount = teamMemberDAO.countByTeamId(t.getTeamId());
            Integer maxSize = (comp != null && comp.getMaxTeamSize() != null && comp.getMaxTeamSize() > 0)
                    ? comp.getMaxTeamSize() : 5;

            if (!first) json.append(",");
            json.append("{");
            json.append("\"teamId\":").append(t.getTeamId()).append(",");
            json.append("\"teamName\":\"").append(escapeJson(t.getTeamName())).append("\",");
            json.append("\"competitionName\":\"").append(escapeJson(comp != null ? comp.getName() : "未知竞赛")).append("\",");
            json.append("\"memberCount\":").append(memberCount).append(",");
            json.append("\"maxTeamSize\":").append(maxSize).append(",");
            json.append("\"leaderId\":").append(t.getLeaderId() != null ? t.getLeaderId() : 0);
            json.append("}");
            first = false;
        }
        json.append("]");

        response.getWriter().write(json.toString());
    }

    /**
     * JSON字符串转义
     */
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
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

