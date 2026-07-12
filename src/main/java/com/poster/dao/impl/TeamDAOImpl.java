package com.poster.dao.impl;

import com.poster.dao.TeamDAO;
import com.poster.model.Team;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 队伍DAO实现类
 * @author 杨祥博
 * @date 2026-07-05
 */
public class TeamDAOImpl implements TeamDAO {

    @Override
    public int insert(Team team) {
        String sql = "INSERT INTO team (team_name, competition_id, category_id, leader_id, team_desc, status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, team.getTeamName());
            pstmt.setInt(2, team.getCompetitionId());
            pstmt.setInt(3, team.getCategoryId());
            pstmt.setInt(4, team.getLeaderId());
            pstmt.setString(5, team.getTeamDesc());
            pstmt.setInt(6, team.getStatus() != null ? team.getStatus() : 1);

            int rows = pstmt.executeUpdate();

            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        team.setTeamId(rs.getInt(1));
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
    public int deleteById(Integer teamId) {
        String sql = "DELETE FROM team WHERE team_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, teamId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(Team team) {
        String sql = "UPDATE team SET team_name=?, competition_id=?, category_id=?, team_desc=?, status=? WHERE team_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, team.getTeamName());
            pstmt.setInt(2, team.getCompetitionId());
            pstmt.setInt(3, team.getCategoryId());
            pstmt.setString(4, team.getTeamDesc());
            pstmt.setInt(5, team.getStatus());
            pstmt.setInt(6, team.getTeamId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public Team findById(Integer teamId) {
        String sql = "SELECT * FROM team WHERE team_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, teamId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractTeamFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Team> findAll() {
        String sql = "SELECT * FROM team ORDER BY create_time DESC";
        List<Team> teams = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                teams.add(extractTeamFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return teams;
    }

    @Override
    public List<Team> findByLeaderId(Integer leaderId) {
        String sql = "SELECT * FROM team WHERE leader_id = ? ORDER BY create_time DESC";
        List<Team> teams = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, leaderId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    teams.add(extractTeamFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return teams;
    }

    @Override
    public List<Team> findByCompetitionId(Integer competitionId) {
        String sql = "SELECT * FROM team WHERE competition_id = ? ORDER BY create_time DESC";
        List<Team> teams = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, competitionId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    teams.add(extractTeamFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return teams;
    }

    @Override
    public List<Team> findByStatus(Integer status) {
        String sql = "SELECT * FROM team WHERE status = ? ORDER BY create_time DESC";
        List<Team> teams = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, status);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    teams.add(extractTeamFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return teams;
    }

    @Override
    public List<Team> searchByTeamName(String keyword) {
        List<Team> teams = new ArrayList<>();
        String sql = "SELECT * FROM team WHERE team_name LIKE ? LIMIT 20";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, "%" + keyword + "%");
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    teams.add(extractTeamFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return teams;
    }

    @Override
    public int count() {
        String sql = "SELECT COUNT(*) FROM team";
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
     * 从ResultSet中提取Team对象
     */
    private Team extractTeamFromResultSet(ResultSet rs) throws SQLException {
        Team team = new Team();
        team.setTeamId(rs.getInt("team_id"));
        team.setTeamName(rs.getString("team_name"));
        team.setCompetitionId(rs.getInt("competition_id"));
        team.setCategoryId(rs.getInt("category_id"));
        team.setLeaderId(rs.getInt("leader_id"));
        team.setTeamDesc(rs.getString("team_desc"));
        team.setStatus(rs.getInt("status"));

        Timestamp createTime = rs.getTimestamp("create_time");
        if (createTime != null) {
            team.setCreateTime(createTime.toLocalDateTime());
        }

        return team;
    }
}
