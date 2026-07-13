package com.poster.controller;

import com.poster.dao.CompetitionDAO;
import com.poster.dao.TeamDAO;
import com.poster.dao.WorkDAO;
import com.poster.dao.WorkFileDAO;
import com.poster.dao.impl.CompetitionDAOImpl;
import com.poster.dao.impl.TeamDAOImpl;
import com.poster.dao.impl.WorkDAOImpl;
import com.poster.dao.impl.WorkFileDAOImpl;
import com.poster.model.Competition;
import com.poster.model.Role;
import com.poster.model.Team;
import com.poster.model.User;
import com.poster.model.Work;
import com.poster.model.WorkFile;
import com.poster.util.FileUploadUtil;
import com.poster.util.UploadAccessPolicy;

import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
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

    private final CompetitionDAO competitionDAO = new CompetitionDAOImpl();
    private final TeamDAO teamDAO = new TeamDAOImpl();
    private final WorkDAO workDAO = new WorkDAOImpl();
    private final WorkFileDAO workFileDAO = new WorkFileDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject json = new JsonObject();

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            writeError(response, out, HttpServletResponse.SC_UNAUTHORIZED, "请先登录");
            return;
        }

        try {
            String competitionIdStr = request.getParameter("competitionId");
            String teamIdStr = request.getParameter("teamId");
            String workIdStr = request.getParameter("workId");

            Integer competitionId = parsePositiveId(competitionIdStr);
            Integer teamId = parsePositiveId(teamIdStr);
            Integer workId = parsePositiveId(workIdStr);
            if (competitionId == null || teamId == null || workId == null) {
                writeError(response, out, HttpServletResponse.SC_BAD_REQUEST,
                        "缺少或无效的competitionId、teamId或workId参数");
                return;
            }

            Team team = teamDAO.findById(teamId);
            Work work = workDAO.findById(workId);
            Competition competition = competitionDAO.findById(competitionId);
            boolean administrator = hasRole(session, "管理员");
            boolean beforeDeadline = competition != null
                    && (competition.getSubmitDeadline() == null
                    || LocalDateTime.now().isBefore(competition.getSubmitDeadline()));
            if (!UploadAccessPolicy.canUpload(user, team, work, competition,
                    administrator, beforeDeadline)) {
                writeError(response, out, HttpServletResponse.SC_FORBIDDEN,
                        "无权向该作品上传附件，或竞赛已截止");
                return;
            }

            Part filePart = request.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                writeError(response, out, HttpServletResponse.SC_BAD_REQUEST, "请选择文件");
                return;
            }

            if (!FileUploadUtil.isAllowedType(filePart.getContentType())
                    || !FileUploadUtil.isAllowedExtension(filePart.getSubmittedFileName())) {
                writeError(response, out, HttpServletResponse.SC_BAD_REQUEST,
                        "不支持的文件类型，仅支持 JPG/PNG");
                return;
            }

            String uploadRealPath = FileUploadUtil.getUploadBasePath();
            String filePath = FileUploadUtil.saveFile(filePart, uploadRealPath, competitionId, teamId);

            WorkFile workFile = new WorkFile();
            workFile.setWorkId(workId);
            workFile.setFileName(safeFileName(filePart.getSubmittedFileName()));
            workFile.setFilePath(filePath);
            workFile.setFileType(filePart.getContentType());
            workFile.setFileSize(filePart.getSize());
            if (workFileDAO.insert(workFile) <= 0) {
                FileUploadUtil.deleteFile(uploadRealPath, filePath);
                writeError(response, out, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "附件记录保存失败，已清理上传文件");
                return;
            }

            String relativePath = "/uploads" + filePath;

            json.addProperty("success", true);
            json.addProperty("url", request.getContextPath() + relativePath);
            json.addProperty("path", relativePath);
            json.addProperty("fileId", workFile.getFileId());
            json.addProperty("message", "上传成功");

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            json.addProperty("success", false);
            json.addProperty("message", "上传失败");
        }

        out.print(json.toString());
    }

    private Integer parsePositiveId(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            int id = Integer.parseInt(value.trim());
            return id > 0 ? id : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String safeFileName(String submittedFileName) {
        if (submittedFileName == null || submittedFileName.trim().isEmpty()) {
            return "attachment";
        }
        String normalized = submittedFileName.replace('\\', '/');
        return Paths.get(normalized).getFileName().toString();
    }

    private boolean hasRole(HttpSession session, String roleName) {
        @SuppressWarnings("unchecked")
        List<Role> roles = (List<Role>) session.getAttribute("roles");
        if (roles == null) {
            return false;
        }
        for (Role role : roles) {
            if (roleName.equals(role.getRoleName())) {
                return true;
            }
        }
        return false;
    }

    private void writeError(HttpServletResponse response, PrintWriter out,
                            int status, String message) {
        response.setStatus(status);
        JsonObject json = new JsonObject();
        json.addProperty("success", false);
        json.addProperty("message", message);
        out.print(json.toString());
    }
}

