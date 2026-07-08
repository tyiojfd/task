package com.poster.controller;

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
        String realPath = getServletContext().getRealPath("/" + com.poster.util.FileUploadUtil.STORAGE_DIR);
        Path storagePath = Paths.get(realPath, fileSubPath);

        if (Files.exists(storagePath) && Files.isReadable(storagePath)) {
            serveFile(response, storagePath);
            return;
        }

        String oldRealPath = getServletContext().getRealPath("/uploads");
        Path oldPath = Paths.get(oldRealPath, fileSubPath);
        if (Files.exists(oldPath) && Files.isReadable(oldPath)) {
            serveFile(response, oldPath);
            return;
        }

        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private void serveFile(HttpServletResponse response, Path filePath) throws IOException {
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