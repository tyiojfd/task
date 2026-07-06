package com.poster.dao.impl;

import com.poster.dao.InvitationDAO;
import com.poster.model.Invitation;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 邀请记录DAO实现类
 * @author 杨祥博
 * @date 2026-07-06
 */
public class InvitationDAOImpl implements InvitationDAO {

    @Override
    public int insert(Invitation invitation) {
        String sql = "INSERT INTO invitation (team_id, inviter_id, invitee_id, status, invite_time) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, invitation.getTeamId());
            pstmt.setInt(2, invitation.getInviterId());
            pstmt.setInt(3, invitation.getInviteeId());
            pstmt.setInt(4, invitation.getStatus() != null ? invitation.getStatus() : 0);
            pstmt.setTimestamp(5, invitation.getInviteTime() != null
                    ? Timestamp.valueOf(invitation.getInviteTime()) : new Timestamp(System.currentTimeMillis()));

            int rows = pstmt.executeUpdate();

            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        invitation.setInvitationId(rs.getInt(1));
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
    public int deleteById(Integer invitationId) {
        String sql = "DELETE FROM invitation WHERE invitation_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, invitationId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(Invitation invitation) {
        String sql = "UPDATE invitation SET status=?, response_time=? WHERE invitation_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, invitation.getStatus());
            pstmt.setTimestamp(2, invitation.getResponseTime() != null
                    ? Timestamp.valueOf(invitation.getResponseTime()) : null);
            pstmt.setInt(3, invitation.getInvitationId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public Invitation findById(Integer invitationId) {
        String sql = "SELECT * FROM invitation WHERE invitation_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, invitationId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractInvitationFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Invitation> findByInviteeId(Integer inviteeId) {
        String sql = "SELECT * FROM invitation WHERE invitee_id = ? ORDER BY invite_time DESC";
        List<Invitation> invitations = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, inviteeId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    invitations.add(extractInvitationFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return invitations;
    }

    @Override
    public List<Invitation> findByTeamId(Integer teamId) {
        String sql = "SELECT * FROM invitation WHERE team_id = ? ORDER BY invite_time DESC";
        List<Invitation> invitations = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, teamId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    invitations.add(extractInvitationFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return invitations;
    }

    @Override
    public List<Invitation> findByStatus(Integer status) {
        String sql = "SELECT * FROM invitation WHERE status = ? ORDER BY invite_time DESC";
        List<Invitation> invitations = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, status);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    invitations.add(extractInvitationFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return invitations;
    }

    @Override
    public List<Invitation> findAll() {
        String sql = "SELECT * FROM invitation ORDER BY invite_time DESC";
        List<Invitation> invitations = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                invitations.add(extractInvitationFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return invitations;
    }

    /**
     * 从ResultSet中提取Invitation对象
     */
    private Invitation extractInvitationFromResultSet(ResultSet rs) throws SQLException {
        Invitation invitation = new Invitation();
        invitation.setInvitationId(rs.getInt("invitation_id"));
        invitation.setTeamId(rs.getInt("team_id"));
        invitation.setInviterId(rs.getInt("inviter_id"));
        invitation.setInviteeId(rs.getInt("invitee_id"));
        invitation.setStatus(rs.getInt("status"));

        Timestamp inviteTime = rs.getTimestamp("invite_time");
        if (inviteTime != null) {
            invitation.setInviteTime(inviteTime.toLocalDateTime());
        }

        Timestamp responseTime = rs.getTimestamp("response_time");
        if (responseTime != null) {
            invitation.setResponseTime(responseTime.toLocalDateTime());
        }

        return invitation;
    }
}
