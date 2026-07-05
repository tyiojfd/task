package com.poster.controller;

import com.poster.model.User;
import com.poster.service.UserService;
import com.poster.service.impl.UserServiceImpl;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

/**
 * 个人中心Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 刷新Session中的用户信息
        User sessionUser = (User) session.getAttribute("user");
        User freshUser = userService.getUserById(sessionUser.getUserId());
        if (freshUser != null) {
            session.setAttribute("user", freshUser);
        }

        request.getRequestDispatcher("/jsp/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        User sessionUser = (User) session.getAttribute("user");
        User freshUser = userService.getUserById(sessionUser.getUserId());

        if ("updateProfile".equals(action)) {
            // 更新个人信息
            String realName = request.getParameter("realName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");

            if (realName == null || realName.trim().isEmpty()) {
                request.setAttribute("error", "真实姓名不能为空");
            } else if (email == null || email.trim().isEmpty()) {
                request.setAttribute("error", "邮箱不能为空");
            } else {
                freshUser.setRealName(realName.trim());
                freshUser.setEmail(email.trim());
                freshUser.setPhone(phone != null ? phone.trim() : null);

                if (userService.updateUser(freshUser)) {
                    session.setAttribute("user", freshUser);
                    request.setAttribute("success", "个人信息更新成功");
                } else {
                    request.setAttribute("error", "更新失败，请重试");
                }
            }
        } else if ("changePassword".equals(action)) {
            // 修改密码
            String oldPassword = request.getParameter("oldPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmNewPassword = request.getParameter("confirmNewPassword");

            if (oldPassword == null || oldPassword.trim().isEmpty()) {
                request.setAttribute("error", "当前密码不能为空");
            } else if (newPassword == null || newPassword.length() < 6) {
                request.setAttribute("error", "新密码长度不能少于6位");
            } else if (!newPassword.equals(confirmNewPassword)) {
                request.setAttribute("error", "两次输入的新密码不一致");
            } else if (userService.changePassword(freshUser.getUserId(), oldPassword, newPassword)) {
                request.setAttribute("success", "密码修改成功");
            } else {
                request.setAttribute("error", "当前密码错误");
            }
        }

        request.getRequestDispatcher("/jsp/profile.jsp").forward(request, response);
    }
}
