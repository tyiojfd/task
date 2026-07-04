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
        // TODO: 实现竞赛插入
        String sql = "INSERT INTO competition (year, name, theme, description, submit_deadline, max_team_size, status, creator_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer competitionId) {
        // TODO: 实现根据ID删除竞赛
        String sql = "DELETE FROM competition WHERE competition_id = ?";
        return 0;
    }

    @Override
    public int update(Competition competition) {
        // TODO: 实现竞赛更新
        String sql = "UPDATE competition SET year=?, name=?, theme=?, description=?, submit_deadline=?, max_team_size=?, status=? WHERE competition_id=?";
        return 0;
    }

    @Override
    public Competition findById(Integer competitionId) {
        // TODO: 实现根据ID查询竞赛
        String sql = "SELECT * FROM competition WHERE competition_id = ?";
        return null;
    }

    @Override
    public List<Competition> findAll() {
        // TODO: 实现查询所有竞赛
        String sql = "SELECT * FROM competition ORDER BY create_time DESC";
        return new ArrayList<>();
    }

    @Override
    public List<Competition> findByYear(Integer year) {
        // TODO: 实现根据年度查询竞赛
        String sql = "SELECT * FROM competition WHERE year = ?";
        return new ArrayList<>();
    }

    @Override
    public List<Competition> findByStatus(Integer status) {
        // TODO: 实现根据状态查询竞赛
        String sql = "SELECT * FROM competition WHERE status = ?";
        return new ArrayList<>();
    }

    @Override
    public List<Competition> findByCreatorId(Integer creatorId) {
        // TODO: 实现根据创建人查询竞赛
        String sql = "SELECT * FROM competition WHERE creator_id = ?";
        return new ArrayList<>();
    }

    @Override
    public int count() {
        // TODO: 实现统计竞赛总数
        String sql = "SELECT COUNT(*) FROM competition";
        return 0;
    }
}
