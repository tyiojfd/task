package com.poster.controller;

import com.poster.model.Work;
import com.poster.service.WorkService;
import com.poster.service.impl.WorkServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.io.OutputStream;

/**
 * 从数据库读取图片BLOB数据并返回
 * @author 洪振博
 * @date 2026-07-08
 */
@WebServlet("/image-data")
public class ImageDataServlet extends HttpServlet {

    private WorkService workService = new WorkServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String workIdStr = request.getParameter("workId");

        if (workIdStr == null || workIdStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "缺少workId参数");
            return;
        }

        try {
            Integer workId = Integer.parseInt(workIdStr);
            Work work = workService.getWorkById(workId);

            if (work == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "作品不存在");
                return;
            }

            String type = request.getParameter("type");
            byte[] imageData;
            String contentType;

            if ("thumb".equalsIgnoreCase(type)) {
                imageData = work.getThumbnailData();
                contentType = work.getThumbnailContentType();
                if (imageData == null || imageData.length == 0) {
                    imageData = work.getImageData();
                    contentType = work.getImageContentType();
                }
            } else {
                imageData = work.getImageData();
                contentType = work.getImageContentType();
            }

            if (imageData == null || imageData.length == 0) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "图片数据不存在");
                return;
            }

            // 设置响应头
            response.setContentType(contentType != null ? contentType : "image/jpeg");
            response.setContentLength(imageData.length);
            response.setHeader("Cache-Control", "private, max-age=3600");
            response.setHeader("X-Image-Variant", "thumb".equalsIgnoreCase(type) ? "thumb" : "original");

            // 写入图片数据
            try (OutputStream out = response.getOutputStream()) {
                out.write(imageData);
                out.flush();
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "无效的workId");
        }
    }
}
