package com.poster.service.impl;

import com.poster.dao.CommentDAO;
import com.poster.dao.impl.CommentDAOImpl;
import com.poster.model.Comment;
import com.poster.service.CommentService;

import java.util.List;

/**
 * 评语服务实现类
 * @author 队员C
 * @date 2026-07-08
 */
public class CommentServiceImpl implements CommentService {

    private CommentDAO commentDAO = new CommentDAOImpl();

    @Override
    public boolean addComment(Comment comment) {
        // 1. 验证必要字段
        if (comment.getWorkId() == null || comment.getJudgeId() == null) {
            return false;
        }

        // 2. 验证评语内容不为空
        if (comment.getCommentText() == null || comment.getCommentText().trim().isEmpty()) {
            return false;
        }

        if (commentDAO.findByWorkIdAndJudgeId(comment.getWorkId(), comment.getJudgeId()) != null) {
            return false;
        }

        // 3. 调用DAO插入数据库
        return commentDAO.insert(comment) > 0;
    }

    @Override
    public boolean updateComment(Comment comment) {
        // 1. 验证必要字段
        if (comment.getCommentId() == null) {
            return false;
        }

        // 2. 验证评语内容不为空
        if (comment.getCommentText() == null || comment.getCommentText().trim().isEmpty()) {
            return false;
        }

        // 3. 调用DAO更新数据库
        return commentDAO.update(comment) > 0;
    }

    @Override
    public boolean deleteComment(Integer commentId) {
        if (commentId == null) {
            return false;
        }
        return commentDAO.deleteById(commentId) > 0;
    }

    @Override
    public Comment getCommentById(Integer commentId) {
        if (commentId == null) {
            return null;
        }
        return commentDAO.findById(commentId);
    }

    @Override
    public List<Comment> getCommentsByWorkId(Integer workId) {
        if (workId == null) {
            return null;
        }
        return commentDAO.findByWorkId(workId);
    }

    @Override
    public List<Comment> getCommentsByJudgeId(Integer judgeId) {
        if (judgeId == null) {
            return null;
        }
        return commentDAO.findByJudgeId(judgeId);
    }

    @Override
    public List<Comment> getAllComments() {
        return commentDAO.findAll();
    }
}
