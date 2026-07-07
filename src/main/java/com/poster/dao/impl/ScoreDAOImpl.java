package com.poster.dao.impl;

import com.poster.dao.ScoreDAO;
import com.poster.model.Score;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 评分记录DAO实现类
 * @author 队员C
 * @date 2026-07-07
 */
public class ScoreDAOImpl implements ScoreDAO {

    @Override
    public int insert(Score score) {
        String sql = "INSERT INTO score (work_id, judge_id, score) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, score.getWorkId());
            pstmt.setInt(2, score.getJudgeId());
            pstmt.setDouble(3, score.getScore());

            int rows = pstmt.executeUpdate();

            if (rows > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        score.setScoreId(rs.getInt(1));
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
    public int deleteById(Integer scoreId) {
        String sql = "DELETE FROM score WHERE score_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, scoreId);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public int update(Score score) {
        String sql = "UPDATE score SET score=? WHERE score_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setDouble(1, score.getScore());
            pstmt.setInt(2, score.getScoreId());

            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    @Override
    public Score findById(Integer scoreId) {
        String sql = "SELECT * FROM score WHERE score_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, scoreId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractScoreFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Score> findByWorkId(Integer workId) {
        String sql = "SELECT * FROM score WHERE work_id = ? ORDER BY score_time DESC";
        List<Score> scoreList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    scoreList.add(extractScoreFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return scoreList;
    }

    @Override
    public List<Score> findByJudgeId(Integer judgeId) {
        String sql = "SELECT * FROM score WHERE judge_id = ? ORDER BY score_time DESC";
        List<Score> scoreList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, judgeId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    scoreList.add(extractScoreFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return scoreList;
    }

    @Override
    public Double getAverageScoreByWorkId(Integer workId) {
        String sql = "SELECT AVG(score) FROM score WHERE work_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, workId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    double avg = rs.getDouble(1);
                    return rs.wasNull() ? 0.0 : avg;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    @Override
    public List<Score> findAll() {
        String sql = "SELECT * FROM score ORDER BY score_time DESC";
        List<Score> scoreList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                scoreList.add(extractScoreFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return scoreList;
    }

    /**
     * 从ResultSet中提取Score对象
     */
    private Score extractScoreFromResultSet(ResultSet rs) throws SQLException {
        Score score = new Score();
        score.setScoreId(rs.getInt("score_id"));
        score.setWorkId(rs.getInt("work_id"));
        score.setJudgeId(rs.getInt("judge_id"));
        score.setScore(rs.getDouble("score"));

        Timestamp scoreTime = rs.getTimestamp("score_time");
        if (scoreTime != null) {
            score.setScoreTime(scoreTime.toLocalDateTime());
        }

        return score;
    }
}
