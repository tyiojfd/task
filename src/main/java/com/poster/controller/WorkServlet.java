package com.poster.controller;

import com.poster.model.*;
import com.poster.service.*;
import com.poster.service.impl.*;
import com.poster.util.FileUploadUtil;
import com.poster.util.WorkAccessPolicy;
import com.poster.util.SharePolicy;
import java.util.*;
import com.poster.dao.*;
import com.poster.dao.impl.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDateTime;

@WebServlet("/work")
@MultipartConfig(
    maxFileSize = 10485760,
    maxRequestSize = 20971520,
    fileSizeThreshold = 5242880
)
public class WorkServlet extends HttpServlet {

    private WorkService workService = new WorkServiceImpl();
    private TeamService teamService = new TeamServiceImpl();
    private CompetitionService competitionService = new CompetitionServiceImpl();
    private TeamMemberDAO teamMemberDAO = new TeamMemberDAOImpl();
    private TeamDAO teamDAO = new TeamDAOImpl();
    private UserDAO userDAO = new UserDAOImpl();
    private WorkFileDAO workFileDAO = new WorkFileDAOImpl();
    private WorkDAO workDAO = new WorkDAOImpl();

    private static final String UPLOAD_BASE = "uploads";
    private static final int THUMBNAIL_MAX_WIDTH = 300;
    private static final float THUMBNAIL_JPEG_QUALITY = 0.75f;
    private static final String THUMBNAIL_CONTENT_TYPE = "image/jpeg";

    private boolean isCompetitionRunningAndOpen(Competition competition) {
        return competition != null
                && competition.getStatus() != null
                && competition.getStatus() == 2
                && (competition.getSubmitDeadline() == null
                    || LocalDateTime.now().isBefore(competition.getSubmitDeadline()));
    }

    private boolean isCompetitionEnded(Competition competition) {
        return competition != null && competition.getStatus() != null && competition.getStatus() == 3;
    }

    private byte[] readPartBytes(Part part) throws IOException {
        try (InputStream input = part.getInputStream();
             ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = input.read(buffer)) != -1) {
                output.write(buffer, 0, bytesRead);
            }
            return output.toByteArray();
        }
    }

    private byte[] createThumbnail(byte[] imageData) throws IOException {
        BufferedImage source = ImageIO.read(new ByteArrayInputStream(imageData));
        if (source == null) {
            throw new IOException("无法读取上传图片");
        }

        int sourceWidth = source.getWidth();
        int sourceHeight = source.getHeight();
        int targetWidth = Math.min(sourceWidth, THUMBNAIL_MAX_WIDTH);
        int targetHeight = Math.max(1, (int) Math.round(sourceHeight * (targetWidth / (double) sourceWidth)));

        BufferedImage thumbnail = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics = thumbnail.createGraphics();
        try {
            graphics.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
            graphics.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            graphics.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            graphics.drawImage(source, 0, 0, targetWidth, targetHeight, java.awt.Color.WHITE, null);
        } finally {
            graphics.dispose();
        }

        ByteArrayOutputStream output = new ByteArrayOutputStream();
        ImageWriter writer = ImageIO.getImageWritersByFormatName("jpg").next();
        try (ImageOutputStream imageOutput = ImageIO.createImageOutputStream(output)) {
            writer.setOutput(imageOutput);
            ImageWriteParam params = writer.getDefaultWriteParam();
            if (params.canWriteCompressed()) {
                params.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                params.setCompressionQuality(THUMBNAIL_JPEG_QUALITY);
            }
            writer.write(null, new IIOImage(thumbnail, null, null), params);
        } finally {
            writer.dispose();
        }
        return output.toByteArray();
    }

    private int parsePage(HttpServletRequest request) {
        try {
            int p = Integer.parseInt(request.getParameter("page"));
            return Math.max(1, p);
        } catch (Exception e) {
            return 1;
        }
    }

    private boolean hasRole(HttpServletRequest request, String roleName) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        @SuppressWarnings("unchecked")
        List<Role> roles = (List<Role>) session.getAttribute("roles");
        if (roles == null) return false;
        for (Role role : roles) {
            if (roleName.equals(role.getRoleName())) return true;
        }
        return false;
    }

    private boolean isUserInCompetition(Integer userId, Integer competitionId) {
        if (userId == null || competitionId == null) return false;
        List<TeamMember> memberships = teamMemberDAO.findByUserId(userId);
        for (TeamMember member : memberships) {
            Team team = teamDAO.findById(member.getTeamId());
            if (team != null && competitionId.equals(team.getCompetitionId())
                    && team.getStatus() != null && team.getStatus() != 0) {
                return true;
            }
        }
        return false;
    }

    private boolean canViewWork(HttpServletRequest request, User user, Work work) {
        if (user == null || work == null) return false;
        boolean administrator = hasRole(request, "管理员");
        boolean judge = hasRole(request, "评委");
        boolean teamMember = teamService.isUserMemberOfTeam(user.getUserId(), work.getTeamId());
        Competition competition = competitionService.getCompetitionById(work.getCompetitionId());
        boolean ended = isCompetitionEnded(competition);
        boolean participantInCompetition = isUserInCompetition(user.getUserId(), work.getCompetitionId());
        return WorkAccessPolicy.canView(administrator, judge, teamMember, ended, participantInCompetition);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("add".equals(action)) {
            showAddForm(request, response);
        } else if ("edit".equals(action)) {
            showEditForm(request, response);
        } else if ("detail".equals(action)) {
            showDetail(request, response);
        } else if ("competitionWorks".equals(action)) {
            showCompetitionWorks(request, response);
        } else if ("delete".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/work?error=delete_requires_post");
        } else {
            listWorks(request, response);
        }
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

        if ("submit".equals(action)) {
            submitWork(request, response);
        } else if ("update".equals(action)) {
            updateWork(request, response);
        } else if ("like".equals(action)) {
            likeWork(request, response);
        } else if ("unlike".equals(action)) {
            unlikeWork(request, response);
        } else if ("share".equals(action)) {
            shareWork(request, response);
        } else if ("delete".equals(action)) {
            deleteWork(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/work");
        }
    }

    // ==================== 已提交的作品列表（含搜索） ====================

    private void listWorks(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        String keyword = request.getParameter("keyword");
        int page = parsePage(request);
        final int pageSize = 12;

        // collect user's team IDs for DB-level pagination
        List<TeamMember> memberships = teamMemberDAO.findByUserId(user.getUserId());
        List<Integer> teamIds = new ArrayList<>();
        Set<Integer> leaderTeamIds = new HashSet<>();
        for (TeamMember m : memberships) {
            teamIds.add(m.getTeamId());
            Team t = teamDAO.findById(m.getTeamId());
            if (t != null && t.getLeaderId() != null && t.getLeaderId().equals(user.getUserId())) {
                leaderTeamIds.add(t.getTeamId());
            }
        }

        long totalCount;
        List<Work> pagedWorks;
        int offset = (page - 1) * pageSize;

        if (keyword != null && !keyword.trim().isEmpty()) {
            totalCount = workDAO.countByTeamIdsAndKeyword(teamIds, keyword.trim());
            pagedWorks = workDAO.findByTeamIdsAndKeywordWithLimit(teamIds, keyword.trim(), offset, pageSize);
        } else {
            totalCount = workDAO.countByTeamIds(teamIds);
            pagedWorks = workDAO.findByTeamIdsWithLimit(teamIds, offset, pageSize);
        }
        PageInfo<Work> pageInfo = new PageInfo<>(pagedWorks, totalCount, page, pageSize);

        // 加载关联数据 (only for current page)
        Map<Integer, Team> teamMap = new HashMap<>();
        Map<Integer, Competition> compMap = new HashMap<>();
        Map<Integer, Integer> likeCountMap = new HashMap<>();
        Map<Integer, Integer> shareCountMap = new HashMap<>();
        Map<Integer, Boolean> likedMap = new HashMap<>();

        for (Work work : pagedWorks) {
            if (!teamMap.containsKey(work.getTeamId())) {
                Team t = teamDAO.findById(work.getTeamId());
                if (t != null) teamMap.put(work.getTeamId(), t);
            }
            if (work.getCompetitionId() != null && !compMap.containsKey(work.getCompetitionId())) {
                Competition c = competitionService.getCompetitionById(work.getCompetitionId());
                if (c != null) compMap.put(work.getCompetitionId(), c);
            }
            likeCountMap.put(work.getWorkId(), workService.getLikeCount(work.getWorkId()));
            shareCountMap.put(work.getWorkId(), workService.getShareCount(work.getWorkId()));
            likedMap.put(work.getWorkId(), workService.isWorkLikedByUser(work.getWorkId(), user.getUserId()));
        }

        request.setAttribute("pageInfo", pageInfo);
        request.setAttribute("teamMap", teamMap);
        request.setAttribute("compMap", compMap);
        request.setAttribute("likeCountMap", likeCountMap);
        request.setAttribute("shareCountMap", shareCountMap);
        request.setAttribute("likedMap", likedMap);
        request.setAttribute("leaderTeamIds", leaderTeamIds);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("/jsp/submission_list.jsp").forward(request, response);
    }

    // ==================== 提交作品表单（选择队伍） ====================

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        // 显示当前用户创建的队伍，并标记哪些队伍当前可提交作品
        List<Team> leaderTeams = teamService.getTeamsByLeaderId(user.getUserId());
        Set<Integer> submittedTeamIds = new HashSet<>();
        Set<Integer> ineligibleTeamIds = new HashSet<>();
        Map<Integer, String> ineligibleReasonMap = new HashMap<>();

        if (leaderTeams != null) {
            for (Team team : leaderTeams) {
                Competition competition = competitionService.getCompetitionById(team.getCompetitionId());
                if (team.getStatus() == null || team.getStatus() != 2) {
                    ineligibleTeamIds.add(team.getTeamId());
                    ineligibleReasonMap.put(team.getTeamId(), "队伍未报名");
                } else if (!isCompetitionRunningAndOpen(competition)) {
                    ineligibleTeamIds.add(team.getTeamId());
                    ineligibleReasonMap.put(team.getTeamId(), "竞赛未进行或已截止");
                }

                List<Work> existingWorks = workService.getWorksByTeamIdAndCompetitionId(team.getTeamId(), team.getCompetitionId());
                if (existingWorks != null && !existingWorks.isEmpty()) {
                    submittedTeamIds.add(team.getTeamId());
                    ineligibleTeamIds.add(team.getTeamId());
                    ineligibleReasonMap.put(team.getTeamId(), "已提交作品");
                }
            }
        }

        request.setAttribute("teams", leaderTeams);
        request.setAttribute("submittedTeamIds", submittedTeamIds);
        request.setAttribute("ineligibleTeamIds", ineligibleTeamIds);
        request.setAttribute("ineligibleReasonMap", ineligibleReasonMap);
        boolean hasEligible = false;
        if (leaderTeams != null) {
            for (Team team : leaderTeams) {
                if (ineligibleTeamIds == null || !ineligibleTeamIds.contains(team.getTeamId())) {
                    hasEligible = true;
                    break;
                }
            }
        }
        request.setAttribute("hasEligibleTeam", hasEligible);
        request.getRequestDispatcher("/jsp/submission_add.jsp").forward(request, response);
    }

    // ==================== 提交作品（POST） ====================

    private void submitWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        // 1. 验证队伍
        String teamIdStr = request.getParameter("teamId");
        if (teamIdStr == null || teamIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/work?action=add&error=no_team");
            return;
        }

        Integer teamId;
        try {
            teamId = Integer.parseInt(teamIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work?action=add&error=invalid_team");
            return;
        }

        Team team = teamDAO.findById(teamId);
        if (team == null) {
            response.sendRedirect(request.getContextPath() + "/work?action=add&error=team_not_found");
            return;
        }

        // 2. 权限验证：只有队长能提交
        if (!team.getLeaderId().equals(user.getUserId())) {
            response.sendRedirect(request.getContextPath() + "/work?action=add&error=permission_denied");
            return;
        }

        // 3. 验证队伍报名状态、竞赛状态和截止日期
        Competition competition = competitionService.getCompetitionById(team.getCompetitionId());
        if (team.getStatus() == null || team.getStatus() != 2) {
            response.sendRedirect(request.getContextPath() + "/work?action=add&error=team_not_registered");
            return;
        }
        if (!isCompetitionRunningAndOpen(competition)) {
            response.sendRedirect(request.getContextPath() + "/work?action=add&error=competition_not_open");
            return;
        }
        List<Work> existingWorks = workService.getWorksByTeamIdAndCompetitionId(teamId, team.getCompetitionId());
        if (existingWorks != null && !existingWorks.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/work?action=add&error=already_submitted");
            return;
        }

        // 4. 验证作品标题
        String title = request.getParameter("title");
        if (title == null || title.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/work?action=add&error=no_title");
            return;
        }

        // 6. 处理文件上传
        Part filePart = request.getPart("imageFile");
        String imagePath = null;
        String uploadRealPath = FileUploadUtil.getUploadBasePath();
        byte[] imageData = null;
        String imageContentType = null;
        byte[] thumbnailData = null;
        String thumbnailContentType = null;

        if (filePart != null && filePart.getSize() > 0) {
            String contentType = filePart.getContentType();
            if (!FileUploadUtil.isAllowedType(contentType)) {
                response.sendRedirect(request.getContextPath() + "/work?action=add&error=invalid_type");
                return;
            }
            if (!FileUploadUtil.isAllowedSize(filePart.getSize())) {
                response.sendRedirect(request.getContextPath() + "/work?action=add&error=file_too_large");
                return;
            }

            try {
                imageData = readPartBytes(filePart);
                imageContentType = contentType;
                thumbnailData = createThumbnail(imageData);
                thumbnailContentType = THUMBNAIL_CONTENT_TYPE;
                imagePath = FileUploadUtil.saveBytes(imageData,
                        filePart.getSubmittedFileName(), uploadRealPath,
                        team.getCompetitionId(), teamId);
            } catch (IOException e) {
                response.sendRedirect(request.getContextPath() + "/work?action=add&error=invalid_image");
                return;
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/work?action=add&error=no_image");
            return;
        }

        // 7. 构建作品对象
        Work work = new Work();
        work.setTeamId(teamId);
        work.setCompetitionId(team.getCompetitionId());
        work.setCategoryId(team.getCategoryId());
        work.setTitle(title.trim());
        work.setDescription(request.getParameter("description"));
        work.setImagePath(imagePath);
        work.setImageData(imageData);
        work.setImageContentType(imageContentType);
        work.setThumbnailData(thumbnailData);
        work.setThumbnailContentType(thumbnailContentType);
        work.setStatus(2); // 已提交

        boolean success = workService.submitWork(work);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/work?msg=submit_success");
        } else {
            FileUploadUtil.deleteFile(uploadRealPath, imagePath);
            response.sendRedirect(request.getContextPath() + "/work?action=add&error=submit_failed");
        }
    }

    // ==================== 作品详情 ====================

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/work");
            return;
        }

        try {
            Integer workId = Integer.parseInt(idStr);
            Work work = workService.getWorkById(workId);
            if (work == null) {
                response.sendRedirect(request.getContextPath() + "/work?error=not_found");
                return;
            }

            if (!canViewWork(request, user, work)) {
                response.setContentType("text/html;charset=UTF-8");
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "比赛结束后才可查看其他队伍的作品");
                return;
            }

            Team team = teamDAO.findById(work.getTeamId());
            boolean isMember = teamService.isUserMemberOfTeam(user.getUserId(), work.getTeamId());
            boolean isLeader = team != null && team.getLeaderId() != null && team.getLeaderId().equals(user.getUserId());
            Competition competition = competitionService.getCompetitionById(work.getCompetitionId());
            boolean canMutate = isLeader && isCompetitionRunningAndOpen(competition);
            int likeCount = workService.getLikeCount(workId);
            int shareCount = workService.getShareCount(workId);
            boolean liked = workService.isWorkLikedByUser(workId, user.getUserId());

            request.setAttribute("work", work);
            request.setAttribute("team", team);
            request.setAttribute("competition", competition);
            request.setAttribute("likeCount", likeCount);
            request.setAttribute("shareCount", shareCount);
            request.setAttribute("liked", liked);
            request.setAttribute("isLeader", canMutate);
            request.setAttribute("isOwnTeam", isMember);
            request.setAttribute("readOnlyView", !canMutate);
            request.setAttribute("attachments", workFileDAO.findByWorkId(workId));
            request.getRequestDispatcher("/jsp/submission_detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work");
        }
    }

    // ==================== 编辑作品表单 ====================

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/work");
            return;
        }

        try {
            Integer workId = Integer.parseInt(idStr);
            Work work = workService.getWorkById(workId);
            if (work == null) {
                response.sendRedirect(request.getContextPath() + "/work?error=not_found");
                return;
            }

            // 权限验证：只有队长能编辑
            Team team = teamDAO.findById(work.getTeamId());
            if (team == null || !team.getLeaderId().equals(user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/work?error=permission_denied");
                return;
            }

            Competition competition = competitionService.getCompetitionById(work.getCompetitionId());
            if (!isCompetitionRunningAndOpen(competition)) {
                response.sendRedirect(request.getContextPath() + "/work?action=detail&id=" + workId + "&error=competition_not_open");
                return;
            }

            request.setAttribute("work", work);
            request.setAttribute("team", team);
            request.setAttribute("competition", competition);
            request.getRequestDispatcher("/jsp/submission_add.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work");
        }
    }

    // ==================== 更新作品（POST） ====================

    private void updateWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String workIdStr = request.getParameter("workId");
        if (workIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/work");
            return;
        }

        try {
            Integer workId = Integer.parseInt(workIdStr);
            Work existingWork = workService.getWorkById(workId);
            if (existingWork == null) {
                response.sendRedirect(request.getContextPath() + "/work?error=not_found");
                return;
            }

            // 权限验证：只有队长能修改
            Team team = teamDAO.findById(existingWork.getTeamId());
            if (team == null || !team.getLeaderId().equals(user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/work?error=permission_denied");
                return;
            }

            // 截止日期验证.
            Competition competition = competitionService.getCompetitionById(existingWork.getCompetitionId());
            if (competition != null && competition.getSubmitDeadline() != null
                    && LocalDateTime.now().isAfter(competition.getSubmitDeadline())) {
                response.sendRedirect(request.getContextPath() + "/work?action=detail&id=" + workId + "&error=deadline_passed");
                return;
            }

            // 检查竞赛状态：已结束、已取消或截止后不可修改作品
            competition = competitionService.getCompetitionById(existingWork.getCompetitionId());
            if (!isCompetitionRunningAndOpen(competition)) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=competition_not_open");
                return;
            }

            // 更新标题
            String title = request.getParameter("title");
            if (title != null && !title.trim().isEmpty()) {
                existingWork.setTitle(title.trim());
            }

            // 更新描述
            existingWork.setDescription(request.getParameter("description"));

            // 处理新图片上传
            Part filePart = request.getPart("imageFile");
            String newImagePath = null;
            if (filePart != null && filePart.getSize() > 0) {
                String oldImagePath = existingWork.getImagePath();
                String contentType = filePart.getContentType();
                if (!FileUploadUtil.isAllowedType(contentType)) {
                    response.sendRedirect(request.getContextPath() + "/work?action=edit&id=" + workId + "&error=invalid_type");
                    return;
                }
                if (!FileUploadUtil.isAllowedSize(filePart.getSize())) {
                    response.sendRedirect(request.getContextPath() + "/work?action=edit&id=" + workId + "&error=file_too_large");
                    return;
                }

                String uploadRealPath = FileUploadUtil.getUploadBasePath();
                try {
                    byte[] imageData = readPartBytes(filePart);
                    byte[] thumbnailData = createThumbnail(imageData);
                    newImagePath = FileUploadUtil.saveBytes(imageData,
                            filePart.getSubmittedFileName(), uploadRealPath,
                            team.getCompetitionId(), team.getTeamId());
                    existingWork.setImagePath(newImagePath);
                    existingWork.setImageData(imageData);
                    existingWork.setImageContentType(contentType);
                    existingWork.setThumbnailData(thumbnailData);
                    existingWork.setThumbnailContentType(THUMBNAIL_CONTENT_TYPE);
                } catch (IOException e) {
                    response.sendRedirect(request.getContextPath() + "/work?action=edit&id=" + workId + "&error=invalid_image");
                    return;
                }

                boolean success = workService.updateWork(existingWork);
                if (success) {
                    FileUploadUtil.deleteFile(uploadRealPath, oldImagePath);
                    response.sendRedirect(request.getContextPath() + "/work?action=detail&id=" + workId + "&msg=update_success");
                } else {
                    FileUploadUtil.deleteFile(uploadRealPath, newImagePath);
                    response.sendRedirect(request.getContextPath() + "/work?action=edit&id=" + workId + "&error=update_failed");
                }
                return;
            }

            boolean success = workService.updateWork(existingWork);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/work?action=detail&id=" + workId + "&msg=update_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/work?action=edit&id=" + workId + "&error=update_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work");
        }
    }

    private void showCompetitionWorks(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        Integer competitionId;
        try {
            competitionId = Integer.parseInt(request.getParameter("competitionId"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/competition?action=list");
            return;
        }

        Competition competition = competitionService.getCompetitionById(competitionId);
        if (competition == null) {
            response.sendRedirect(request.getContextPath() + "/competition?action=list&error=not_found");
            return;
        }

        boolean privileged = hasRole(request, "管理员") || hasRole(request, "评委");
        if (!privileged && !isCompetitionEnded(competition)) {
            response.setContentType("text/html;charset=UTF-8");
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "比赛进行中，结束后才可查看该比赛作品");
            return;
        }

        int page = parsePage(request);
        final int pageSize = 12;
        long totalCount = workDAO.countByCompetitionId(competitionId);
        int offset = (page - 1) * pageSize;
        List<Work> works = workDAO.findByCompetitionIdWithLimit(competitionId, offset, pageSize);
        PageInfo<Work> pageInfo = new PageInfo<>(works, totalCount, page, pageSize);

        Map<Integer, Team> teamMap = new HashMap<>();
        Map<Integer, Integer> likeCountMap = new HashMap<>();
        for (Work work : works) {
            if (work.getStatus() != null && (work.getStatus() == 2 || work.getStatus() == 3)) {
                Team team = teamDAO.findById(work.getTeamId());
                if (team != null) teamMap.put(work.getTeamId(), team);
                likeCountMap.put(work.getWorkId(), workService.getLikeCount(work.getWorkId()));
            }
        }
        request.setAttribute("competition", competition);
        request.setAttribute("pageInfo", pageInfo);
        request.setAttribute("teamMap", teamMap);
        request.setAttribute("likeCountMap", likeCountMap);
        request.getRequestDispatcher("/jsp/competition_works.jsp").forward(request, response);
    }

    // ==================== 删除作品 ====================

    private void deleteWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/work");
            return;
        }

        try {
            Integer workId = Integer.parseInt(idStr);
            Work work = workService.getWorkById(workId);
            if (work == null) {
                response.sendRedirect(request.getContextPath() + "/work?error=not_found");
                return;
            }

            // 权限验证：只有队长能删除，且仅限竞赛进行中且未截止
            Team team = teamDAO.findById(work.getTeamId());
            if (team == null || !team.getLeaderId().equals(user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/work?error=permission_denied");
                return;
            }
            Competition competition = competitionService.getCompetitionById(work.getCompetitionId());
            if (!isCompetitionRunningAndOpen(competition)) {
                response.sendRedirect(request.getContextPath() + "/work?action=detail&id=" + workId + "&error=competition_not_open");
                return;
            }

            boolean success = workService.deleteWork(workId, work.getTeamId());
            if (success) {
                if (work.getImagePath() != null) {
                    FileUploadUtil.deleteFile(FileUploadUtil.getUploadBasePath(), work.getImagePath());
                }
                response.sendRedirect(request.getContextPath() + "/work?msg=delete_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/work?error=delete_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work");
        }
    }
    private void likeWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        String workIdStr = request.getParameter("workId");
        if (workIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/work");
            return;
        }
        try {
            Integer workId = Integer.parseInt(workIdStr);
            Work work = workService.getWorkById(workId);
            if (!canViewWork(request, user, work)) {
                response.setContentType("text/html;charset=UTF-8");
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "无权操作该作品");
                return;
            }
            workService.likeWork(workId, user.getUserId());
            response.sendRedirect(request.getContextPath() + "/work");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work");
        }
    }

    private void unlikeWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        String workIdStr = request.getParameter("workId");
        if (workIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/work");
            return;
        }
        try {
            Integer workId = Integer.parseInt(workIdStr);
            Work work = workService.getWorkById(workId);
            if (!canViewWork(request, user, work)) {
                response.setContentType("text/html;charset=UTF-8");
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "无权操作该作品");
                return;
            }
            workService.unlikeWork(workId, user.getUserId());
            response.sendRedirect(request.getContextPath() + "/work");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work");
        }
    }

    private void shareWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        String workIdStr = request.getParameter("workId");
        if (workIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/work?error=not_found");
            return;
        }
        try {
            Integer workId = Integer.parseInt(workIdStr);
            Work work = workService.getWorkById(workId);
            if (work == null) {
                response.sendRedirect(request.getContextPath() + "/work?error=not_found");
                return;
            }
            if (!canViewWork(request, user, work)) {
                response.setContentType("text/html;charset=UTF-8");
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "无权分享该作品");
                return;
            }
            String platform = SharePolicy.normalizePlatform(request.getParameter("platform"));
            if (platform == null || !workService.shareWork(workId, user.getUserId(), platform)) {
                response.sendRedirect(request.getContextPath() + "/work?action=detail&id=" + workId + "&error=share_failed");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/work?action=detail&id=" + workId + "&msg=share_success");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work?error=not_found");
        }
    }

}
