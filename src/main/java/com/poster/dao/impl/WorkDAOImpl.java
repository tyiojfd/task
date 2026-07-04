package com.poster.dao.impl;

import com.poster.dao.WorkDAO;
import com.poster.model.Work;
import com.poster.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 作品DAO实现类
 * @author 团队共建
 * @date 2026-07-04
 */
public class WorkDAOImpl implements WorkDAO {

    @Override
    public int insert(Work work) {
        // TODO: 实现作品插入
        String sql = "INSERT INTO work (team_id, competition_id, title, description, status) VALUES (?, ?, ?, ?, ?)";
        return 0;
    }

    @Override
    public int deleteById(Integer workId) {
        // TODO: 实现根据ID删除作品
        String sql = "DELETE FROM work WHERE work_id = ?";
        return 0;
    }

    @Override
    public int update(Work work) {
        // TODO: 实现作品更新
        String sql = "UPDATE work SET title=?, description=?, status=? WHERE work_id=?";
        return 0;
    }

    @Override
    public Work findById(Integer workId) {
        // TODO: 实现根据ID查询作品
        String sql = "SELECT * FROM work WHERE work_id = ?";
        return null;
    }

    @Override
    public List<Work> findAll() {
        // TODO: 实现查询所有作品
        String sql = "SELECT * FROM work ORDER BY submit_time DESC";
        return new ArrayList<>();
    }

    @Override
    public List<Work> findByTeamId(Integer teamId) {
        // TODO: 实现根据队伍ID查询作品
        String sql = "SELECT * FROM work WHERE team_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<Work> findByCompetitionId(Integer competitionId) {
        // TODO: 实现根据竞赛ID查询作品
        String sql = "SELECT * FROM work WHERE competition_id = ?";
        return new ArrayList<>();
    }

    @Override
    public List<Work> findByStatus(Integer status) {
        // TODO: 实现根据状态查询作品
        String sql = "SELECT * FROM work WHERE status = ?";
        return new ArrayList<>();
    }

    @Override
    public int count() {
        // TODO: 实现统计作品总数
        String sql = "SELECT COUNT(*) FROM work";
        return 0;
    }
}
