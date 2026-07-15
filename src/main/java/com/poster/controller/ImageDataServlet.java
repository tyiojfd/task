package com.poster.controller;

import com.poster.dao.TeamDAO;
import com.poster.dao.TeamMemberDAO;
import com.poster.dao.impl.TeamDAOImpl;
import com.poster.dao.impl.TeamMemberDAOImpl;
import com.poster.model.Competition;
import com.poster.model.Role;
import com.poster.model.Team;
import com.poster.model.TeamMember;
import com.poster.model.User;
import com.poster.model.Work;
import com.poster.service.CompetitionService;
import com.poster.service.TeamService;
import com.poster.service.WorkService;
import com.poster.service.impl.CompetitionServiceImpl;
import com.poster.service.impl.TeamServiceImpl;
import com.poster.service.impl.WorkServiceImpl;
import com.poster.util.WorkAccessPolicy;
import com.poster.util.DownloadHeaderPolicy;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;

/**
 * 从数据库读取图片BLOB数据并返回
 * @author 洪振博
 * @date 2026-07-08
 */
@WebServlet("/image-data")
public class ImageDataServlet extends HttpServlet {

    private WorkService workService = new WorkServiceImpl();
    private TeamService teamService = new TeamServiceImpl();
    private CompetitionService competitionService = new CompetitionServiceImpl();
    private TeamDAO teamDAO = new TeamDAOImpl();
    private TeamMemberDAO teamMemberDAO = new TeamMemberDAOImpl();

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

            HttpSession session = request.getSession(false);
            User user = session == null ? null : (User) session.getAttribute("user");
            if (user == null || !canViewWork(request, user, work)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "无权查看该作品图片");
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
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", 0);
            if ("true".equalsIgnoreCase(request.getParameter("download"))) {
                String downloadName = work.getImagePath();
                if (downloadName == null || downloadName.trim().isEmpty()) {
                    downloadName = "work-" + work.getWorkId() + ".jpg";
                }
                response.setHeader("Content-Disposition", DownloadHeaderPolicy.attachment(downloadName));
            }
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

    private boolean canViewWork(HttpServletRequest request, User user, Work work) {
        boolean administrator = hasRole(request, "管理员");
        boolean judge = hasRole(request, "评委");
        boolean teamMember = teamService.isUserMemberOfTeam(user.getUserId(), work.getTeamId());
        Competition competition = competitionService.getCompetitionById(work.getCompetitionId());
        boolean ended = competition != null && Integer.valueOf(3).equals(competition.getStatus());
        boolean participantInCompetition = isUserInCompetition(user.getUserId(), work.getCompetitionId());
        return WorkAccessPolicy.canView(administrator, judge, teamMember, ended, participantInCompetition);
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

    private boolean hasRole(HttpServletRequest request, String roleName) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
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
}
