package com.poster.dao.impl;

import com.poster.dao.TeamApplicationDAO;
import com.poster.model.TeamApplication;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 入队申请DAO实现类
 * @author Claude
 * @date 2026-07-12
 */
public class TeamApplicationDAOImpl implements TeamApplicationDAO {

    @Override
    public int insert(TeamApplication application) {
        String sql = "INSERT INTO team_application (team_id, applicant_id, message, status) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setInt(1, application.getTeamId());
            pstmt.setInt(2, application.getApplicantId());
            pstmt.setString(3, application.getMessage());
            pstmt.setInt(4, application.getStatus() != null ? application.getStatus() : 0);
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) application.setApplicationId(rs.getInt(1));
                }
            }
            return rows;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(TeamApplication application) {
        String sql = "UPDATE team_application SET message=?, status=?, response_time=? WHERE application_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, application.getMessage());
            pstmt.setInt(2, application.getStatus());
            if (application.getResponseTime() != null) {
                pstmt.setTimestamp(3, Timestamp.valueOf(application.getResponseTime()));
            } else {
                pstmt.setNull(3, Types.TIMESTAMP);
            }
            pstmt.setInt(4, application.getApplicationId());
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public TeamApplication findById(Integer applicationId) {
        String sql = "SELECT * FROM team_application WHERE application_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, applicationId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return extract(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<TeamApplication> findByTeamId(Integer teamId) {
        return queryList("SELECT * FROM team_application WHERE team_id = ? ORDER BY apply_time DESC", teamId);
    }

    @Override
    public List<TeamApplication> findByApplicantId(Integer applicantId) {
        return queryList("SELECT * FROM team_application WHERE applicant_id = ? ORDER BY apply_time DESC", applicantId);
    }

    @Override
    public List<TeamApplication> findPendingByTeamId(Integer teamId) {
        return queryList("SELECT * FROM team_application WHERE team_id = ? AND status = 0 ORDER BY apply_time DESC", teamId);
    }

    @Override
    public TeamApplication findPendingByTeamIdAndApplicantId(Integer teamId, Integer applicantId) {
        String sql = "SELECT * FROM team_application WHERE team_id = ? AND applicant_id = ? AND status = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, teamId);
            pstmt.setInt(2, applicantId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return extract(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private List<TeamApplication> queryList(String sql, Integer id) {
        List<TeamApplication> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) list.add(extract(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private TeamApplication extract(ResultSet rs) throws SQLException {
        TeamApplication application = new TeamApplication();
        application.setApplicationId(rs.getInt("application_id"));
        application.setTeamId(rs.getInt("team_id"));
        application.setApplicantId(rs.getInt("applicant_id"));
        application.setMessage(rs.getString("message"));
        application.setStatus(rs.getInt("status"));
        Timestamp applyTime = rs.getTimestamp("apply_time");
        if (applyTime != null) application.setApplyTime(applyTime.toLocalDateTime());
        Timestamp responseTime = rs.getTimestamp("response_time");
        if (responseTime != null) application.setResponseTime(responseTime.toLocalDateTime());
        return application;
    }
}
