package com.poster.dao.impl;

import com.poster.dao.ScoreDAO;
import com.poster.model.Score;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 评分记录DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class ScoreDAOImpl implements ScoreDAO {

    @Override
    public int insert(Score score) {
        // TODO: 实现评分记录插入
        String sql = "INSERT INTO score (work_id, judge_id, score) VALUES (?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer scoreId) {
        // TODO: 实现根据ID删除评分记录
        String sql = "DELETE FROM score WHERE score_id = ?";
        return 0;
    }

    @Override
    public int update(Score score) {
        // TODO: 实现更新评分
        String sql = "UPDATE score SET score=? WHERE score_id=?";
        return 0;
    }

    @Override
    public Score findById(Integer scoreId) {
        // TODO: 实现根据ID查询评分记录
        String sql = "SELECT * FROM score WHERE score_id = ?";
        return null;
    }

    @Override
    public List<Score> findByWorkId(Integer workId) {
        // TODO: 实现根据作品ID查询所有评分
        String sql = "SELECT * FROM score WHERE work_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<Score> findByJudgeId(Integer judgeId) {
        // TODO: 实现根据评委ID查询所有评分
        String sql = "SELECT * FROM score WHERE judge_id = ?";
        return new ArrayList<>();
    }

    @Override
    public Double getAverageScoreByWorkId(Integer workId) {
        // TODO: 实现查询作品的平均分
        String sql = "SELECT AVG(score) FROM score WHERE work_id = ?";
        return 0.0;
    }

    @Override
    public List<Score> findAll() {
        // TODO: 实现查询所有评分记录
        String sql = "SELECT * FROM score ORDER BY score_time DESC";
        return new ArrayList<>();
    }
}
