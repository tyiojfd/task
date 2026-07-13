package com.poster.controller;

import com.poster.dao.TeamDAO;
import com.poster.dao.TeamMemberDAO;
import com.poster.dao.WorkFileDAO;
import com.poster.dao.impl.TeamDAOImpl;
import com.poster.dao.impl.TeamMemberDAOImpl;
import com.poster.dao.impl.WorkFileDAOImpl;
import com.poster.model.Competition;
import com.poster.model.Role;
import com.poster.model.Team;
import com.poster.model.TeamMember;
import com.poster.model.User;
import com.poster.model.Work;
import com.poster.model.WorkFile;
import com.poster.service.CompetitionService;
import com.poster.service.TeamService;
import com.poster.service.WorkService;
import com.poster.service.impl.CompetitionServiceImpl;
import com.poster.service.impl.TeamServiceImpl;
import com.poster.service.impl.WorkServiceImpl;
import com.poster.util.FileUploadUtil;
import com.poster.util.UploadPathResolver;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@WebServlet("/uploads/*")
public class ImageServlet extends HttpServlet {

    private final WorkFileDAO workFileDAO = new WorkFileDAOImpl();
    private final WorkService workService = new WorkServiceImpl();
    private final TeamService teamService = new TeamServiceImpl();
    private final CompetitionService competitionService = new CompetitionServiceImpl();
    private final TeamDAO teamDAO = new TeamDAOImpl();
    private final TeamMemberDAO teamMemberDAO = new TeamMemberDAOImpl();

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

        if (!isPublicFile(fileSubPath) && !canReadPrivateFile(request, fileSubPath)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "无权访问该上传文件");
            return;
        }

        // 判断是否是下载请求
        boolean isDownload = "true".equals(request.getParameter("download"));

        // 1. 尝试从外置存储目录读取
        String externalBase = FileUploadUtil.getStorageBasePath();
        Path externalPath = UploadPathResolver.resolve(Paths.get(externalBase), fileSubPath);
        if (externalPath != null && Files.exists(externalPath) && Files.isReadable(externalPath)) {
            serveFile(response, externalPath, isDownload);
            return;
        }

        // 2. 回退到webapp内路径（兼容旧版本已上传文件）
        String webappBase = getServletContext().getRealPath("/" + FileUploadUtil.STORAGE_DIR);
        Path webappPath = webappBase == null
                ? null : UploadPathResolver.resolve(Paths.get(webappBase), fileSubPath);
        if (webappPath != null && Files.exists(webappPath) && Files.isReadable(webappPath)) {
            serveFile(response, webappPath, isDownload);
            return;
        }

        // 3. 回退到旧版 /uploads 目录
        String oldBase = getServletContext().getRealPath("/uploads");
        Path oldPath = oldBase == null
                ? null : UploadPathResolver.resolve(Paths.get(oldBase), fileSubPath);
        if (oldPath != null && Files.exists(oldPath) && Files.isReadable(oldPath)) {
            serveFile(response, oldPath, isDownload);
            return;
        }

        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    private boolean isPublicFile(String fileSubPath) {
        if (fileSubPath == null) {
            return false;
        }
        String lowerPath = fileSubPath.toLowerCase(java.util.Locale.ROOT);
        return lowerPath.matches("/avatars/[^/]+\\.(jpg|jpeg|png|gif|webp)")
                || lowerPath.matches("/competition_[0-9]+/cover\\.(jpg|jpeg|png)");
    }

    private boolean canReadPrivateFile(HttpServletRequest request, String fileSubPath) {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            return false;
        }

        WorkFile workFile = workFileDAO.findByFilePath(fileSubPath);
        if (workFile == null) {
            return false;
        }
        Work work = workService.getWorkById(workFile.getWorkId());
        if (work == null) {
            return false;
        }

        boolean administrator = hasRole(session, "管理员");
        boolean judge = hasRole(session, "评委");
        boolean teamMember = teamService.isUserMemberOfTeam(user.getUserId(), work.getTeamId());
        Competition competition = competitionService.getCompetitionById(work.getCompetitionId());
        boolean ended = competition != null && Integer.valueOf(3).equals(competition.getStatus());
        boolean participantInCompetition = isUserInCompetition(user.getUserId(), work.getCompetitionId());
        return com.poster.util.WorkAccessPolicy.canView(administrator, judge, teamMember,
                ended, participantInCompetition);
    }

    private boolean isUserInCompetition(Integer userId, Integer competitionId) {
        if (userId == null || competitionId == null) {
            return false;
        }
        List<TeamMember> memberships = teamMemberDAO.findByUserId(userId);
        if (memberships == null) {
            return false;
        }
        for (TeamMember membership : memberships) {
            Team team = teamDAO.findById(membership.getTeamId());
            if (team != null && competitionId.equals(team.getCompetitionId())
                    && team.getStatus() != null && team.getStatus() != 0) {
                return true;
            }
        }
        return false;
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
