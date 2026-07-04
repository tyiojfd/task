package com.poster.dao.impl;

import com.poster.dao.TeamDAO;
import com.poster.model.Team;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 队伍DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class TeamDAOImpl implements TeamDAO {

    @Override
    public int insert(Team team) {
        // TODO: 实现队伍插入
        String sql = "INSERT INTO team (team_name, leader_id, competition_id, category_id, status) VALUES (?, ?, ?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer teamId) {
        // TODO: 实现根据ID删除队伍
        String sql = "DELETE FROM team WHERE team_id = ?";
        return 0;
    }

    @Override
    public int update(Team team) {
        // TODO: 实现队伍更新
        String sql = "UPDATE team SET team_name=?, status=? WHERE team_id=?";
        return 0;
    }

    @Override
    public Team findById(Integer teamId) {
        // TODO: 实现根据ID查询队伍
        String sql = "SELECT * FROM team WHERE team_id = ?";
        return null;
    }

    @Override
    public List<Team> findAll() {
        // TODO: 实现查询所有队伍
        String sql = "SELECT * FROM team ORDER BY create_time DESC";
        return new ArrayList<>();
    }

    @Override
    public List<Team> findByLeaderId(Integer leaderId) {
        // TODO: 实现根据队长ID查询队伍
        String sql = "SELECT * FROM team WHERE leader_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<Team> findByCompetitionId(Integer competitionId) {
        // TODO: 实现根据竞赛ID查询队伍
        String sql = "SELECT * FROM team WHERE competition_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<Team> findByStatus(Integer status) {
        // TODO: 实现根据状态查询队伍
        String sql = "SELECT * FROM team WHERE status = ?";
        return new ArrayList<>();
    }

    @Override
    public int count() {
        // TODO: 实现统计队伍总数
        String sql = "SELECT COUNT(*) FROM team";
        return 0;
    }
}
