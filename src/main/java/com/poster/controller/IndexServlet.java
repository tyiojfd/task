package com.poster.controller;

import com.poster.model.User;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

/**
 * 首页Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/index")
public class IndexServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 获取当前登录用户（可能为null）
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // 将用户信息传递给JSP（让JSP根据登录状态显示不同内容）
        request.setAttribute("currentUser", user);

        // 转发到首页（无论是否登录都可以访问）
        request.getRequestDispatcher("/jsp/index.jsp").forward(request, response);
    }
}
