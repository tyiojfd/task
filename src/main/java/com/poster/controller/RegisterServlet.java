package com.poster.controller;

import com.poster.service.UserService;
import com.poster.service.impl.UserServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

/**
 * 注册Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 转发到注册页面
        request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1. 获取表单参数
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String realName = request.getParameter("realName");
        String email = request.getParameter("email");

        // 2. 验证输入
        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("error", "用户名不能为空");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }
        username = username.trim();

        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "密码不能为空");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "密码长度不能少于6位");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "两次密码输入不一致");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }

        if (realName == null || realName.trim().isEmpty()) {
            request.setAttribute("error", "真实姓名不能为空");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }
        realName = realName.trim();

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "邮箱不能为空");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }
        email = email.trim();
        if (!email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            request.setAttribute("error", "请输入有效的邮箱地址");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }

        // 3. 调用Service注册用户
        try {
            boolean success = userService.register(username, password, realName, email);
            if (success) {
                request.setAttribute("success", "注册成功，请登录");
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "用户名或邮箱已被注册");
                request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "注册失败，服务器内部错误");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
        }
    }
}
