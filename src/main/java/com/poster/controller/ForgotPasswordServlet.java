package com.poster.controller;

import com.poster.service.UserService;
import com.poster.service.impl.UserServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    private final UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/forgot_password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String newPwd = request.getParameter("newPassword");
        String confirmPwd = request.getParameter("confirmPassword");

        boolean hasError = false;
        if (isBlank(username) || isBlank(email) || isBlank(newPwd)) {
            request.setAttribute("error", "请填写完整信息");
            hasError = true;
        } else if (newPwd.length() < 6) {
            request.setAttribute("error", "新密码长度不能少于6位");
            hasError = true;
        } else if (!newPwd.equals(confirmPwd)) {
            request.setAttribute("error", "两次输入的密码不一致");
            hasError = true;
        }

        if (!hasError) {
            if (userService.resetPassword(username.trim(), email.trim(), newPwd)) {
                request.setAttribute("success", "密码重置成功，请返回登录");
            } else {
                request.setAttribute("error", "用户名和邮箱不匹配");
                request.setAttribute("username", username);
                request.setAttribute("email", email);
            }
        } else {
            request.setAttribute("username", username);
            request.setAttribute("email", email);
        }

        request.getRequestDispatcher("/jsp/forgot_password.jsp").forward(request, response);
    }

    private boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
}
