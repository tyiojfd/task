package com.poster.controller;

import com.poster.model.Role;
import com.poster.model.User;
import com.poster.service.UserService;
import com.poster.service.impl.UserServiceImpl;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
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

        // 转发到登录页面
        request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1. 获取表单参数
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 2. 验证输入
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "用户名和密码不能为空");
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            return;
        }

        // 3. 调用Service验证登录
        User user = userService.login(username.trim(), password);

        if (user != null) {
            // 登录成功，设置Session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            // 加载用户角色
            List<Role> roles = userService.getUserRoles(user.getUserId());
            session.setAttribute("roles", roles);

            // 重定向到主页
            response.sendRedirect(request.getContextPath() + "/index");
        } else {
            request.setAttribute("error", "用户名或密码错误，或账号已被禁用");
            request.setAttribute("username", username);
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
        }
    }
}
