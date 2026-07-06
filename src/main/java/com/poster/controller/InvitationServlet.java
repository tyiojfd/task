package com.poster.controller;

import com.poster.model.Invitation;
import com.poster.model.Team;
import com.poster.model.User;
import com.poster.dao.TeamDAO;
import com.poster.dao.UserDAO;
import com.poster.dao.impl.TeamDAOImpl;
import com.poster.dao.impl.UserDAOImpl;
import com.poster.service.InvitationService;
import com.poster.service.impl.InvitationServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 邀请Servlet
 * @author 杨祥博
 * @date 2026-07-06
 */
@WebServlet("/invitation")
public class InvitationServlet extends HttpServlet {

    private InvitationService invitationService = new InvitationServiceImpl();
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

        User user = (User) session.getAttribute("user");

        // 获取用户的所有邀请
        List<Invitation> invitations = invitationService.getInvitationsForUser(user.getUserId());

        // 加载关联数据：队伍名称、邀请人姓名
        Map<Integer, String> teamNames = new HashMap<>();
        Map<Integer, String> inviterNames = new HashMap<>();

        if (invitations != null) {
            for (Invitation inv : invitations) {
                if (!teamNames.containsKey(inv.getTeamId())) {
                    Team team = teamDAO.findById(inv.getTeamId());
                    teamNames.put(inv.getTeamId(), team != null ? team.getTeamName() : "未知队伍");
                }
                if (!inviterNames.containsKey(inv.getInviterId())) {
                    User inviter = userDAO.findById(inv.getInviterId());
                    inviterNames.put(inv.getInviterId(), inviter != null ? inviter.getRealName() : "未知用户");
                }
            }
        }

        request.setAttribute("invitations", invitations);
        request.setAttribute("teamNames", teamNames);
        request.setAttribute("inviterNames", inviterNames);
        request.getRequestDispatcher("/jsp/invitation_list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        if ("accept".equals(action)) {
            try {
                Integer invitationId = Integer.parseInt(request.getParameter("invitationId"));
                boolean success = invitationService.acceptInvitation(invitationId, user.getUserId());
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/invitation?msg=accept_success");
                } else {
                    response.sendRedirect(request.getContextPath() + "/invitation?error=accept_failed");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/invitation?error=invalid_id");
            }
        } else if ("reject".equals(action)) {
            try {
                Integer invitationId = Integer.parseInt(request.getParameter("invitationId"));
                boolean success = invitationService.rejectInvitation(invitationId, user.getUserId());
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/invitation?msg=reject_success");
                } else {
                    response.sendRedirect(request.getContextPath() + "/invitation?error=reject_failed");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/invitation?error=invalid_id");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/invitation");
        }
    }
}
