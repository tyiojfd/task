package com.poster.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

/**
 * 文件上传Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/upload")
@MultipartConfig(
    maxFileSize = 10485760,        // 10MB
    maxRequestSize = 20971520       // 20MB
)
public class FileUploadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: 实现文件上传逻辑
        // 1. 获取上传的文件
        // 2. 验证文件类型和大小
        // 3. 保存文件到服务器
        // 4. 返回文件路径
    }
}
