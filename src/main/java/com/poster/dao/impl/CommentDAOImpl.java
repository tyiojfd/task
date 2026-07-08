package com.poster.dao.impl;

import com.poster.dao.CommentDAO;
import com.poster.model.Comment;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 评语记录DAO实现类
 * @author 队员C
 * @date 2026-07-08
 */
public class CommentDAOImpl implements CommentDAO {

    @Override
    public int insert(Comment comment) {
        String sql = "INSERT INTO comment (work_id, judge_id, comment_text) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, comment.getWorkId());
            pstmt.setInt(2, comment.getJudgeId());
            pstmt.setString(3, comment.getCommentText());

            int rows = pstmt.executeUpdate();

            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        comment.setCommentId(rs.getInt(1));
                    }
                }
            }

            return rows;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int deleteById(Integer commentId) {
        String sql = "DELETE FROM comment WHERE comment_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, commentId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(Comment comment) {
        String sql = "UPDATE comment SET comment_text=? WHERE comment_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, comment.getCommentText());
            pstmt.setInt(2, comment.getCommentId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public Comment findById(Integer commentId) {
        String sql = "SELECT * FROM comment WHERE comment_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, commentId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractCommentFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Comment> findByWorkId(Integer workId) {
        String sql = "SELECT * FROM comment WHERE work_id = ? ORDER BY comment_time DESC";
        List<Comment> commentList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    commentList.add(extractCommentFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return commentList;
    }

    @Override
    public List<Comment> findByJudgeId(Integer judgeId) {
        String sql = "SELECT * FROM comment WHERE judge_id = ? ORDER BY comment_time DESC";
        List<Comment> commentList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, judgeId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    commentList.add(extractCommentFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return commentList;
    }

    @Override
    public List<Comment> findAll() {
        String sql = "SELECT * FROM comment ORDER BY comment_time DESC";
        List<Comment> commentList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                commentList.add(extractCommentFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return commentList;
    }

    /**
     * 从ResultSet中提取Comment对象
     */
    private Comment extractCommentFromResultSet(ResultSet rs) throws SQLException {
        Comment comment = new Comment();
        comment.setCommentId(rs.getInt("comment_id"));
        comment.setWorkId(rs.getInt("work_id"));
        comment.setJudgeId(rs.getInt("judge_id"));
        comment.setCommentText(rs.getString("comment_text"));

        Timestamp commentTime = rs.getTimestamp("comment_time");
        if (commentTime != null) {
            comment.setCommentTime(commentTime.toLocalDateTime());
        }

        return comment;
    }
}
