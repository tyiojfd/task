package com.poster.controller;

import com.poster.model.*;
import com.poster.service.*;
import com.poster.service.impl.*;
import com.poster.util.FileUploadUtil;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;

/**
 * 作品Servlet
 * @author 队员B
 * @date 2026-07-06
 */
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
    private ScoreService scoreService = new ScoreServiceImpl();
    private CommentService commentService = new CommentServiceImpl();
    private AwardService awardService = new AwardServiceImpl();
    private CertificateService certificateService = new CertificateServiceImpl();
    private com.poster.dao.CategoryDAO categoryDAO = new com.poster.dao.impl.CategoryDAOImpl();
    private com.poster.dao.UserDAO userDAO = new com.poster.dao.impl.UserDAOImpl();
    private com.poster.dao.TeamMemberDAO teamMemberDAO = new com.poster.dao.impl.TeamMemberDAOImpl();
    private com.poster.dao.TeamDAO teamDAO = new com.poster.dao.impl.TeamDAOImpl();

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
            listMyWorks(request, response);
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
        } else if ("delete".equals(action)) {
            deleteWork(request, response);
        } else if ("like".equals(action)) {
            likeWork(request, response);
        } else if ("unlike".equals(action)) {
            unlikeWork(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks");
        }
    }

    /**
     * 显示"我的作品"列表
     */
    private void listMyWorks(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        List<TeamMember> memberships = teamMemberDAO.findByUserId(user.getUserId());
        List<Team> myTeams = new ArrayList<>();
        List<Integer> leaderTeamIds = new ArrayList<>();
        for (TeamMember m : memberships) {
            Team t = teamDAO.findById(m.getTeamId());
            if (t != null && t.getStatus() != null && t.getStatus() != 0) {
                myTeams.add(t);
                if (t.getLeaderId() != null && t.getLeaderId().equals(user.getUserId()) && t.getStatus() == 2) {
                    leaderTeamIds.add(t.getTeamId());
                }
            }
        }

        List<Work> works = workService.getWorksByUserId(user.getUserId());

        Map<Integer, String> teamNameMap = new HashMap<>();
        Map<Integer, String> competitionNameMap = new HashMap<>();

        for (Team team : myTeams) {
            teamNameMap.put(team.getTeamId(), team.getTeamName());
        }

        for (Work work : works) {
            if (work.getCompetitionId() != null && !competitionNameMap.containsKey(work.getCompetitionId())) {
                Competition comp = competitionService.getCompetitionById(work.getCompetitionId());
                if (comp != null) {
                    competitionNameMap.put(work.getCompetitionId(), comp.getName());
                }
            }
            if (!teamNameMap.containsKey(work.getTeamId())) {
                Team t = teamDAO.findById(work.getTeamId());
                if (t != null) {
                    teamNameMap.put(work.getTeamId(), t.getTeamName());
                }
            }
        }

        request.setAttribute("works", works);
        request.setAttribute("myTeams", myTeams);
        request.setAttribute("leaderTeamIds", leaderTeamIds);
        request.setAttribute("teamNameMap", teamNameMap);
        request.setAttribute("competitionNameMap", competitionNameMap);
        request.getRequestDispatcher("/jsp/submission_list.jsp").forward(request, response);
    }

    /**
     * 显示作品提交表单
     */
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String teamIdStr = request.getParameter("teamId");
        if (teamIdStr == null || teamIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks");
            return;
        }

        try {
            Integer teamId = Integer.parseInt(teamIdStr);
            Team team = teamService.getTeamById(teamId);
            if (team == null) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=team_not_found");
                return;
            }

            if (!team.getLeaderId().equals(user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=not_leader");
                return;
            }

            Competition competition = competitionService.getCompetitionById(team.getCompetitionId());
            List<com.poster.model.CompetitionCategory> categories = categoryDAO.findByCompetitionId(team.getCompetitionId());

            List<Work> existingWorks = workService.getWorksByTeamId(teamId);
            Work existingWork = null;
            for (Work w : existingWorks) {
                if (w.getStatus() >= 2) {
                    existingWork = w;
                    break;
                }
            }

            request.setAttribute("team", team);
            request.setAttribute("competition", competition);
            request.setAttribute("categories", categories);
            request.setAttribute("existingWork", existingWork);
            request.getRequestDispatcher("/jsp/submission_add.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=invalid_team");
        }
    }

    /**
     * 显示作品编辑表单
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks");
            return;
        }

        try {
            Integer workId = Integer.parseInt(idStr);
            Work work = workService.getWorkById(workId);
            if (work == null) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=work_not_found");
                return;
            }

            Team team = teamService.getTeamById(work.getTeamId());
            if (team == null || !team.getLeaderId().equals(user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=permission_denied");
                return;
            }

            Competition competition = competitionService.getCompetitionById(work.getCompetitionId());
            List<com.poster.model.CompetitionCategory> categories =
                    categoryDAO.findByCompetitionId(work.getCompetitionId());

            request.setAttribute("work", work);
            request.setAttribute("team", team);
            request.setAttribute("competition", competition);
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/jsp/submission_add.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=invalid_id");
        }
    }

    /**
     * 显示作品详情
     */
    private void showDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks");
            return;
        }

        try {
            Integer workId = Integer.parseInt(idStr);
            Work work = workService.getWorkById(workId);
            if (work == null) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=work_not_found");
                return;
            }

            Team team = teamService.getTeamById(work.getTeamId());
            if (team == null || !teamService.isUserMemberOfTeam(user.getUserId(), team.getTeamId())) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=permission_denied");
                return;
            }

            Competition competition = competitionService.getCompetitionById(work.getCompetitionId());

            // 加载评分数据
            List<Score> scores = scoreService.getScoresByWorkId(workId);
            Double avgScore = scoreService.getAverageScore(workId);

            // 加载评语数据
            List<Comment> comments = commentService.getCommentsByWorkId(workId);

            // 加载获奖数据
            Award award = awardService.getAwardByWorkId(workId);
            Certificate certificate = null;
            if (award != null) {
                certificate = certificateService.getCertificateByAwardId(award.getAwardId());
            }

            request.setAttribute("work", work);
            request.setAttribute("team", team);
            request.setAttribute("competition", competition);
            request.setAttribute("scores", scores);
            request.setAttribute("avgScore", avgScore);
            request.setAttribute("comments", comments);
            request.setAttribute("award", award);
            request.setAttribute("certificate", certificate);
            request.getRequestDispatcher("/jsp/submission_detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=invalid_id");
        }
    }

    /**
     * 提交新作品
     */
    private void submitWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        try {
            String teamIdStr = request.getParameter("teamId");
            String categoryIdStr = request.getParameter("categoryId");
            String title = request.getParameter("title");
            String description = request.getParameter("description");

            if (teamIdStr == null || title == null || title.trim().isEmpty()) {
                request.setAttribute("error", "请填写必要信息");
                showAddForm(request, response);
                return;
            }

            Integer teamId = Integer.parseInt(teamIdStr);

            Team team = teamService.getTeamById(teamId);
            if (team == null || !team.getLeaderId().equals(user.getUserId())) {
                request.setAttribute("error", "只有队长可以提交作品");
                showAddForm(request, response);
                return;
            }
            if (team.getStatus() == null || team.getStatus() != 2) {
                request.setAttribute("error", "队伍报名参赛后才能提交作品");
                showAddForm(request, response);
                return;
            }

            Integer competitionId = team.getCompetitionId();

            // 校验截止日期
            Competition competition = competitionService.getCompetitionById(competitionId);
            if (competition != null && competition.getSubmitDeadline() != null
                    && LocalDateTime.now().isAfter(competition.getSubmitDeadline())) {
                request.setAttribute("error", "提交已截止，无法提交作品");
                showAddForm(request, response);
                return;
            }

            // 处理文件上传
            Part filePart = request.getPart("imageFile");
            String imagePath = null;
            byte[] imageData = null;
            String imageContentType = null;

            if (filePart != null && filePart.getSize() > 0) {
                String uploadRealPath = getServletContext().getRealPath("/" + FileUploadUtil.STORAGE_DIR);
                imagePath = "/uploads" + FileUploadUtil.saveFile(filePart, uploadRealPath, competitionId, teamId);

                // 读取图片二进制数据保存到数据库
                imageContentType = filePart.getContentType();
                try (java.io.InputStream inputStream = filePart.getInputStream();
                     java.io.ByteArrayOutputStream outputStream = new java.io.ByteArrayOutputStream()) {
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        outputStream.write(buffer, 0, bytesRead);
                    }
                    imageData = outputStream.toByteArray();
                } catch (java.io.IOException e) {
                    e.printStackTrace();
                }
            } else {
                request.setAttribute("error", "请上传海报图片");
                showAddForm(request, response);
                return;
            }

            Work work = new Work();
            work.setTeamId(teamId);
            work.setCompetitionId(competitionId);
            if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                work.setCategoryId(Integer.parseInt(categoryIdStr));
            }
            work.setTitle(title.trim());
            work.setDescription(description != null ? description.trim() : null);
            work.setImagePath(imagePath);
            work.setImageData(imageData);
            work.setImageContentType(imageContentType);

            boolean success = workService.submitWork(work);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&msg=submit_success");
            } else {
                request.setAttribute("error", "作品提交失败，请重试");
                showAddForm(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "提交作品时发生错误：" + e.getMessage());
            showAddForm(request, response);
        }
    }

    /**
     * 更新作品
     */
    private void updateWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        try {
            String workIdStr = request.getParameter("workId");
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String categoryIdStr = request.getParameter("categoryId");

            if (workIdStr == null || title == null || title.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=invalid_input");
                return;
            }

            Integer workId = Integer.parseInt(workIdStr);
            Work existingWork = workService.getWorkById(workId);
            if (existingWork == null) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=work_not_found");
                return;
            }

            Team team = teamService.getTeamById(existingWork.getTeamId());
            if (team == null || !team.getLeaderId().equals(user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=permission_denied");
                return;
            }

            Part filePart = request.getPart("imageFile");
            String imagePath = existingWork.getImagePath();
            byte[] imageData = existingWork.getImageData();
            String imageContentType = existingWork.getImageContentType();

            if (filePart != null && filePart.getSize() > 0) {
                String uploadRealPath = getServletContext().getRealPath("/" + FileUploadUtil.STORAGE_DIR);
                if (existingWork.getImagePath() != null) {
                    FileUploadUtil.deleteFile(uploadRealPath, existingWork.getImagePath());
                }
                imagePath = "/uploads" + FileUploadUtil.saveFile(filePart, uploadRealPath,
                        existingWork.getCompetitionId(), existingWork.getTeamId());

                // 读取新图片二进制数据
                imageContentType = filePart.getContentType();
                try (java.io.InputStream inputStream = filePart.getInputStream();
                     java.io.ByteArrayOutputStream outputStream = new java.io.ByteArrayOutputStream()) {
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        outputStream.write(buffer, 0, bytesRead);
                    }
                    imageData = outputStream.toByteArray();
                } catch (java.io.IOException e) {
                    e.printStackTrace();
                }
            }

            existingWork.setTitle(title.trim());
            existingWork.setDescription(description != null ? description.trim() : null);
            if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                existingWork.setCategoryId(Integer.parseInt(categoryIdStr));
            }
            existingWork.setImagePath(imagePath);
            existingWork.setImageData(imageData);
            existingWork.setImageContentType(imageContentType);

            boolean success = workService.updateWork(existingWork);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&msg=update_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/work?action=edit&id=" + workId + "&error=update_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=update_error");
        }
    }

    /**
     * 删除作品
     */
    private void deleteWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks");
            return;
        }

        try {
            Integer workId = Integer.parseInt(idStr);
            Work work = workService.getWorkById(workId);
            if (work == null) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=work_not_found");
                return;
            }

            Team team = teamService.getTeamById(work.getTeamId());
            Competition competition = competitionService.getCompetitionById(work.getCompetitionId());

            if (team == null || !team.getLeaderId().equals(user.getUserId())) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=permission_denied");
                return;
            }

            // 截止日期后禁用删除
            if (competition != null && competition.getSubmitDeadline() != null
                    && LocalDateTime.now().isAfter(competition.getSubmitDeadline())) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=deadline_passed");
                return;
            }

            if (work.getImagePath() != null) {
                String uploadRealPath = getServletContext().getRealPath("/" + FileUploadUtil.STORAGE_DIR);
                FileUploadUtil.deleteFile(uploadRealPath, work.getImagePath());
            }

            boolean success = workService.deleteWork(workId, work.getTeamId());
            if (success) {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&msg=delete_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=delete_failed");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks&error=invalid_id");
        }
    }

    /**
     * 点赞作品
     */
    private void likeWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String workIdStr = request.getParameter("workId");
        if (workIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks");
            return;
        }

        try {
            Integer workId = Integer.parseInt(workIdStr);
            workService.likeWork(workId, user.getUserId());
            response.sendRedirect(request.getContextPath() + "/work?action=detail&id=" + workId);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks");
        }
    }

    /**
     * 取消点赞
     */
    private void unlikeWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        String workIdStr = request.getParameter("workId");
        if (workIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks");
            return;
        }

        try {
            Integer workId = Integer.parseInt(workIdStr);
            workService.unlikeWork(workId, user.getUserId());
            response.sendRedirect(request.getContextPath() + "/work?action=detail&id=" + workId);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/work?action=myWorks");
        }
    }
}
