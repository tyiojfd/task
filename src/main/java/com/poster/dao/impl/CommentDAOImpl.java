package com.poster.dao.impl;

import com.poster.dao.CommentDAO;
import com.poster.model.Comment;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 评语记录DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class CommentDAOImpl implements CommentDAO {

    @Override
    public int insert(Comment comment) {
        // TODO: 实现评语记录插入
        String sql = "INSERT INTO comment (work_id, judge_id, comment_text) VALUES (?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer commentId) {
        // TODO: 实现根据ID删除评语记录
        String sql = "DELETE FROM comment WHERE comment_id = ?";
        return 0;
    }

    @Override
    public int update(Comment comment) {
        // TODO: 实现更新评语
        String sql = "UPDATE comment SET comment_text=? WHERE comment_id=?";
        return 0;
    }

    @Override
    public Comment findById(Integer commentId) {
        // TODO: 实现根据ID查询评语记录
        String sql = "SELECT * FROM comment WHERE comment_id = ?";
        return null;
    }

    @Override
    public List<Comment> findByWorkId(Integer workId) {
        // TODO: 实现根据作品ID查询所有评语
        String sql = "SELECT * FROM comment WHERE work_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<Comment> findByJudgeId(Integer judgeId) {
        // TODO: 实现根据评委ID查询所有评语
        String sql = "SELECT * FROM comment WHERE judge_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<Comment> findAll() {
        // TODO: 实现查询所有评语记录
        String sql = "SELECT * FROM comment ORDER BY comment_time DESC";
        return new ArrayList<>();
    }
}
