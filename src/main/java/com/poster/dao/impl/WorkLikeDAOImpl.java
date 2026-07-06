package com.poster.dao.impl;

import com.poster.dao.WorkLikeDAO;
import com.poster.model.WorkLike;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 作品点赞DAO实现类
 * @author 队员B
 * @date 2026-07-06
 */
public class WorkLikeDAOImpl implements WorkLikeDAO {

    @Override
    public int insert(WorkLike workLike) {
        String sql = "INSERT INTO work_like (work_id, user_id) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, workLike.getWorkId());
            pstmt.setInt(2, workLike.getUserId());

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        workLike.setId(rs.getInt(1));
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
    public int deleteById(Integer id) {
        String sql = "DELETE FROM work_like WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int deleteByWorkIdAndUserId(Integer workId, Integer userId) {
        String sql = "DELETE FROM work_like WHERE work_id = ? AND user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public List<WorkLike> findByWorkId(Integer workId) {
        String sql = "SELECT * FROM work_like WHERE work_id = ?";
        List<WorkLike> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    WorkLike wl = new WorkLike();
                    wl.setId(rs.getInt("id"));
                    wl.setWorkId(rs.getInt("work_id"));
                    wl.setUserId(rs.getInt("user_id"));
                    Timestamp likeTime = rs.getTimestamp("like_time");
                    if (likeTime != null) {
                        wl.setLikeTime(likeTime.toLocalDateTime());
                    }
                    list.add(wl);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<WorkLike> findByUserId(Integer userId) {
        String sql = "SELECT * FROM work_like WHERE user_id = ?";
        List<WorkLike> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    WorkLike wl = new WorkLike();
                    wl.setId(rs.getInt("id"));
                    wl.setWorkId(rs.getInt("work_id"));
                    wl.setUserId(rs.getInt("user_id"));
                    Timestamp likeTime = rs.getTimestamp("like_time");
                    if (likeTime != null) {
                        wl.setLikeTime(likeTime.toLocalDateTime());
                    }
                    list.add(wl);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean isLiked(Integer workId, Integer userId) {
        String sql = "SELECT COUNT(*) FROM work_like WHERE work_id = ? AND user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);
            pstmt.setInt(2, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public int countByWorkId(Integer workId) {
        String sql = "SELECT COUNT(*) FROM work_like WHERE work_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
