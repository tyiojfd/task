package com.poster.dao.impl;

import com.poster.dao.AwardDAO;
import com.poster.model.Award;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 获奖设置DAO实现类
 * @author 队员C
 * @date 2026-07-08
 */
public class AwardDAOImpl implements AwardDAO {

    @Override
    public int insert(Award award) {
        String sql = "INSERT INTO award (competition_id, work_id, award_level, final_score, issuer_id) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, award.getCompetitionId());
            pstmt.setInt(2, award.getWorkId());
            pstmt.setString(3, award.getAwardLevel());
            pstmt.setDouble(4, award.getFinalScore());
            pstmt.setInt(5, award.getIssuerId());

            int rows = pstmt.executeUpdate();

            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        award.setAwardId(rs.getInt(1));
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
    public int deleteById(Integer awardId) {
        String sql = "DELETE FROM award WHERE award_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, awardId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(Award award) {
        String sql = "UPDATE award SET award_level=?, final_score=? WHERE award_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, award.getAwardLevel());
            pstmt.setDouble(2, award.getFinalScore());
            pstmt.setInt(3, award.getAwardId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public Award findById(Integer awardId) {
        String sql = "SELECT * FROM award WHERE award_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, awardId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractAwardFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Award> findByCompetitionId(Integer competitionId) {
        String sql = "SELECT * FROM award WHERE competition_id = ? ORDER BY final_score DESC";
        List<Award> awardList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, competitionId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    awardList.add(extractAwardFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return awardList;
    }

    @Override
    public Award findByWorkId(Integer workId) {
        String sql = "SELECT * FROM award WHERE work_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractAwardFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Award> findAll() {
        String sql = "SELECT * FROM award ORDER BY award_time DESC";
        List<Award> awardList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                awardList.add(extractAwardFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return awardList;
    }

    /**
     * 从ResultSet中提取Award对象
     */
    private Award extractAwardFromResultSet(ResultSet rs) throws SQLException {
        Award award = new Award();
        award.setAwardId(rs.getInt("award_id"));
        award.setCompetitionId(rs.getInt("competition_id"));
        award.setWorkId(rs.getInt("work_id"));
        award.setAwardLevel(rs.getString("award_level"));
        award.setFinalScore(rs.getDouble("final_score"));
        award.setIssuerId(rs.getInt("issuer_id"));

        Timestamp awardTime = rs.getTimestamp("award_time");
        if (awardTime != null) {
            award.setAwardTime(awardTime.toLocalDateTime());
        }

        return award;
    }
}
