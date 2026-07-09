package com.poster.controller;

import com.poster.model.*;
import com.poster.service.*;
import com.poster.service.impl.*;
import com.poster.util.FileUploadUtil;
import java.util.*;
import com.poster.dao.*;
import com.poster.dao.impl.*;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
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

    private static final String UPLOAD_BASE = "uploads";

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
        } else if ("delete".equals(action)) {
            deleteWork(request, response);
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

        List<Work> works;
        if (keyword != null && !keyword.trim().isEmpty()) {
            works = workService.searchWorksByUserTeams(user.getUserId(), keyword.trim());
        } else {
            works = workService.getWorksByUserId(user.getUserId());
        }

        // 加载关联数据
        Map<Integer, Team> teamMap = new HashMap<>();
        Map<Integer, Competition> compMap = new HashMap<>();
        Map<Integer, Integer> likeCountMap = new HashMap<>();
        Map<Integer, Boolean> likedMap = new HashMap<>();
        List<Integer> userTeamIds = new ArrayList<>();

        List<TeamMember> memberships = teamMemberDAO.findByUserId(user.getUserId());
        for (TeamMember m : memberships) {
            userTeamIds.add(m.getTeamId());
        }

        // 找出用户是队长的队伍ID集合
        Set<Integer> leaderTeamIds = new HashSet<>();
        for (TeamMember m : memberships) {
            Team t = teamDAO.findById(m.getTeamId());
            if (t != null && t.getLeaderId() != null && t.getLeaderId().equals(user.getUserId())) {
                leaderTeamIds.add(t.getTeamId());
            }
        }

        for (Work work : works) {
            if (!teamMap.containsKey(work.getTeamId())) {
                Team t = teamDAO.findById(work.getTeamId());
                if (t != null) teamMap.put(work.getTeamId(), t);
            }
            if (work.getCompetitionId() != null && !compMap.containsKey(work.getCompetitionId())) {
                Competition c = competitionService.getCompetitionById(work.getCompetitionId());
                if (c != null) compMap.put(work.getCompetitionId(), c);
            }
            likeCountMap.put(work.getWorkId(), workService.getLikeCount(work.getWorkId()));
            likedMap.put(work.getWorkId(), workService.isWorkLikedByUser(work.getWorkId(), user.getUserId()));
        }

        request.setAttribute("works", works);
        request.setAttribute("teamMap", teamMap);
        request.setAttribute("compMap", compMap);
        request.setAttribute("likeCountMap", likeCountMap);
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

        // 显示当前用户创建的所有队伍（含未报名）
        List<Team> leaderTeams = teamService.getTeamsByLeaderId(user.getUserId());

        request.setAttribute("teams", leaderTeams);
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

        // 3. 验证截止日期
        Competition competition = competitionService.getCompetitionById(team.getCompetitionId());
        if (competition != null && competition.getSubmitDeadline() != null
                && LocalDateTime.now().isAfter(competition.getSubmitDeadline())) {
            response.sendRedirect(request.getContextPath() + "/work?action=add&error=deadline_passed");
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
        byte[] imageData = null;
        String imageContentType = null;

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

            // 保存到文件系统
            String uploadRealPath = getServletContext().getRealPath("/" + FileUploadUtil.STORAGE_DIR);
            try {
                imagePath = FileUploadUtil.saveFile(filePart, uploadRealPath, team.getCompetitionId(), teamId);
            } catch (IOException e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/work?action=add&error=upload_failed");
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
        work.setStatus(2); // 已提交

        boolean success = workService.submitWork(work);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/work?msg=submit_success");
        } else {
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

            // 权限验证：非本队成员不能查看
            List<TeamMember> memberships = teamMemberDAO.findByUserId(user.getUserId());
            boolean isMember = false;
            boolean isLeader = false;
            for (TeamMember m : memberships) {
                if (m.getTeamId().equals(work.getTeamId())) {
                    isMember = true;
                    Team t = teamDAO.findById(m.getTeamId());
                    if (t != null && t.getLeaderId().equals(user.getUserId())) {
                        isLeader = true;
                    }
                    break;
                }
            }
            if (!isMember) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "无权查看其他队伍的作品");
                return;
            }

            Team team = teamDAO.findById(work.getTeamId());
            Competition competition = competitionService.getCompetitionById(work.getCompetitionId());
            int likeCount = workService.getLikeCount(workId);
            boolean liked = workService.isWorkLikedByUser(workId, user.getUserId());

            request.setAttribute("work", work);
            request.setAttribute("team", team);
            request.setAttribute("competition", competition);
            request.setAttribute("likeCount", likeCount);
            request.setAttribute("liked", liked);
            request.setAttribute("isLeader", isLeader);
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

            // 截止日期验证
            Competition competition = competitionService.getCompetitionById(work.getCompetitionId());
            if (competition != null && competition.getSubmitDeadline() != null
                    && LocalDateTime.now().isAfter(competition.getSubmitDeadline())) {
                response.sendRedirect(request.getContextPath() + "/work?action=detail&id=" + workId + "&error=deadline_passed");
                return;
            }
            Integer competitionId = team.getCompetitionId();

            // 校验竞赛状态：必须为"进行中"且未过截止日期
            competition = competitionService.getCompetitionById(competitionId);
            if (competition != null) {
                if (competition.getStatus() == null || competition.getStatus() != 2) {
                    request.setAttribute("error", "竞赛已结束或已取消，无法提交作品");
                    showAddForm(request, response);
                    return;
                }
                if (competition.getSubmitDeadline() != null
                        && LocalDateTime.now().isAfter(competition.getSubmitDeadline())) {
                    request.setAttribute("error", "提交已截止，无法提交作品");
                    showAddForm(request, response);
                    return;
                }
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

            // 截止日期验证
            Competition competition = competitionService.getCompetitionById(existingWork.getCompetitionId());
            if (competition != null && competition.getSubmitDeadline() != null
                    && LocalDateTime.now().isAfter(competition.getSubmitDeadline())) {
                response.sendRedirect(request.getContextPath() + "/work?action=detail&id=" + workId + "&error=deadline_passed");
                return;
            }

            // 检查竞赛状态：已结束或已取消的竞赛不可修改作品
            competition = competitionService.getCompetitionById(existingWork.getCompetitionId());
            if (competition != null) {
                if (competition.getStatus() == null || competition.getStatus() != 2) {
                    response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=competition_ended");
                    return;
                }
                if (competition.getSubmitDeadline() != null
                        && LocalDateTime.now().isAfter(competition.getSubmitDeadline())) {
                    response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=deadline_passed");
                    return;
                }
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
            if (filePart != null && filePart.getSize() > 0) {
                String contentType = filePart.getContentType();
                if (!FileUploadUtil.isAllowedType(contentType)) {
                    response.sendRedirect(request.getContextPath() + "/work?action=edit&id=" + workId + "&error=invalid_type");
                    return;
                }
                if (!FileUploadUtil.isAllowedSize(filePart.getSize())) {
                    response.sendRedirect(request.getContextPath() + "/work?action=edit&id=" + workId + "&error=file_too_large");
                    return;
                }

                // 删除旧图片
                if (existingWork.getImagePath() != null) {
                    String uploadRealPath = getServletContext().getRealPath("/" + FileUploadUtil.STORAGE_DIR);
                    FileUploadUtil.deleteFile(uploadRealPath, existingWork.getImagePath());
                }

                // 保存新图片
                String uploadRealPath = getServletContext().getRealPath("/" + FileUploadUtil.STORAGE_DIR);
                String imagePath = FileUploadUtil.saveFile(filePart, uploadRealPath, team.getCompetitionId(), team.getTeamId());
                existingWork.setImagePath(imagePath);
                existingWork.setImageData(null);
                existingWork.setImageContentType(contentType);
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

            // 权限验证：只有队长能删除
            Team team = teamDAO.findById(work.getTeamId());
            if (team == null || !team.getLeaderId().equals(user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/work?error=permission_denied");
                return;
            }


            if (work.getImagePath() != null) {
                String uploadRealPath = getServletContext().getRealPath("/" + FileUploadUtil.STORAGE_DIR);
                FileUploadUtil.deleteFile(uploadRealPath, work.getImagePath());
            }

            boolean success = workService.deleteWork(workId, work.getTeamId());
            if (success) {
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
            workService.unlikeWork(workId, user.getUserId());
            response.sendRedirect(request.getContextPath() + "/work");
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work");
        }
    }

}