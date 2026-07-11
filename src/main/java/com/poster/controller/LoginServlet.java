package com.poster.controller;

import com.poster.model.Role;
import com.poster.model.User;
import com.poster.service.UserService;
import com.poster.service.impl.UserServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

/**
 * 登录Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 检查是否已登录
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect(request.getContextPath() + "/index");
            return;
        }

        // 显示注册成功提示
        if ("success".equals(request.getParameter("registered"))) {
            request.setAttribute("success", "注册成功，请登录");
        }

        String role = normalizeRole(request.getParameter("role"));
        request.getSession().setAttribute("loginEntryRole", role == null ? "普通用户" : role);
        request.setAttribute("loginRole", role);
        forwardByRole(request, response, role);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1. 获取表单参数
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        HttpSession entrySession = request.getSession(false);
        String loginRole = null;
        if (entrySession != null) {
            loginRole = normalizeRole((String) entrySession.getAttribute("loginEntryRole"));
        }
        String expectedRole = loginRole == null ? "普通用户" : loginRole;

        // 2. 验证输入
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "用户名和密码不能为空");
            request.setAttribute("loginRole", loginRole);
            forwardByRole(request, response, loginRole);
            return;
        }

        // 3. 调用Service验证登录。普通登录入口默认只允许队员/队长，不能作为管理员/评委的通用入口。
        User user = userService.login(username.trim(), password, expectedRole);

        if (user != null) {
            // 登录成功，设置Session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            // 加载用户角色
            List<Role> roles = userService.getUserRoles(user.getUserId());
            session.setAttribute("roles", roles);
            session.removeAttribute("loginEntryRole");

            // 重定向到主页
            response.sendRedirect(request.getContextPath() + "/index");
        } else {
            request.setAttribute("error", loginRole == null
                    ? "普通登录入口仅支持队员/队长账号，请管理员或评委使用对应登录入口"
                    : "该账号不属于当前登录入口，或用户名/密码错误");
            request.setAttribute("username", username);
            request.setAttribute("loginRole", loginRole);
            forwardByRole(request, response, loginRole);
        }
    }

    private void forwardByRole(HttpServletRequest request, HttpServletResponse response, String role)
            throws ServletException, IOException {
        if ("评委".equals(role)) {
            request.getRequestDispatcher("/jsp/login_judge.jsp").forward(request, response);
        } else if ("管理员".equals(role)) {
            request.getRequestDispatcher("/jsp/login_admin.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
        }
    }

    private String normalizeRole(String role) {
        if (role == null) {
            return null;
        }
        role = role.trim();
        if ("admin".equalsIgnoreCase(role) || "管理员".equals(role)) {
            return "管理员";
        }
        if ("judge".equalsIgnoreCase(role) || "评委".equals(role)) {
            return "评委";
        }
        if ("member".equalsIgnoreCase(role) || "participant".equalsIgnoreCase(role)
                || "普通用户".equals(role) || "队员".equals(role) || "队长".equals(role)) {
            return "普通用户";
        }
        return null;
    }
}
