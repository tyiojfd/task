package com.poster.dao.impl;

import com.poster.dao.CompetitionDAO;
import com.poster.model.Competition;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 竞赛DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class CompetitionDAOImpl implements CompetitionDAO {

    @Override
    public int insert(Competition competition) {
        String sql = "INSERT INTO competition (year, name, theme, description, submit_deadline, max_team_size, status, creator_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, competition.getYear());
            pstmt.setString(2, competition.getName());
            pstmt.setString(3, competition.getTheme());
            pstmt.setString(4, competition.getDescription());
            pstmt.setTimestamp(5, Timestamp.valueOf(competition.getSubmitDeadline()));
            pstmt.setInt(6, competition.getMaxTeamSize());
            pstmt.setInt(7, competition.getStatus());
            pstmt.setInt(8, competition.getCreatorId());

            int rows = pstmt.executeUpdate();

            // 获取自动生成的ID
            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        competition.setCompetitionId(rs.getInt(1));
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
    public int deleteById(Integer competitionId) {
        String sql = "DELETE FROM competition WHERE competition_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, competitionId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(Competition competition) {
        String sql = "UPDATE competition SET year=?, name=?, theme=?, description=?, submit_deadline=?, max_team_size=?, status=? WHERE competition_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, competition.getYear());
            pstmt.setString(2, competition.getName());
            pstmt.setString(3, competition.getTheme());
            pstmt.setString(4, competition.getDescription());
            pstmt.setTimestamp(5, Timestamp.valueOf(competition.getSubmitDeadline()));
            pstmt.setInt(6, competition.getMaxTeamSize());
            pstmt.setInt(7, competition.getStatus());
            pstmt.setInt(8, competition.getCompetitionId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public Competition findById(Integer competitionId) {
        String sql = "SELECT * FROM competition WHERE competition_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, competitionId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractCompetitionFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Competition> findAll() {
        String sql = "SELECT * FROM competition ORDER BY create_time DESC";
        List<Competition> competitions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                competitions.add(extractCompetitionFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return competitions;
    }

    @Override
    public List<Competition> findByYear(Integer year) {
        String sql = "SELECT * FROM competition WHERE year = ?";
        List<Competition> competitions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, year);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    competitions.add(extractCompetitionFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return competitions;
    }

    @Override
    public List<Competition> findByStatus(Integer status) {
        String sql = "SELECT * FROM competition WHERE status = ?";
        List<Competition> competitions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, status);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    competitions.add(extractCompetitionFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return competitions;
    }

    @Override
    public List<Competition> findByCreatorId(Integer creatorId) {
        String sql = "SELECT * FROM competition WHERE creator_id = ?";
        List<Competition> competitions = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, creatorId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    competitions.add(extractCompetitionFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return competitions;
    }

    @Override
    public int count() {
        String sql = "SELECT COUNT(*) FROM competition";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * 从ResultSet中提取Competition对象
     */
    private Competition extractCompetitionFromResultSet(ResultSet rs) throws SQLException {
        Competition competition = new Competition();
        competition.setCompetitionId(rs.getInt("competition_id"));
        competition.setYear(rs.getInt("year"));
        competition.setName(rs.getString("name"));
        competition.setTheme(rs.getString("theme"));
        competition.setDescription(rs.getString("description"));

        Timestamp submitDeadline = rs.getTimestamp("submit_deadline");
        if (submitDeadline != null) {
            competition.setSubmitDeadline(submitDeadline.toLocalDateTime());
        }

        competition.setMaxTeamSize(rs.getInt("max_team_size"));
        competition.setStatus(rs.getInt("status"));
        competition.setCreatorId(rs.getInt("creator_id"));

        Timestamp createTime = rs.getTimestamp("create_time");
        if (createTime != null) {
            competition.setCreateTime(createTime.toLocalDateTime());
        }

        return competition;
    }
}
