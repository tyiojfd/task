package com.poster.controller;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

/**
 * 奖状Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/certificate")
public class CertificateServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现奖状查看/下载逻辑
        // 1. 获取action参数
        // 2. 根据action执行不同操作（view/download）
    }
}
