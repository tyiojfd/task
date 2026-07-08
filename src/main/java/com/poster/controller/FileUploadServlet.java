package com.poster.controller;

import com.poster.util.FileUploadUtil;

import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import com.google.gson.JsonObject;

/**
 * 文件上传Servlet（通用图片上传接口）
 * @author 队员B
 * @date 2026-07-06
 *
 */
@WebServlet("/upload")
@MultipartConfig(
    maxFileSize = 10485760,        // 10MB
    maxRequestSize = 20971520,     // 20MB
    fileSizeThreshold = 5242880    // 5MB
)
public class FileUploadServlet extends HttpServlet {

    private static final String UPLOAD_BASE = "uploads";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject json = new JsonObject();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            json.addProperty("success", false);
            json.addProperty("message", "请先登录");
            out.print(json.toString());
            return;
        }

        try {
            // 获取参数
            String competitionIdStr = request.getParameter("competitionId");
            String teamIdStr = request.getParameter("teamId");

            if (competitionIdStr == null || teamIdStr == null) {
                json.addProperty("success", false);
                json.addProperty("message", "缺少必要参数");
                out.print(json.toString());
                return;
            }

            Integer competitionId = Integer.parseInt(competitionIdStr);
            Integer teamId = Integer.parseInt(teamIdStr);

            // 处理上传
            Part filePart = request.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                json.addProperty("success", false);
                json.addProperty("message", "请选择文件");
                out.print(json.toString());
                return;
            }

            // 校验文件类型
            if (!FileUploadUtil.isAllowedType(filePart.getContentType())) {
                json.addProperty("success", false);
                json.addProperty("message", "不支持的文件类型，仅支持 JPG/PNG");
                out.print(json.toString());
                return;
            }

            // 保存文件
            String uploadRealPath = getServletContext().getRealPath("/" + UPLOAD_BASE);
            String relativePath = "/" + UPLOAD_BASE + FileUploadUtil.saveFile(filePart, uploadRealPath, competitionId, teamId);

            json.addProperty("success", true);
            json.addProperty("url", request.getContextPath() + relativePath);
            json.addProperty("path", relativePath);
            json.addProperty("message", "上传成功");

        } catch (Exception e) {
            e.printStackTrace();
            json.addProperty("success", false);
            json.addProperty("message", "上传失败：" + e.getMessage());
        }

        out.print(json.toString());
    }
}
