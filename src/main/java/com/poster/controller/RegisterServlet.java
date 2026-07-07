package com.poster.controller;

import com.poster.service.UserService;
import com.poster.service.impl.UserServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

/**
 * 注册Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/register")
@MultipartConfig(
    maxFileSize = 10485760,     // 10MB
    maxRequestSize = 20971520,  // 20MB
    fileSizeThreshold = 5242880 // 5MB
)
public class RegisterServlet extends HttpServlet {

    private UserService userService = new UserServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1. 获取表单参数
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String realName = request.getParameter("realName");
        String email = request.getParameter("email");

        // 2. 验证输入
        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("error", "用户名不能为空");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }
        username = username.trim();

        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "密码不能为空");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "密码长度不能少于6位");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "两次密码输入不一致");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }

        if (realName == null || realName.trim().isEmpty()) {
            request.setAttribute("error", "真实姓名不能为空");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }
        realName = realName.trim();

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "邮箱不能为空");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }
        email = email.trim();
        if (!email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
            request.setAttribute("error", "请输入有效的邮箱地址");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            return;
        }

        // 3. 处理头像上传（可选）
        String avatarPath = null;
        try {
            Part avatarPart = request.getPart("avatar");
            if (avatarPart != null && avatarPart.getSize() > 0) {
                String contentType = avatarPart.getContentType();
                if (contentType == null || (!contentType.equals("image/jpeg") && !contentType.equals("image/png"))) {
                    request.setAttribute("error", "头像仅支持 JPG/PNG 格式");
                    request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
                    return;
                }
                if (avatarPart.getSize() > 2 * 1024 * 1024) {
                    request.setAttribute("error", "头像文件不能超过2MB");
                    request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
                    return;
                }
                avatarPath = saveAvatar(avatarPart, request);
            }
        } catch (Exception e) {
            // 头像上传失败不影响注册，继续
            e.printStackTrace();
        }

        // 4. 调用Service注册用户
        try {
            boolean success = userService.register(username, password, realName, email, avatarPath);
            if (success) {
                request.setAttribute("success", "注册成功，请登录");
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "用户名或邮箱已被注册");
                request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "注册失败，服务器内部错误");
            request.getRequestDispatcher("/jsp/register.jsp").forward(request, response);
        }
    }

    /**
     * 保存头像文件
     */
    private String saveAvatar(Part avatarPart, HttpServletRequest request) throws IOException {
        String uploadDir = getServletContext().getRealPath("/uploads/avatars");
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        String originalName = avatarPart.getSubmittedFileName();
        String ext = "";
        if (originalName != null && originalName.contains(".")) {
            ext = originalName.substring(originalName.lastIndexOf("."));
        }
        String fileName = "avatar_" + UUID.randomUUID().toString().substring(0, 8) + ext;
        Path filePath = uploadPath.resolve(fileName);
        avatarPart.write(filePath.toString());

        return "/uploads/avatars/" + fileName;
    }
}
