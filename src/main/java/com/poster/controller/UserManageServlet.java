package com.poster.controller;

import com.poster.model.Role;
import com.poster.model.User;
import com.poster.service.UserService;
import com.poster.service.impl.UserServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/users")
public class UserManageServlet extends HttpServlet {
    private final UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) { response.sendError(403); return; }

        String keyword = request.getParameter("keyword");
        List<User> users = userService.searchUsers(keyword);
        List<Role> allRoles = userService.getAllRoles();
        Map<Integer, List<Role>> userRolesMap = new HashMap<>();
        for (User user : users) {
            userRolesMap.put(user.getUserId(), userService.getUserRoles(user.getUserId()));
        }

        request.setAttribute("users", users);
        request.setAttribute("allRoles", allRoles);
        request.setAttribute("userRolesMap", userRolesMap);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("/jsp/user_manage.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) { response.sendError(403); return; }

        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");
        Integer userId = null;
        try { userId = Integer.parseInt(userIdStr); } catch (NumberFormatException ignored) {}

        boolean success = false;
        if (userId != null && "status".equals(action)) {
            String statusStr = request.getParameter("status");
            try {
                int status = Integer.parseInt(statusStr);
                if (status == 0 || status == 1) {
                    success = userService.updateUserStatus(userId, status);
                }
            } catch (NumberFormatException ignored) {}
        } else if (userId != null && "roles".equals(action)) {
            success = userService.updateUserRoles(userId, request.getParameterValues("roleIds"));
        } else if (userId != null && "resetPwd".equals(action)) {
            String newPwd = request.getParameter("newPassword");
            User user = userService.getUserById(userId);
            if (user != null && newPwd != null && newPwd.length() >= 6) {
                success = userService.resetPassword(user.getUsername(), user.getEmail(), newPwd);
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/users?" + (success ? "ok=1" : "err=1"));
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) return false;
        @SuppressWarnings("unchecked")
        List<Role> roles = (List<Role>) session.getAttribute("roles");
        if (roles == null) return false;
        for (Role r : roles) { if ("管理员".equals(r.getRoleName())) return true; }
        return false;
    }
}
