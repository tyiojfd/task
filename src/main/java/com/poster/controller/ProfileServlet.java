package com.poster.controller;

import com.poster.model.User;
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
 * 个人中心Servlet
 * @author 团队共建
 * @date 2026-07-04
 */
@WebServlet("/profile")
@MultipartConfig(
    maxFileSize = 2097152,      // 2MB
    maxRequestSize = 5242880,   // 5MB
    fileSizeThreshold = 1048576 // 1MB
)
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
        } else if ("uploadAvatar".equals(action)) {
            try {
                Part avatarPart = request.getPart("avatar");
                if (avatarPart == null || avatarPart.getSize() == 0) {
                    request.setAttribute("error", "请选择头像文件");
                } else {
                    String contentType = avatarPart.getContentType();
                    if (contentType == null || (!contentType.equals("image/jpeg") && !contentType.equals("image/png"))) {
                        request.setAttribute("error", "头像仅支持 JPG/PNG 格式");
                    } else if (avatarPart.getSize() > 2 * 1024 * 1024) {
                        request.setAttribute("error", "头像文件不能超过2MB");
                    } else {
                        String avatarPath = saveAvatar(avatarPart, request);
                        // 删除旧头像
                        if (freshUser.getAvatar() != null && !freshUser.getAvatar().isEmpty()) {
                            String oldPath = getServletContext().getRealPath(freshUser.getAvatar());
                            try { new File(oldPath).delete(); } catch (Exception ignored) {}
                        }
                        freshUser.setAvatar(avatarPath);
                        if (userService.updateUser(freshUser)) {
                            session.setAttribute("user", freshUser);
                            request.setAttribute("success", "头像更新成功");
                        } else {
                            request.setAttribute("error", "头像更新失败");
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "上传失败：" + e.getMessage());
            }
        }

        request.getRequestDispatcher("/jsp/profile.jsp").forward(request, response);
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
