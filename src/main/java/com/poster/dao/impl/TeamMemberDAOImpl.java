package com.poster.dao.impl;

import com.poster.dao.TeamMemberDAO;
import com.poster.model.TeamMember;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 队伍成员DAO实现类
 * @author 杨祥博
 * @date 2026-07-05
 */
public class TeamMemberDAOImpl implements TeamMemberDAO {

    @Override
    public int insert(TeamMember teamMember) {
        String sql = "INSERT INTO team_member (team_id, user_id, is_leader) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, teamMember.getTeamId());
            pstmt.setInt(2, teamMember.getUserId());
            // role: 1=队长 -> is_leader=1, 2=队员 -> is_leader=0
            int isLeader = (teamMember.getRole() != null && teamMember.getRole() == 1) ? 1 : 0;
            pstmt.setInt(3, isLeader);

            int rows = pstmt.executeUpdate();

            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        teamMember.setId(rs.getInt(1));
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
        String sql = "DELETE FROM team_member WHERE id = ?";
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
    public int deleteByTeamIdAndUserId(Integer teamId, Integer userId) {
        String sql = "DELETE FROM team_member WHERE team_id = ? AND user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, teamId);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(TeamMember teamMember) {
        String sql = "UPDATE team_member SET is_leader=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int isLeader = (teamMember.getRole() != null && teamMember.getRole() == 1) ? 1 : 0;
            pstmt.setInt(1, isLeader);
            pstmt.setInt(2, teamMember.getId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public TeamMember findById(Integer id) {
        String sql = "SELECT * FROM team_member WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractTeamMemberFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<TeamMember> findByTeamId(Integer teamId) {
        String sql = "SELECT * FROM team_member WHERE team_id = ? ORDER BY is_leader DESC, join_time ASC";
        List<TeamMember> members = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, teamId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    members.add(extractTeamMemberFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return members;
    }

    @Override
    public List<TeamMember> findByUserId(Integer userId) {
        String sql = "SELECT * FROM team_member WHERE user_id = ? ORDER BY join_time DESC";
        List<TeamMember> members = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    members.add(extractTeamMemberFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return members;
    }

    @Override
    public int countByTeamId(Integer teamId) {
        String sql = "SELECT COUNT(*) FROM team_member WHERE team_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, teamId);

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

    /**
     * 从ResultSet中提取TeamMember对象
     */
    private TeamMember extractTeamMemberFromResultSet(ResultSet rs) throws SQLException {
        TeamMember member = new TeamMember();
        member.setId(rs.getInt("id"));
        member.setTeamId(rs.getInt("team_id"));
        member.setUserId(rs.getInt("user_id"));
        // is_leader: 1 -> role=1(队长), 0 -> role=2(队员)
        int isLeader = rs.getInt("is_leader");
        member.setRole(isLeader == 1 ? 1 : 2);

        Timestamp joinTime = rs.getTimestamp("join_time");
        if (joinTime != null) {
            member.setJoinTime(joinTime.toLocalDateTime());
        }

        return member;
    }
}
