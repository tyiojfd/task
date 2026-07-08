package com.poster.controller;

import com.poster.dao.WorkDAO;
import com.poster.dao.impl.WorkDAOImpl;
import com.poster.model.Comment;
import com.poster.model.User;
import com.poster.model.Work;
import com.poster.service.CommentService;
import com.poster.service.impl.CommentServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

/**
 * 评语Servlet
 * @author 队员C
 * @date 2026-07-08
 */
@WebServlet("/comment")
public class CommentServlet extends HttpServlet {

    private CommentService commentService = new CommentServiceImpl();
    private WorkDAO workDAO = new WorkDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("list".equals(action)) {
            // 查看某作品的所有评语
            showCommentsByWork(request, response);
        } else if ("myComments".equals(action)) {
            // 我的评语记录
            showMyComments(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            // 添加评语
            addComment(request, response);
        } else if ("update".equals(action)) {
            // 更新评语
            updateComment(request, response);
        } else if ("delete".equals(action)) {
            // 删除评语
            deleteComment(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }

    /**
     * 查看某作品的所有评语
     */
    private void showCommentsByWork(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String workIdStr = request.getParameter("workId");
        if (workIdStr == null || workIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
            return;
        }

        try {
            Integer workId = Integer.parseInt(workIdStr);
            Work work = workDAO.findById(workId);
            if (work == null) {
                response.sendRedirect(request.getContextPath() + "/score?action=list");
                return;
            }

            List<Comment> comments = commentService.getCommentsByWorkId(workId);
            request.setAttribute("work", work);
            request.setAttribute("comments", comments);

            // 检查当前用户是否已添加评语
            HttpSession session = request.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                User user = (User) session.getAttribute("user");
                boolean hasCommented = false;
                for (Comment c : comments) {
                    if (c.getJudgeId().equals(user.getUserId())) {
                        hasCommented = true;
                        request.setAttribute("myComment", c);
                        break;
                    }
                }
                request.setAttribute("hasCommented", hasCommented);
            }

            request.getRequestDispatcher("/jsp/score_input.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }

    /**
     * 我的评语记录
     */
    private void showMyComments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        List<Comment> myComments = commentService.getCommentsByJudgeId(user.getUserId());

        request.setAttribute("myComments", myComments);
        request.setAttribute("workDAO", workDAO);

        request.getRequestDispatcher("/jsp/score_list.jsp").forward(request, response);
    }

    /**
     * 添加评语
     */
    private void addComment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            Integer workId = Integer.parseInt(request.getParameter("workId"));
            String commentText = request.getParameter("commentText");

            Comment comment = new Comment();
            comment.setWorkId(workId);
            comment.setJudgeId(user.getUserId());
            comment.setCommentText(commentText);

            boolean success = commentService.addComment(comment);

            if (success) {
                request.getSession().setAttribute("message", "评语添加成功！");
            } else {
                request.getSession().setAttribute("error", "评语添加失败，请检查内容是否为空");
            }
            response.sendRedirect(request.getContextPath() + "/score?action=input&workId=" + workId);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }

    /**
     * 更新评语
     */
    private void updateComment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            Integer commentId = Integer.parseInt(request.getParameter("commentId"));
            String commentText = request.getParameter("commentText");
            String workIdStr = request.getParameter("workId");

            Comment comment = new Comment();
            comment.setCommentId(commentId);
            comment.setCommentText(commentText);

            boolean success = commentService.updateComment(comment);

            if (success) {
                request.getSession().setAttribute("message", "评语更新成功！");
            } else {
                request.getSession().setAttribute("error", "评语更新失败");
            }

            if (workIdStr != null && !workIdStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/score?action=input&workId=" + workIdStr);
            } else {
                response.sendRedirect(request.getContextPath() + "/score?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }

    /**
     * 删除评语
     */
    private void deleteComment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            Integer commentId = Integer.parseInt(request.getParameter("commentId"));
            String workIdStr = request.getParameter("workId");

            boolean success = commentService.deleteComment(commentId);

            if (success) {
                request.getSession().setAttribute("message", "评语删除成功！");
            } else {
                request.getSession().setAttribute("error", "评语删除失败");
            }

            if (workIdStr != null && !workIdStr.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/score?action=input&workId=" + workIdStr);
            } else {
                response.sendRedirect(request.getContextPath() + "/score?action=list");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/score?action=list");
        }
    }
}
