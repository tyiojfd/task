package com.poster.controller;

import com.poster.service.UserService;
import com.poster.service.impl.UserServiceImpl;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
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
        // TODO: 转发到注册页面
        request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现注册逻辑
        // 1. 获取表单参数
        // 2. 验证输入
        // 3. 调用Service注册用户
        // 4. 跳转到登录页或返回错误
    }
}
