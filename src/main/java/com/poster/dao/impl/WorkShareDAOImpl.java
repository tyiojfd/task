package com.poster.dao.impl;

import com.poster.dao.WorkShareDAO;
import com.poster.model.WorkShare;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 作品分享DAO实现类
 * @author 队员B
 * @date 2026-07-06
 */
public class WorkShareDAOImpl implements WorkShareDAO {

    @Override
    public int insert(WorkShare workShare) {
        String sql = "INSERT INTO work_share (work_id, user_id, platform) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, workShare.getWorkId());
            pstmt.setInt(2, workShare.getUserId());
            pstmt.setString(3, workShare.getPlatform());

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        workShare.setId(rs.getInt(1));
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
        String sql = "DELETE FROM work_share WHERE id = ?";
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
    public List<WorkShare> findByWorkId(Integer workId) {
        String sql = "SELECT * FROM work_share WHERE work_id = ?";
        List<WorkShare> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    WorkShare ws = new WorkShare();
                    ws.setId(rs.getInt("id"));
                    ws.setWorkId(rs.getInt("work_id"));
                    ws.setUserId(rs.getInt("user_id"));
                    ws.setPlatform(rs.getString("platform"));
                    Timestamp shareTime = rs.getTimestamp("share_time");
                    if (shareTime != null) {
                        ws.setShareTime(shareTime.toLocalDateTime());
                    }
                    list.add(ws);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<WorkShare> findByUserId(Integer userId) {
        String sql = "SELECT * FROM work_share WHERE user_id = ?";
        List<WorkShare> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    WorkShare ws = new WorkShare();
                    ws.setId(rs.getInt("id"));
                    ws.setWorkId(rs.getInt("work_id"));
                    ws.setUserId(rs.getInt("user_id"));
                    ws.setPlatform(rs.getString("platform"));
                    Timestamp shareTime = rs.getTimestamp("share_time");
                    if (shareTime != null) {
                        ws.setShareTime(shareTime.toLocalDateTime());
                    }
                    list.add(ws);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int countByWorkId(Integer workId) {
        String sql = "SELECT COUNT(*) FROM work_share WHERE work_id = ?";
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

    @Override
    public List<WorkShare> findAll() {
        String sql = "SELECT * FROM work_share ORDER BY share_time DESC";
        List<WorkShare> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                WorkShare ws = new WorkShare();
                ws.setId(rs.getInt("id"));
                ws.setWorkId(rs.getInt("work_id"));
                ws.setUserId(rs.getInt("user_id"));
                Timestamp shareTime = rs.getTimestamp("share_time");
                if (shareTime != null) {
                    ws.setShareTime(shareTime.toLocalDateTime());
                }
                list.add(ws);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
