package com.poster.dao.impl;

import com.poster.dao.AwardDAO;
import com.poster.model.Award;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 获奖设置DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class AwardDAOImpl implements AwardDAO {

    @Override
    public int insert(Award award) {
        // TODO: 实现获奖记录插入
        String sql = "INSERT INTO award (competition_id, work_id, award_level) VALUES (?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer awardId) {
        // TODO: 实现根据ID删除获奖记录
        String sql = "DELETE FROM award WHERE award_id = ?";
        return 0;
    }

    @Override
    public int update(Award award) {
        // TODO: 实现更新获奖信息
        String sql = "UPDATE award SET award_level=? WHERE award_id=?";
        return 0;
    }

    @Override
    public Award findById(Integer awardId) {
        // TODO: 实现根据ID查询获奖记录
        String sql = "SELECT * FROM award WHERE award_id = ?";
        return null;
    }

    @Override
    public List<Award> findByCompetitionId(Integer competitionId) {
        // TODO: 实现根据竞赛ID查询所有获奖记录
        String sql = "SELECT * FROM award WHERE competition_id = ?";
        return new ArrayList<>();
    }

    @Override
    public Award findByWorkId(Integer workId) {
        // TODO: 实现根据作品ID查询获奖记录
        String sql = "SELECT * FROM award WHERE work_id = ?";
        return null;
    }

    @Override
    public List<Award> findAll() {
        // TODO: 实现查询所有获奖记录
        String sql = "SELECT * FROM award ORDER BY award_time DESC";
        return new ArrayList<>();
    }
}
