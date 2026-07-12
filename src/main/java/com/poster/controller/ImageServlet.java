package com.poster.controller;

import com.poster.util.FileUploadUtil;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@WebServlet("/uploads/*")
public class ImageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String requestURI = request.getRequestURI();
        String contextPath = request.getContextPath();
        String relativePath = requestURI.substring(contextPath.length());

        if (relativePath == null || relativePath.isEmpty() || relativePath.equals("/uploads") || relativePath.equals("/uploads/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String fileSubPath = relativePath.substring("/uploads".length());

        // 判断是否是下载请求
        boolean isDownload = "true".equals(request.getParameter("download"));

        // 1. 尝试从外置存储目录读取
        String externalBase = FileUploadUtil.getStorageBasePath();
        Path externalPath = Paths.get(externalBase, fileSubPath);
        if (Files.exists(externalPath) && Files.isReadable(externalPath)) {
            serveFile(response, externalPath, isDownload);
            return;
        }

        // 2. 回退到webapp内路径（兼容旧版本已上传文件）
        String webappBase = getServletContext().getRealPath("/" + FileUploadUtil.STORAGE_DIR);
        Path webappPath = Paths.get(webappBase, fileSubPath);
        if (Files.exists(webappPath) && Files.isReadable(webappPath)) {
            serveFile(response, webappPath, isDownload);
            return;
        }

        // 3. 回退到旧版 /uploads 目录
        String oldBase = getServletContext().getRealPath("/uploads");
        Path oldPath = Paths.get(oldBase, fileSubPath);
        if (Files.exists(oldPath) && Files.isReadable(oldPath)) {
            serveFile(response, oldPath, isDownload);
            return;
        }

        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private void serveFile(HttpServletResponse response, Path filePath, boolean isDownload) throws IOException {
        String fileName = filePath.getFileName().toString().toLowerCase();
        String contentType;
        if (fileName.endsWith(".png")) {
            contentType = "image/png";
        } else if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) {
            contentType = "image/jpeg";
        } else {
            contentType = "application/octet-stream";
        }

        response.setContentType(contentType);
        response.setHeader("Cache-Control", "private, max-age=3600");

        if (isDownload) {
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filePath.getFileName().toString() + "\"");
        }

        try (InputStream in = Files.newInputStream(filePath);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}
